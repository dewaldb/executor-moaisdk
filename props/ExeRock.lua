--[[
  FILE: ExeRock.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
]]

local ExeRock = {}
ExeRock.__index = ExeRock

setmetatable(ExeRock, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRock.new(args)
  local self = setmetatable({}, ExeRock)
  
  self.name = args.name
  self.size = (math.random()*args.size)+0.25
  
  self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.STATIC )
  self.body:setTransform(args.x,args.y,math.random(0,360))
  
  local polygon = {}
  for i = 1,6 do
    local angle = -(i-1)/6.0 * 360 * DEGTORAD;
    polygon[((i-1)*2)+1] = math.sin(angle)*(self.size)
    polygon[((i-1)*2)+2] = math.cos(angle)*(self.size)
  end
  
	body_fixture = self.body:addPolygon ( polygon )
  body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  if args.friction then
    body_fixture:setFriction(args.friction)
  end
  
  texture = MOAIGfxQuad2D.new ()
  texture:setTexture ( 'resources/sprites/rock'..(math.random(1,7))..'.png' )
  texture:setRect ( -self.size, -self.size, self.size, self.size )
  
  self.sprite = MOAIProp2D.new ()
  self.sprite:setDeck ( texture )
  self.sprite.body = self.body
  self.sprite:setParent ( self.body )
  ExeGame.layer:insertProp ( self.sprite )
  
  self.body.entity = self
  
  return self
end

function ExeRock:destroy()
  self.body:destroy()
  ExeGame.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeRock