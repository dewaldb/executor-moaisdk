--[[
    FILE: ExeStaticConvex.lua
    DESCRIPTION: 
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 11-01-2014
]]

local ExeStaticConvex = {}
ExeStaticConvex.__index = ExeStaticConvex

setmetatable(ExeStaticConvex, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeStaticConvex.new(args)
    local self = setmetatable({}, ExeStaticConvex)
    
    self.name = args.name
    self.rot = args.rot
    self.scale = args.scale
    self.layer = args.layer
    
    if args.scale_random == true then
        self.scale = (math.random()*args.scale)+args.scale_min
    end
    
    if args.rot_random == true then
        self.rot = (math.random()*args.rot)+args.rot_min
    end

    --print (self.name.." Scale:"..self.scale)
    
    self.body = ExeMap.physWorld:addBody ( MOAIBox2DBody.STATIC )
    self.body:setTransform(args.x,args.y,self.rot)
    
    for i,item in ipairs(args.points) do
        args.points[i] = self.scale * args.points[i]
    end
    
    local body_fixture = self.body:addPolygon( args.points )
    body_fixture:setFriction(args.friction) -- 0 = slide, 1 = full friction
    body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
    if args.friction then
        body_fixture:setFriction(args.friction)
    end
    
    local image = MOAIImage.new()
    image:load(args.image, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA + MOAIImage.POW_TWO)
    local iw, ih = image:getSize()

    local texture = MOAIGfxQuad2D.new ()
    texture:setTexture ( image:copy() )
    texture:setRect ( -(self.scale*iw)/worldScale, -(self.scale*ih)/worldScale, (self.scale*iw)/worldScale, (self.scale*ih)/worldScale )
    
    self.sprite = MOAIProp2D.new ()
    self.sprite:setDeck ( texture )
    self.sprite.body = self.body
    self.sprite:setParent ( self.body )
    ExeGame.layers[self.layer]:insertProp ( self.sprite )
    
    self.body.entity = self
    
    return self
end

function ExeStaticConvex:destroy()
    self.body:destroy()
    ExeGame.layers[self.layer]:removeProp ( self.sprite )
    self.sprite = nil
end

return ExeStaticConvex