--[[
    FILE: ExeMap.lua
    DESCRIPTION: Map object for loading and clearing levels
    AUTHOR: Dewald Bodenstein
    VERSION: 0.4
    MOAI VERSION: v1.4p0
    CREATED: 17-08-2013
    
    http://lua-users.org/wiki/ObjectOrientationTutorial
]]

json = require ("executor/libs/dkjson")

ExeCamera = require "executor/ExeCamera"
ExeEditor = require "executor/props/ExeEditor"
ExeEditorPoint = require "executor/props/ExeEditorPoint"
ExeEditorPointsChain = require "executor/props/ExeEditorPointsChain"
ExePlayer = require "executor/props/ExePlayer"
ExeTimer = require "executor/props/ExeTimer"
ExeButton = require "executor/props/ExeButton"
ExeCrate = require "executor/props/ExeCrate"
ExeRock = require "executor/props/ExeRock"
ExeRigidBody = require "executor/props/ExeRigidBody"
ExeFloorChain = require "executor/props/ExeFloorChain"
ExeStaticConvex = require "executor/props/ExeStaticConvex"

local _M = {}

_M.BOX2D_WORLD = 0x0001
_M.BOX2D_PROPS = 0x0002
_M.BOX2D_SENSOR = 0x0003

function _M.init()
    _M.physWorld = MOAIBox2DWorld.new ()
    _M.physWorld:setGravity ( 0, -10 )
    _M.physWorld:setUnitsToMeters ( 2 )
    _M.physWorld:start ()
    ExeGame.layer_debug:setBox2DWorld ( _M.physWorld )
    
    _M.entities = {}
    _M.entityCount = 0
    
    MOAIGfxDevice.getFrameBuffer():setClearColor(1,1,1,0)
    _M.camera = ExeCamera.new(0.95)
    _M.player = nil
    
    -- load an entities file for predefined entities to load in a map
    _M.baseEntities = nil
    EntitiesList = function(data)
        _M.baseEntities = data.data
    end
    dofile('data/entities.lua')
end

function _M.loadMap(filename)
    local mapd = nil
    MapData = function(data)
        mapd = data
    end
    dofile(filename)
    
    if mapd.settings.physics_bodies then
        local textfile = io.input("data/bodies/"..mapd.settings.physics_bodies):read()
        local obj, pos, err = json.decode (textfile, 1, nil)
        if obj then
            _M.rigidBodies = obj["rigidBodies"]
            _M.dynamicBodies = obj["dynamicBodies"]
        end
        if err then
            print("Physics Bodies Error: "..err)
        end
    end
    
    MOAIGfxDevice.getFrameBuffer():setClearColor((1/255)*mapd.settings.clear_color.R,(1/255)*mapd.settings.clear_color.G,(1/255)*mapd.settings.clear_color.B,mapd.settings.clear_color.A)
    _M.physWorld:setGravity ( mapd.settings.gravity.x, mapd.settings.gravity.y )
    
    for i,entity in ipairs(mapd.entities) do
        _M.spawnEntity({class=entity.class_name,args=entity.args})
        print (_M.entities[entity.args.name])
    end
    
    for i,group in pairs(_M.entities) do
        print("i: "..i)
    end
    
    --if(_M.player~=nil) then
    --    _M.player:activate(_M.camera)
    --end
end

function _M.clearMap()
    _M.camera:clearAnchors()

    for i,group in pairs(_M.entities) do
        print (i)
        for j,entity in ipairs(group) do
            print("destroy " .. entity.name)
            entity:destroy()
            entity = nil
        end
        group = nil
    end

    _M.entities = {}
    _M.entityCount = 0
end

--[[
    spawnEntity(args)
    version 0.2
    args = {
        baseEntity
            Name of base entity to use from baseEntities table. Not
            necessary when class is set. (Optional)
        class
            Class name for the entity to spawn, not necessary
            when baseEntity is set. (Optional)
        args
            Arguments to pass to new() of the specified class. These are
            merged with the baseEntity's args. (Required)
    }
--]]
function _M.spawnEntity(args)
    _M.entityCount = _M.entityCount+1
    
    local options = args
    
    if args.baseEntity ~= nil then
        options = table.deepCopy(_M.baseEntities[args.baseEntity])
        options.class = options.class_name
        
        for key,value in pairs(args.args) do
            options.args[key] = value
        end
        
        options.args.name = args.baseEntity .. "_" .. _M.entityCount
    else
        options.args.name = "Entity_" .. _M.entityCount
    end
    
    -- revise name creation, now that a base entity is used the name from it can be used
    --if base.args.name == nil or base.args.name == "" then
        --base.args.name = "Entity_" .. _M.entityCount
    --end
    
    -- allow named entity groups, this has nothing to do with parent-child nodes
    if _M.entities[options.args.name] == nil then
        _M.entities[options.args.name] = {}
    end
    
    print(options.class.." = "..options.args.name)

    local ent = _G[options.class].new(options.args)
    
    table.insert(_M.entities[options.args.name], ent)
    
    return ent
end

function _M.destroyEntity(name)
    -- destroy all entities of the named group
    for i,value in ipairs(_M.entities[name]) do
        _M.entities[name][i]:destroy()
        _M.entities[name][i] = nil
    end
    
    _M.entities[name] = nil
end

function _M.globalCollision(phase, fix_a, fix_b, arbiter)
  local name = "None"
  if phase == MOAIBox2DArbiter.BEGIN then
    if fix_a:getBody().entity == _M.player then
      _M.player.on_ground = _M.player.on_ground + 1
      _M.player.jumping = false
      name = _M.player.name
    end
    if fix_b:getBody().entity == _M.player then
      _M.player.on_ground = _M.player.on_ground + 1
      _M.player.jumping = false
      name = _M.player.name
    end
    print ( 'gbegin: ' .. name )
  end
  if phase == MOAIBox2DArbiter.END then
    if fix_a:getBody().entity == _M.player then
      _M.player.on_ground = _M.player.on_ground - 1
      name = _M.player.name
    end
    if fix_b:getBody().entity == _M.player then
      _M.player.on_ground = _M.player.on_ground - 1
      name = ExeMap.player.name
    end
    print ( 'gend: ' .. name )
  end
  if phase == MOAIBox2DArbiter.PRE_SOLVE then
    --print ( 'gpre!' )
  end
  if phase == MOAIBox2DArbiter.POST_SOLVE then
    --print ( 'gpost!' )
  end
end

return _M