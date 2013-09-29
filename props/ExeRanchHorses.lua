--[[
  FILE: ExeRanchHorses.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 30-08-13
]]

local ExeRanchHorses = {}
ExeRanchHorses.__index = ExeRanchHorses

setmetatable(ExeRanchHorses, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRanchHorses.new(args)
  local self = setmetatable({}, ExeRanchHorses)
  
  self.name = args.name
  
  self.horse1 = ExeRanchHorse.new({
    name = "Horse1",
    x=0,
    y=-1
  })
  
  -- movement thread
  self.thread = MOAIThread.new()
  self.thread:run( function()
    while true do
      if ExeInput.buttons[1] then
        self:mouseLeftClicked()
      end
      
      local dx, dy = self.horse1.body:getLinearVelocity()
      local horsex, horsey = self.horse1.body:getPosition()
      local camx, camy = ExeMap.camera:getLoc()
      
      local goal_angle = 0
      if self.horse1.goal ~= nil then
        goal_angle = math.min(0.5,math.max(-0.5,self.horse1.goal.h))
      end
      
      local bodyAngle = self.horse1.body:getAngle() * DEGTORAD
      local nextAngle = bodyAngle + self.horse1.body:getAngularVelocity() / 60.0
      local totalRotation = goal_angle - nextAngle
      while totalRotation < -180 * DEGTORAD do
        totalRotation = totalRotation + 360 * DEGTORAD
      end
      while totalRotation >  180 * DEGTORAD do
        totalRotation = totalRotation - 360 * DEGTORAD
      end
      local desiredAngularVelocity = totalRotation * 60
      local change = 5 * DEGTORAD; -- allow 1 degree rotation per time step
      desiredAngularVelocity = math.min( change, math.max(-change, desiredAngularVelocity))
      local impulse = self.horse1.body:getInertia() * desiredAngularVelocity
      self.horse1.body:applyAngularImpulse( impulse )
      
      if self.horse1.goal ~= nil then
        if self.horse1.start_time ~= 0 then
          local duration = os.time() - self.horse1.start_time
          if duration < self.horse1.move_time then
            dx = dx - (math.sin(self.horse1.goal.h)*(0.075*math.min(2,self.horse1.goal.d)))
            dy = dy + (math.cos(self.horse1.goal.h)*(0.075*math.min(2,self.horse1.goal.d)))
          else
            self.horse1.start_time = 0
            self.horse1.goal = nil
          end
        end
      end
      
      dy = dy + (((camy-horsey)*0.005)+0.05) -- add minimum forward speed
      
      -- apply velocity changes
      self.horse1.body:setLinearVelocity( dx, dy )
      
      coroutine.yield()
    end
  end )
  
  return self
end

function ExeRanchHorses:destroy()
  --self.thread:stop()
  --self.thread = nil
  self.horse1:destroy()
  --ExeMap.layer:removeProp ( self.sprite )
  --self.sprite = nil
end

function ExeRanchHorses:mouseLeftClicked()
  self.horse1.start_time = os.time()
  
  local mx,my = ExeMap.layer:wndToWorld(ExeInput.mousePos.x,ExeInput.mousePos.y)
  -- the goal is a relavant value
  local bodyX,bodyY = self.horse1.body:getPosition()
  self.horse1.goal = {x=mx-bodyX,y=my-bodyY,h=0,d=math.abs(DISTANCE(mx,my,bodyX,bodyY))}
  
  local bodyAngle = self.horse1.body:getAngle() * DEGTORAD
  local goal = {x=bodyX+self.horse1.goal.x,y=bodyY+self.horse1.goal.y}
  
  local toTarget = {x=goal.x - bodyX, y=goal.y - bodyY}
  self.horse1.goal.h = math.atan2( -toTarget.x, toTarget.y )
end

return ExeRanchHorses