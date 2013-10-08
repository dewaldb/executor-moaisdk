--[[
    FILE: ExeRigidBody.lua
    DESCRIPTION: 
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 08-10-13
]]

local json = require ("executor/libs/dkjson")

local ExeRigidBody = {}
ExeRigidBody.__index = ExeRigidBody

setmetatable(ExeRigidBody, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function ExeRigidBody.new(args)
    local self = setmetatable({}, ExeRigidBody)
    
    self.name = args.name
    
    local textfile = io.input("data/bodies/"..args.filename):read()
    local bodyfile = json.decode(textfile, 1, nil)
    print(bodyfile)
    --[[self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.STATIC )
    self.body:setTransform(args.x,args.y)
    
    body_fixture = self.body:addChain( args.points )
    body_fixture:setFriction(args.friction)
    body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
    ]]
    --floorFixture:setFilter ( 0x02 )
    --floorFixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
    
    --[[texture = MOAIGfxQuad2D.new ()
    texture:setTexture ( 'moai.png' )
    texture:setRect ( -0.5, -0.5, 0.5, 0.5 )
    
    sprite = MOAIProp2D.new ()
    sprite:setDeck ( texture )
    sprite.body = self.body
    sprite:setParent ( self.body )
    map.layer:insertProp ( sprite )]]
    
    --self.body.entity = self
    
    return self
end

function ExeRigidBody:destroy()
    --self.body:destroy()
    --ExeMap.layer:removeProp ( self.sprite )
    --self.sprite = nil
end

return ExeRigidBody
