--[[
  FILE: ExeRanchCows.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 30-08-13
]]

local ExeRanchCows = {}
ExeRanchCows.__index = ExeRanchCows

setmetatable(ExeRanchCows, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRanchCows.new(args)
  local self = setmetatable({}, ExeRanchCows)
  
  self.name = args.name
  self.cow_dies_after = 10 -- kill a cow after it has been standing still for this amount of seconds
  self.start_cows_count = 10
  self.cows_count = self.start_cows_count
  self.lost_cows_count = 0
  self.dead_cows_count = 0
  self.cows_health = 0
  self.cows = {}
  self.lost_cows = {}
  self.dead_cows = {}
  self.start_time = os.clock()
  self.largest_herd = 0
  
  for i = 1,self.cows_count do
    table.insert(
      self.cows,
      ExeRanchCow.new({
        name="cow_"..i,
        x=args.x,
        y=args.y
      })
    )
  end
  
  -- movement thread
  self.thread = MOAIThread.new()
  self.thread:run( function()
    while true do
      self.cows_health = 0
      self.largest_herd = 0
      for i,cow in pairs(self.cows) do
        if cow.health > 0 then
          self.cows_health = self.cows_health + cow.health
          if cow.herd_size > self.largest_herd then
            self.largest_herd = cow.herd_size
          end
          
          local dx, dy = cow.body:getLinearVelocity()
          local cowx, cowy = cow.body:getPosition()
          local camx, camy = ExeMap.camera:getLoc()
          
          if cow.prev_pos ~= nil then
            -- get the calculated velocity
            if cow.stand_start_time == nil then
              if math.abs(DISTANCE(cow.prev_pos.x,cow.prev_pos.y,cowx,cowy)) < 0.001 and 
                  math.abs(DISTANCE(camx,camy,cowx,cowy)) > 12 then
                --print("Cow Moved: "..DISTANCE(cow.prev_pos.x,cow.prev_pos.y,cowx,cowy))
                cow.stand_start_time = os.time()
              else
                cow.stand_start_time = nil
              end
            end
          end
          cow.prev_pos = {x=cowx,y=cowy}
          
          -- rotate towards front, should have a checkpoint-type heading indicator on a path in a map
          local bodyAngle = cow.body:getAngle() * DEGTORAD
          local nextAngle = bodyAngle + cow.body:getAngularVelocity() / 60.0
          local totalRotation = 0 - nextAngle
          while totalRotation < -180 * DEGTORAD do
            totalRotation = totalRotation + 360 * DEGTORAD
          end
          while totalRotation >  180 * DEGTORAD do
            totalRotation = totalRotation - 360 * DEGTORAD
          end
          local desiredAngularVelocity = totalRotation * 60
          local change = 10 * DEGTORAD; -- allow 2 degree rotation per time step
          desiredAngularVelocity = math.min( change, math.max(-change, desiredAngularVelocity))
          local impulse = cow.body:getInertia() * desiredAngularVelocity
          cow.body:applyAngularImpulse( impulse )
          
          for j,fixture in pairs(cow.sense_list) do
            --print ("sensed")
            local entity = fixture:getBody().entity
            if entity ~= nil then
              if entity.horse == true then
                -- if it is a horse have him "push" the cow away from him
                local horsex, horsey = entity.body:getPosition()
                dx = dx - (math.sin((horsex-cowx)) * 0.15)
                dy = dy - (math.sin((horsey-cowy)) * 0.15)
              end
              if entity.cow == nil and entity.horse == nil then
                -- if it is something else, "push" the cow away from it
                local otherx, othery = entity.body:getPosition()
                dx = dx - (math.sin((otherx-cowx)) * 0.035)
                dy = dy - (math.sin((othery-cowy)) * 0.035)
              end
              if entity.cow == true then
                -- if it is a cow have him "pull" another cow towards himself
                local cow2x, cow2y = entity.body:getPosition()
                dx = dx + (math.sin((cow2x-cowx)) * 0.001)
                dy = dy + (math.sin((cow2y-cowy)) * 0.001)
              end
            end
          end
          
          --dx = dx + (((camx-cowx)*0.0025)) -- move towards x center of screen
          dy = dy + (((camy-cowy)*0.005)+0.05+(0.01*(cow.herd_size+1))) -- add minimum forward speed
          
          -- apply velocity changes
          cow.body:setLinearVelocity( dx, dy )
          
          if cow.stand_start_time ~= nil then
            if math.abs(DISTANCE(cow.prev_pos.x,cow.prev_pos.y,cowx,cowy)) > 0.001 and 
                  math.abs(DISTANCE(camx,camy,cowx,cowy)) < 12 then
                --print("Cow Moved: "..DISTANCE(cow.prev_pos.x,cow.prev_pos.y,cowx,cowy))
                cow.stand_start_time = nil
            elseif cow.stand_start_time + self.cow_dies_after < os.time() then
              -- the cow is lost
              cow:removeCameraAnchor()
              table.insert(self.lost_cows,cow)
              self.cows_count = self.cows_count - 1
              self.lost_cows_count = self.lost_cows_count + 1
              self.cows[i] = nil
            end
          end
        else
          -- the cow is dead
          cow:removeCameraAnchor()
          table.insert(self.dead_cows,cow)
          self.cows_count = self.cows_count - 1
          self.dead_cows_count = self.dead_cows_count + 1
          self.cows[i] = nil
        end
      end
      
      if widgets.variousLblHealth ~= nil then
        local label = widgets.variousLblHealth.window
        label:setText("Overall Health: "..math.ceil(self.cows_health/self.start_cows_count))
      end
      
      if widgets.variousLblCows ~= nil then
        local label = widgets.variousLblCows.window
        label:setText(
          "Cows - Live: "..(self.cows_count)..
          " Lost: "..(self.lost_cows_count)..
          " Dead: "..(self.dead_cows_count)..
          " Largest Herd: "..(self.largest_herd+1))
      end
      
      coroutine.yield()
    end
  end )
  
  return self
end

function ExeRanchCows:destroy()
  self.thread:stop()
  self.thread = nil
  for i,cow in pairs(self.cows) do
    cow:destroy()
    self.cows[i] = nil
  end
  for i,cow in pairs(self.dead_cows) do
    cow:destroy()
    self.dead_cows[i] = nil
  end
end

return ExeRanchCows