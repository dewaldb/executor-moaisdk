--[[
    FILE: ExeEditorPoint.lua
    DESCRIPTION: 
    AUTHOR: Dewald Bodenstein
    VERSION: 0.2
    MOAI VERSION: v1.4p0
    CREATED: 16-08-13
]]

local ExeEditorPoint = {}
ExeEditorPoint.__index = ExeEditorPoint

setmetatable(ExeEditorPoint, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function ExeEditorPoint.new(args)
    local self = setmetatable({}, ExeEditorPoint)
    
    self.name = args.name
    
    self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.DYNAMIC )
    self.body:setTransform(args.x,args.y)
    
    body_fixture = self.body:addCircle ( 0, 0, 0.25 )
    body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
    body_fixture:setFriction(1)
    body_fixture:setDensity(5)
    
    self.body:resetMassData ()
    self.body:setAngularDamping(1000)
    self.body:setLinearDamping(1000)
    
    self.texture = MOAIGfxQuad2D.new ()
    self.texture:setTexture ( 'resources/sprites/editor/point.png' )
    self.texture:setRect ( -0.25, -0.25, 0.25, 0.25 )
    
    self.sprite = MOAIProp2D.new ()
    self.sprite:setDeck ( self.texture )
    self.sprite.body = self.body
    self.sprite:setParent ( self.body )
    ExeMap.layer:insertProp ( self.sprite )
    
    self.body.entity = self
    
    return self
end

function ExeEditorPoint:destroy()
  self.body:destroy()
  ExeMap.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeEditorPoint