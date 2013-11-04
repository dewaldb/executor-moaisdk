--[[
  FILE: ExeAnimSprite.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 28-08-13
]]

local ExeAnimSprite = {}
ExeAnimSprite.__index = ExeAnimSprite

setmetatable(ExeAnimSprite, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  args = {
    frame_count = 17,
    frame_rate = 0.05,
    mode = MOAITimer.LOOP,
    texture = "resources/sprites/player/nordik.png",
    size = { 40,40 },
    rect_size = { -1, -1, 1, 1 }
  }
]]
function ExeAnimSprite.new(host,args)
  local self = setmetatable({}, ExeAnimSprite)
  
  self.frame_count = args.frame_count
  self.frame_rate = args.frame_rate
  self.mode = args.mode
  self.host = host
  self.end_span_callback = nil
  
  local tileLib = MOAITileDeck2D.new ()
  tileLib:setTexture ( "resources/sprites/player/nordik.png" )
  tileLib:setSize ( args.size[1], args.size[2] )
  tileLib:setRect ( args.rect_size[1], args.rect_size[2], args.rect_size[3], args.rect_size[4] )

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( tileLib )
  ExeGame.layer:insertProp ( self.prop ) -- won't allow animated sprites on any other layers, BAD!

  self.curve = MOAIAnimCurve.new ()

  self.anim = MOAIAnim:new ()
  self.anim.host = self
  self.anim:reserveLinks ( 1 )
  self.anim:start ()
  
  return self
end

--[[
args = {set number, frame rate, play mode}
]]
function ExeAnimSprite:play(args)
  local num = args.num
  local rate = args.rate or self.frame_rate
  local mode = args.mode or self.mode
  
  if args.end_span ~= nil then
    self.end_span_callback = args.end_span
    self.anim:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, self.endSpan )
  else
    self.anim:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, nil )
  end
  
  self.curve:reserveKeys (self.frame_count)
  for i = 1, self.frame_count do
    self.curve:setKey(i, rate * (i - 1), ((num-1)*self.frame_count)+i, MOAIEaseType.FLAT )
  end
  self.anim:setMode( mode )
  self.anim:setLink( 1, self.curve, self.prop, MOAIProp2D.ATTR_INDEX )
  self.anim:start()
end

function ExeAnimSprite:stop()
  self.anim:stop()
end

function ExeAnimSprite.endSpan(self,i)
  self.host.end_span_callback(self.host.host,i)
end

function ExeAnimSprite:destroy()
  self.anim:stop()
  self.anim = nil
  self.curve = nil
  ExeGame.layer:removeProp ( self.prop )
  self.prop = nil
end

return ExeAnimSprite

