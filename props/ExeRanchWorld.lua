--[[
  FILE: ExeRanchWalls.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 30-08-13
]]

local ExeRanchWorld = {}
ExeRanchWorld.__index = ExeRanchWorld

setmetatable(ExeRanchWorld, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRanchWorld.new(args)
  local self = setmetatable({}, ExeRanchWalls)
  
  self.name = args.name
  self.spawn_dist = 1
  self.middle_rnd_spawn = 0.75 -- greater = spawn less
  self.sides_rnd_spawn = 0.2
  self.walls_rnd_spawn = 0.3
  self.middle_dist = 4
  self.sides_dist = 5 + self.middle_dist
  self.walls_dist = 5 + self.sides_dist
  self.last_spawn = 0
  self.obstacles = {}
  self.start_time = os.time()
  self.prev_camx, self.prev_camy = ExeMap.camera:getLoc()
  self.distance_traveled = 0
  self.current_speed = 0
  self.last_frame = os.clock()
  
  math.randomseed(os.time())
  math.random()
  
  -- Create a 4x4 grid of 64x64px squares
  self.grid = MOAIGrid.new()
  self.grid:initRectGrid(4, 4, 16, 16)
  self.grid:setRow(1, 1, 1, 1, 1)
  self.grid:setRow(2, 1, 1, 1, 1)
  self.grid:setRow(3, 1, 1, 1, 1)
  self.grid:setRow(4, 1, 1, 1, 1)
  
  -- Load the image file
  self.deck = MOAITileDeck2D.new()
  self.deck:setTexture("resources/tiles/sand02.png")
  self.deck:setSize(1, 1)
  
  -- Make a prop with that grid and image set
  self.prop = MOAIProp2D.new()
  self.prop:setDeck(self.deck)
  self.prop:setGrid(self.grid)
  self.prop:setLoc(-32, -32)
  
  --ExeMap.layer:insertProp(self.prop)
  
  -- thread
  self.thread = MOAIThread.new()
  self.thread:run( function()
    while true do
      local camx, camy = ExeMap.camera:getLoc()
      
      -- calc total distance traveled
      self.distance_traveled = self.distance_traveled + DISTANCE(self.prev_camx, self.prev_camy, camx, camy)
      -- calc current speed
      if self.last_frame ~= os.clock() then
        --print(DISTANCE(self.prev_camx, self.prev_camy, camx, camy))
        self.current_speed = DISTANCE(self.prev_camx, self.prev_camy, camx, camy)/(os.clock() - self.last_frame)
        self.last_frame = os.clock()
      end
      
      self.prev_camx = camx
      self.prev_camy = camy
      
      blockx = math.floor(camx/16)*16
      blocky = math.floor(camy/16)*16
      self.prop:setLoc(blockx-32, blocky-32)
      
      if self.last_spawn+self.spawn_dist < camy and math.random(0,1) == 1 then
        --print(#self.obstacles)
        -- lets remove past obstacles
        for i,val in pairs(self.obstacles) do
          local posx, posy = val.body:getPosition()
          --print("NUM:"..i.."POSY:"..(posy-camy))
          if (posy-camy) < -15 then
            self.obstacles[i]:destroy()
            self.obstacles[i] = nil
          end
        end
        
        -- spawn a new obstacle center
        self.last_spawn = camy
        if math.random() > self.middle_rnd_spawn then
          local x = math.random(-self.middle_dist,self.middle_dist)
          table.insert(
            self.obstacles,
            ExeRock.new({
              x = camx+x,
              y = camy+14+(math.random(-1,1)),
              size = math.abs(x*0.2),
              friction = 0
            })
          )
        end
        
        -- spawn a new obstacle left
        if math.random() > self.sides_rnd_spawn then
          local x = math.random(-self.sides_dist,-self.middle_dist)
          table.insert(
            self.obstacles,
            ExeRock.new({
              x = camx+x,
              y = camy+14+(math.random(-1,1)),
              size = math.abs(x*0.2),
              friction = 0
            })
          )
        end
        
        -- spawn a new obstacle left
        if math.random() > self.walls_rnd_spawn then
          local x = math.random(-self.walls_dist,-self.sides_dist)
          table.insert(
            self.obstacles,
            ExeRock.new({
              x = camx+x,
              y = camy+16+(math.random(-1,1)),
              size = math.abs(x*0.275),
              friction = 0
            })
          )
        end
        
        -- spawn a new obstacle right
        if math.random() > self.sides_rnd_spawn then
          local x = math.random(self.middle_dist,self.sides_dist)
          table.insert(
            self.obstacles,
            ExeRock.new({
              x = camx+x,
              y = camy+14+(math.random(-1,1)),
              size = math.abs(x*0.2),
              friction = 0
            })
          )
        end
        
        -- spawn a new obstacle right
        if math.random() > self.walls_rnd_spawn then
          local x = math.random(self.sides_dist,self.walls_dist)
          table.insert(
            self.obstacles,
            ExeRock.new({
              x = camx+x,
              y = camy+16+(math.random(-1,1)),
              size = math.abs(x*0.275),
              friction = 0
            })
          )
        end
      end
      
      if widgets.variousLblTime ~= nil then
        local label = widgets.variousLblTime.window
        label:setText("Time: "..(os.time()-self.start_time))
      end
      
      if widgets.variousLblDistance ~= nil then
        local label = widgets.variousLblDistance.window
        label:setText("Distance: "..(math.floor(self.distance_traveled)))
      end
      
      if widgets.variousLblSpeed ~= nil then
        local label = widgets.variousLblSpeed.window
        label:setText("Avg. Speed: "..(math.round(self.distance_traveled/math.max(1,(os.time()-self.start_time)),1)).."m/s Speed: "..math.round(self.current_speed,1).."m/s")
      end
      
      coroutine.yield()
    end
  end )
  
  return self
end

function ExeRanchWorld:destroy()
  self.thread:stop()
  self.thread = nil
end

return ExeRanchWorld