--[[
  FILE: ExeRanchHorse.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 30-08-13
]]

local ExeRanchHorse = {}
ExeRanchHorse.__index = ExeRanchHorse

setmetatable(ExeRanchHorse, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRanchHorse.new(args)
  local self = setmetatable({}, ExeRanchHorse)
  
  self.name = args.name
  self.horse = true
  
  self.goal = nil
  self.start_time = 0
  self.move_time = 1 -- 1 seconds
  
  self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.DYNAMIC )
  self.body:setTransform(args.x,args.y)
  self.body:setLinearDamping(2)
  self.body:setAngularDamping(2)
  
  local polygon = {}
  for i = 1,6 do
    local angle = -(i-1)/6.0 * 360 * DEGTORAD;
    polygon[((i-1)*2)+1] = math.sin(angle)/2
    polygon[((i-1)*2)+2] = math.cos(angle)/2
  end
  polygon[1] = 0
  polygon[2] = 1 --change one vertex to be pointy
  
	local body_fixture = self.body:addPolygon ( polygon )
  body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  body_fixture:setFriction(1)
  body_fixture:setDensity ( 5 )
  
  self.body:resetMassData ()
  
  texture = MOAIGfxQuad2D.new ()
  texture:setTexture ( 'resources/sprites/horse.png' )
  texture:setRect ( -0.35, -1.2, 0.35, 1.2 )
  
  self.sprite = MOAIProp2D.new ()
  self.sprite:setDeck ( texture )
  self.sprite.body = self.body
  self.sprite:setParent ( self.body )
  ExeMap.layer:insertProp ( self.sprite )
  
  self.body.entity = self
  
  ExeMap.camera:addAnchor(self.body)
  
  return self
end

function ExeRanchHorse:destroy()
  self.body:destroy()
  ExeMap.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeRanchHorse