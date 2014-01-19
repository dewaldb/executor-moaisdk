--[[
  FILE: ExeButton.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
]]

local ExeButton = {}
ExeButton.__index = ExeButton

setmetatable(ExeButton, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeButton.new(args)
  local self = setmetatable({}, ExeButton)
  
  self.name = args.name
  
  self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.STATIC )
  self.body:setTransform(args.x,args.y)
  
  body_fixture = self.body:addCircle ( 0,0, 0.5 )
  body_fixture:setSensor(true)
  body_fixture:setFilter(ExeMap.BOX2D_PROPS,ExeMap.BOX2D_SENSOR)
  
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
  
  math.randomseed(os.time())
  
  return self
end

function ExeButton:interact(entity)
  ExeMap.spawnEntity({class="ExeCrate",args={x=math.random(10)-5,y=math.random(10)-5}})
end

function ExeButton:destroy()
  self.body:destroy()
  ExeGame.layer:removeProp ( self.sprite )
  self.sprite = nil
end

return ExeButton