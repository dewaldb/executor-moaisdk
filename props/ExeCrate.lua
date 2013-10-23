--[[
  FILE: ExeCrate.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
]]

local ExeCrate = {}
ExeCrate.__index = ExeCrate

setmetatable(ExeCrate, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeCrate.new(args)
  local self = setmetatable({}, ExeCrate)
  
  self.name = args.name
  
  self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.DYNAMIC )
  self.body:setTransform(args.x,args.y)
  
  local poly = {
		-0.5, -0.5,
		0.5, -0.5,
		0.5, 0.5,
		-0.5, 0.5,
	}
	body_fixture = self.body:addPolygon ( poly )
  body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  body_fixture:setFriction(1)
  body_fixture:setDensity ( 5 )
  
  self.body:resetMassData ()
  
  texture = MOAIGfxQuad2D.new ()
  texture:setTexture ( 'moai.png' )
  texture:setRect ( -0.5, -0.5, 0.5, 0.5 )
  
  self.sprite = MOAIProp2D.new ()
  self.sprite:setDeck ( texture )
  self.sprite.body = self.body
  self.sprite:setParent ( self.body )
  ExeGame.layer:insertProp ( self.sprite )
  
  self.body.entity = self
  
  return self
end

function ExeCrate:destroy()
  self.body:destroy()
  ExeGame.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeCrate