--[[
  FILE: ExePlayer.lua
	DESCRIPTION: Player
	AUTHOR: Dewald Bodenstein
	VERSION: 0.1
	MOAI VERSION: v1.4p0
	CREATED: 18-08-13
]]

local ExePlayer = {}
ExePlayer.__index = ExePlayer

setmetatable(ExePlayer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExePlayer.new(args)
  local self = setmetatable({}, ExePlayer)
  
  self.ANIMS = {
    --{set number, frame rate, frame count, play mode}
    Idle_Right = {num = 3},
    Idle_Left = {num = 4},
    Walk_Right = {num = 7},
    Walk_Left = {num = 8},
    Jump_Right = {num = 7, mode = MOAITimer.NORMAL, end_span = self.animEndSpan},
    Jump_Left = {num = 8, mode = MOAITimer.NORMAL, end_span = self.animEndSpan},
    Fall_Right = {num = 3},
    Fall_Left = {num = 4},
    Die = {num = 1, mode = MOAITimer.NORMAL}
  }
  
  self.name = "PLAYER"
  self.active = false
  self.on_ground = 0
  self.direction = 1
  self.walk_speed = 2.5
  self.run_speed = 5
  self.max_speed = self.walk_speed
  self.max_walk_velocity = 5
  self.max_run_velocity = 7.5
  self.speed = 0
  self.jump_force = 2.5
  self.max_walk_jump_velocity = 7.5
  self.max_run_jump_velocity = 15
  self.jumping = false
  self.anim = self.ANIMS.Idle_Left
  self.sense_list = {}
  
  self.keys = {right = 97, left = 100, interact = 101, jump = 32}
  
  self.player_body = ExeMap.physWorld:addBody ( MOAIBox2DBody.DYNAMIC )
  self.player_body:setTransform(args.x,args.y)
  self.player_body:setFixedRotation(true)
  
  local head_fixture = self.player_body:addCircle ( 0, 0.75, 0.75 )
  head_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  head_fixture:setDensity ( 5 )
  head_fixture:setFriction ( 0 )
  
  local legs_fixture = self.player_body:addCircle ( 0,-0.75, 0.75 )
  legs_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  legs_fixture:setDensity ( 5 )
  legs_fixture:setFriction ( 0 )
  
  local feet_fixture = self.player_body:addCircle ( 0,-0.787, 0.75 )
  feet_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  feet_fixture:setSensor(true)
  feet_fixture:setCollisionHandler ( ExePlayer.onCollide, MOAIBox2DArbiter.ALL )
  
  local sensor_fixture = self.player_body:addCircle ( 0,0, 1.5 )
  sensor_fixture:setFilter(ExeMap.BOX2D_SENSOR)
  sensor_fixture:setSensor(true)
  sensor_fixture:setCollisionHandler ( ExePlayer.onSensorCollide, MOAIBox2DArbiter.ALL, ExeMap.BOX2D_SENSOR )
  
  local body_fixture = self.player_body:addPolygon ( {-0.75, -0.75, 0.75, -0.75, 0.75, 0.75, -0.75, 0.75} )
  body_fixture:setFilter(ExeMap.BOX2D_WORLD,ExeMap.BOX2D_WORLD)
  body_fixture:setDensity ( 5 )
  body_fixture:setFriction ( 0 )
  
  self.player_body:resetMassData ()
  
  self.anim_sprite = ExeAnimSprite.new(self,{
    frame_count = 17,
    frame_rate = 0.05,
    mode = MOAITimer.LOOP,
    texture = "resources/sprites/player/nordik.png",
    size = { 17,9 },
    rect_size = { -1.75, -1.75, 1.75, 1.75 }
  })
  
  self.anim_sprite.prop.body = self.player_body
  self.anim_sprite.prop:setParent ( self.player_body )
  self:animPlay(self.anim)
  
  -- player movement thread
  self.thread = MOAIThread.new()
  self.thread:run( function()
    while true do
      -- handle movement
      if self.jumping == false then
        if ExeInput.keys[self.keys.right] then
          self.speed = (math.max(-self.max_speed,self.speed - 0.25))
        elseif ExeInput.keys[self.keys.left] then
          self.speed = (math.min(self.max_speed,self.speed + 0.25))
        else
          self.speed = self.speed * 0.5
        end
      end
      
      local dx, dy = self.player_body:getLinearVelocity()
      
      if self.on_ground <= 0 and self.jumping then
        dx = dx * 0.75
      else
        dx = dx * 0.5
      end
      
      dy = dy - 0.25
      
      --if self.on_ground > 0 then
        dx = dx+self.speed
      --end
      
      -- handle jumping
      if ExeInput.keys[self.keys.jump] and self.on_ground > 0 then
        self.jumping = true
        self:animStop()
        dy = math.min(self.max_walk_jump_velocity,dy + self.jump_force)
        dx = dx * 1.5
      end
      
      -- apply velocity changes
      self.player_body:setLinearVelocity( dx, dy )
      
      -- dicern direction
      if dx < -0.5 then
        self.direction = -1
      elseif dx > 0.5 then
        self.direction = 1
      end
      
      -- apply appropriate animation
      if self.on_ground > 0 then
        if dx < -0.5 then
          self:animPlay(self.ANIMS.Walk_Right)
        elseif dx > 0.5 then
          self:animPlay(self.ANIMS.Walk_Left)
        else
          if self.direction < 0 then
            self:animPlay(self.ANIMS.Idle_Right)
          elseif self.direction > 0 then
            self:animPlay(self.ANIMS.Idle_Left)
          end
        end
      else
        if self.jumping == true then
          if self.direction < 0 then
            self:animPlay(self.ANIMS.Jump_Right)
          elseif self.direction > 0 then
            self:animPlay(self.ANIMS.Jump_Left)
          end
        else
          if dx < -0.5 then
            self:animPlay(self.ANIMS.Fall_Right)
          elseif dx > 0.5 then
            self:animPlay(self.ANIMS.Fall_Left)
          else
            if self.direction < 0 then
              self:animPlay(self.ANIMS.Fall_Right)
            elseif self.direction > 0 then
              self:animPlay(self.ANIMS.Fall_Left)
            end
          end
        end
      end
      
      -- handle interaction
      if ExeInput.keys[self.keys.interact] then
        if table.getn(self.sense_list) > 0 then
          for i,obj in ipairs(self.sense_list) do
            if obj:getBody().entity ~= nil and obj:getBody().entity.interact ~=nil then
              obj:getBody().entity.interact(self)
              --print ("Interact with: " .. obj:getBody().entity.name)
              break
            end
          end
        end
      end
      
      coroutine.yield()
    end
  end )

  --self.keyEventHandle = ExeInput.addKeyboardEvent(function(key,down)
  --    print ("Pressed: " .. key)
  --end)
  
  self.player_body.entity = self
  ExeMap.player = self
  
  return self
end

function ExePlayer:animPlay(anim)
  self.anim = anim -- must be an anim in self.ANIMS
  self.anim_sprite:play(self.anim)
end

function ExePlayer:animStop()
  self.anim_sprite:stop()
end

function ExePlayer.animEndSpan(self, i)
  print ("END JUMP:"..self.name)
  self.jumping = false
end

function ExePlayer:deactivate(camera)
  self.active = false
  camera:removeAnchor(self.player_body)
end

function ExePlayer:activate(camera)
  self.active = true
  camera:addAnchor(self.player_body)
end

function ExePlayer.collisionBegin(self)
  local dx, dy = self.player_body:getLinearVelocity()
  self.player_body:setLinearVelocity( math.min(dx,self.max_walk_velocity), dy )
  
  self.on_ground = self.on_ground + 1
  self.jumping = false
end

function ExePlayer.collisionEnd(self)
  self.on_ground = self.on_ground - 1
end

function ExePlayer.onCollide(phase, fix_a, fix_b, arbiter)
  local name = "None"
  
  if phase == MOAIBox2DArbiter.BEGIN then
    if fix_a:getBody().entity ~= nil and fix_a:getBody().entity.name == "PLAYER" then
      fix_a:getBody().entity.collisionBegin(fix_a:getBody().entity)
      name = fix_a:getBody().entity.name
    end
    if fix_b:getBody().entity ~= nil and fix_b:getBody().entity.name == "PLAYER" then
      fix_b:getBody().entity.collisionBegin(fix_b:getBody().entity)
      name = fix_b:getBody().entity.name
    end
		print ( 'begin: ' .. name )
	end
	if phase == MOAIBox2DArbiter.END then
    if fix_a:getBody().entity ~= nil and fix_a:getBody().entity.name == "PLAYER" then
      fix_a:getBody().entity.collisionEnd(fix_a:getBody().entity)
      name = fix_a:getBody().entity.name
    end
    if fix_b:getBody().entity ~= nil and fix_b:getBody().entity.name == "PLAYER" then
      fix_b:getBody().entity.collisionEnd(fix_b:getBody().entity)
      name = fix_b:getBody().entity.name
    end
		print ( 'end: ' .. name )
	end
	if phase == MOAIBox2DArbiter.PRE_SOLVE then
		print ( 'pre!' )
	end
	if phase == MOAIBox2DArbiter.POST_SOLVE then
		print ( 'post!' )
	end
end

function ExePlayer.senseBegin(self,fixture)
  table.insert(self.sense_list, 1, fixture)
end

function ExePlayer.senseEnd(self,fixture)
  for i,v in pairs(self.sense_list) do
    if v == fixture then
      table.remove(self.sense_list,i)
      break
    end
  end
end

function ExePlayer.onSensorCollide(phase, fix_a, fix_b, arbiter)
  local name = "None"
  
  if phase == MOAIBox2DArbiter.BEGIN then
    if fix_a:getBody().entity ~= nil and fix_a:getBody().entity.name == "PLAYER" then
      fix_a:getBody().entity.senseBegin(fix_a:getBody().entity,fix_b)
      name = fix_a:getBody().entity.name
    end
    if fix_b:getBody().entity ~= nil and fix_b:getBody().entity.name == "PLAYER" then
      fix_b:getBody().entity.senseBegin(fix_b:getBody().entity,fix_a)
      name = fix_b:getBody().entity.name
    end
		print ( 'begin: ' .. name )
	end
	if phase == MOAIBox2DArbiter.END then
    if fix_a:getBody().entity ~= nil and fix_a:getBody().entity.name == "PLAYER" then
      fix_a:getBody().entity.senseEnd(fix_a:getBody().entity,fix_b)
      name = fix_a:getBody().entity.name
    end
    if fix_b:getBody().entity ~= nil and fix_b:getBody().entity.name == "PLAYER" then
      fix_b:getBody().entity.senseEnd(fix_b:getBody().entity,fix_a)
      name = fix_b:getBody().entity.name
    end
		print ( 'end: ' .. name )
	end
end

function ExePlayer:destroy()
  ExeInput.removeKeyboardEvent(self.keyEventHandle)
  self.thread:stop()
  self.thread = nil
  self.player_body:destroy()
  self.anim_sprite:destroy()
end

return ExePlayer