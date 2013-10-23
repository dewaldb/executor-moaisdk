--[[
    FILE: ExeRigidBody.lua
    DESCRIPTION: 
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 08-10-13
]]

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
    
    local rigid_body = ExeMap.rigidBodies[args.rigid_body]
    
    self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.DYNAMIC )
    self.body:setTransform(args.x,args.y)
    
    local body_fixture = nil
    
    --if rigid_body["polygons"] then
    --    local body_fixture = self.body:addChain( args.points )
    --end
    
    if rigid_body["circles"] then
        for i,circle in ipairs(rigid_body["circles"]) do
            body_fixture = self.body:addCircle ( circle.cx, circle.cy, circle.r )
        end
    end
    
    if args.friction then
        body_fixture:setFriction(args.friction)
    end
    
    body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
    
    --floorFixture:setFilter ( 0x02 )
    --floorFixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
    
    local texture = MOAIGfxQuad2D.new ()
    texture:setTexture ( string.gsub(rigid_body["imagePath"],"../","") ) -- remove relative paths added by physics-body-editor
    texture:setRect ( 0, 0, 1, 1 )
    
    local sprite = MOAIProp2D.new ()
    sprite:setDeck ( texture )
    sprite.body = self.body
    sprite:setParent ( self.body )
    ExeGame.layer:insertProp ( sprite )
    
    self.body.entity = self
    
    return self
end

function ExeRigidBody:destroy()
    --self.body:destroy()
    --ExeGame.layer:removeProp ( self.sprite )
    --self.sprite = nil
end

return ExeRigidBody
