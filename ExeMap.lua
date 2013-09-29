--[[
  FILE: ExeMap.lua
	DESCRIPTION: Map object for loading and clearing levels
	AUTHOR: Dewald Bodenstein
	VERSION: 0.1
	MOAI VERSION: v1.4p0
	CREATED: 17-08-13
  
  http://lua-users.org/wiki/ObjectOrientationTutorial
]]

ExeCamera = require "executor/ExeCamera"
ExePlayer = require "executor/props/ExePlayer"
ExeTimer = require "executor/props/ExeTimer"
ExeButton = require "executor/props/ExeButton"
ExeCrate = require "executor/props/ExeCrate"
ExeRock = require "executor/props/ExeRock"
ExeFloorChain = require "executor/props/ExeFloorChain"
ExeRanchWorld = require "executor/props/ExeRanchWorld"
ExeRanchCow = require "executor/props/ExeRanchCow"
ExeRanchCows = require "executor/props/ExeRanchCows"
ExeRanchHorse = require "executor/props/ExeRanchHorse"
ExeRanchHorses = require "executor/props/ExeRanchHorses"

local _M = {}

_M.BOX2D_WORLD = 0x0001
_M.BOX2D_PROPS = 0x0002
_M.BOX2D_SENSOR = 0x0003

function _M.init(viewport,screenWidth,screenHeight)
  _M.layer = MOAILayer2D.new ()
  _M.layer:setViewport ( viewport )
  MOAISim.pushRenderPass ( _M.layer )
  
  _M.physWorld = MOAIBox2DWorld.new ()
  _M.physWorld:setGravity ( 0, -10 )
  _M.physWorld:setUnitsToMeters ( 2 )
  _M.physWorld:start ()
  _M.layer:setBox2DWorld ( _M.physWorld )
  
  _M.entities = {}
  _M.entityCount = 0
  
  MOAIGfxDevice.getFrameBuffer():setClearColor(0,0,0,0)
  _M.camera = ExeCamera.new(_M.layer,viewport,screenWidth/30,0.99)
  _M.player = nil
end

function _M.loadMap(filename)
    local mapd = nil
    MapData = function(data)
        mapd = data
    end
    dofile(filename)
    
    MOAIGfxDevice.getFrameBuffer():setClearColor((1/255)*mapd.settings.clear_color.R,(1/255)*mapd.settings.clear_color.G,(1/255)*mapd.settings.clear_color.B,mapd.settings.clear_color.A)
    _M.physWorld:setGravity ( mapd.settings.gravity.x, mapd.settings.gravity.y )
    
    for i,entity in ipairs(mapd.entities) do
        _M.spawnEntity(entity.class_name,entity.args)
        print (_M.entities[entity.args.name])
    end
    
    for i,group in pairs(_M.entities) do
        print("i: "..i)
    end
    
    if(_M.player~=nil) then
        _M.player:activate(_M.camera)
    end
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

function _M.spawnEntity(class,args)
  _M.entityCount = _M.entityCount+1
  
  if args.name == nil then
    args.name = "Entity_" .. _M.entityCount
  end
  
  if _M.entities[args.name] == nil then
    _M.entities[args.name] = {}
  end
  
  print(_M.entities[args.name])
  
  table.insert(_M.entities[args.name], _G[class].new(args))
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