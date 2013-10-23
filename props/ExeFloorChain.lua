--[[
  FILE: ExeFloorChain.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
]]

local ExeFloorChain = {}
ExeFloorChain.__index = ExeFloorChain

setmetatable(ExeFloorChain, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeFloorChain.new(args)
    local self = setmetatable({}, ExeFloorChain)

    self.name = args.name

    self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.STATIC )
    self.body:setTransform(args.x,args.y)
    
    local body_fixture = self.body:addChain( args.points )
    body_fixture:setFriction(args.friction)
    body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
    
    --floorFixture:setFilter ( 0x02 )
    --floorFixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
    
    local texture = MOAIGfxQuad2D.new ()
    texture:setTexture ( args.filename )
    texture:setRect ( -(args.width/2)/worldScale, -(args.height/2)/worldScale, (args.width/2)/worldScale, (args.height/2)/worldScale )
    
    self.sprite = MOAIProp2D.new ()
    self.sprite:setDeck ( texture )
    self.sprite.body = self.body
    self.sprite:setParent ( self.body )
    ExeGame.layer:insertProp ( self.sprite )
    
    self.body.entity = self
    
    return self
end

function ExeFloorChain:destroy()
  self.body:destroy()
  ExeGame.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeFloorChain