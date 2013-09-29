--[[
  FILE: ExeTimer.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 16-08-13
]]

local ExeTimer = {}
ExeTimer.__index = ExeTimer

setmetatable(ExeTimer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
args = {
  name
  timed_scripts = { - scripts to run at the specified times
    0 = script
    0.5 = script
  }
  auto_start - start the delay count down as soon as its been created
  delay - delay before the timer starts
}
]]
function ExeTimer.new(args)
  local self = setmetatable({}, ExeTimer)
  
  self.name = args.name
  self.timed_scripts = args.timed_scripts
  self.started = args.auto_start
  self.delay = args.delay
  self.start_time = os.time()
  
  self.thread = MOAIThread.new()
  self.thread:run(function()
    while true do
      if self.started == true then
        if os.time() >= self.start_time+self.delay then
          local cur_time = os.time()-(self.start_time+self.delay)
          if self.timed_scripts[cur_time] ~= nil then
            print("run the script at "..cur_time.." | "..self.timed_scripts[cur_time])
            self.timed_scripts[cur_time] = nil
          end
        end
      end
      
      coroutine.yield()
    end
  end)
  
  return self
end

function ExeTimer:start()
  self.started = true
  self.start_time = os.time()
end

function ExeTimer:destroy()
  self.thread:stop()
  self.thread = nil
end

return ExeTimer