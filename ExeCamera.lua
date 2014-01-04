--[[
  FILE: ExeCamera.lua
	DESCRIPTION: Handles the Camera and CameraFitter
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
  
  http://lua-users.org/wiki/ObjectOrientationTutorial
]]

local ExeCamera = {}
ExeCamera.__index = ExeCamera

setmetatable(ExeCamera, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeCamera.new(speed)
    local self = setmetatable({}, ExeCamera)
    
    self.camera = MOAICamera2D.new ()
    for i,val in pairs(ExeGame.layers) do
        val:setCamera ( self.camera )
    end
    
    self.fitter = MOAICameraFitter2D.new ()
    self.fitter:setViewport ( ExeGame.viewport )
    self.fitter:setCamera ( self.camera )
    self.fitter:setFitScale ( worldScale )
    self.fitter:setFitMode ( MOAICameraFitter2D.FITTING_MODE_SEEK_SCALE )
    self.fitter:setMin ( worldScale )
    self.fitter:setDamper( speed )
    
    return self
end

function ExeCamera:addAnchor(object)
  local anchor = MOAICameraAnchor2D.new ()
  anchor:setParent ( object )
  anchor:setRect(-(screenWidth/2)/worldScale,-(screenHeight/2)/worldScale,(screenWidth/2)/worldScale,(screenHeight/2)/worldScale)
  self.fitter:insertAnchor ( anchor )
  self.fitter:start ()
  
  return anchor
end

function ExeCamera:removeAnchor(anchor)
  self.fitter:removeAnchor(anchor)
end

function ExeCamera:clearAnchors()
  self.fitter:clearAnchors()
  
  self.fitter:setViewport ( ExeGame.viewport )
  self.fitter:setCamera ( self.camera )
end

function ExeCamera:setLoc(x,y)
  self.camera:setLoc(x,y)
end

function ExeCamera:getLoc()
  return self.camera:getLoc()
end

return ExeCamera