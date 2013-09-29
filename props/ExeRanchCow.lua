--[[
  FILE: ExeRanchCow.lua
	DESCRIPTION: 
	AUTHOR: Dewald Bodenstein
	VERSION: 0.2
	MOAI VERSION: v1.4p0
	CREATED: 30-08-13
]]

local ExeRanchCow = {}
ExeRanchCow.__index = ExeRanchCow

setmetatable(ExeRanchCow, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeRanchCow.new(args)
  local self = setmetatable({}, ExeRanchCow)
  
  self.name = args.name
  self.health = 100
  self.cow = true
  self.sense_list = {}
  self.stand_start_time = nil
  self.prev_pos = nil
  self.herd = {}
  self.herd_size = 0
  
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
  body_fixture:setFriction(0.25)
  body_fixture:setRestitution(0.2)
  body_fixture:setDensity ( 5 )
  body_fixture:setCollisionHandler ( ExeRanchCow.onCollide, MOAIBox2DArbiter.ALL )
  
  local sensor_fixture = self.body:addCircle ( 0,0,3 )
  sensor_fixture:setSensor(true)
  sensor_fixture:setCollisionHandler ( ExeRanchCow.onSensorCollide, MOAIBox2DArbiter.ALL )
  
  self.body:resetMassData ()
  
  local texture = MOAIGfxQuad2D.new ()
  texture:setTexture ( 'resources/sprites/cow.png' )
  texture:setRect ( -0.75, -0.75, 0.75, 0.75 )
  
  self.sprite = MOAIProp2D.new ()
  self.sprite:setDeck ( texture )
  self.sprite.body = self.body
  self.sprite:setParent ( self.body )
  ExeMap.layer:insertProp ( self.sprite )
  
  self.body.entity = self
  
  self:addCameraAnchor()
  
  return self
end

function ExeRanchCow:addCameraAnchor()
  self.anchor = ExeMap.camera:addAnchor(self.body)
end

function ExeRanchCow:removeCameraAnchor()
  if self.anchor ~= nil then
    ExeMap.camera:removeAnchor(self.anchor)
    self.anchor = nil
  end
end

function ExeRanchCow:destroy()
  self.body:destroy()
  ExeMap.layer:removeProp ( self.sprite )
  self.sprite = nil
end

function ExeRanchCow.senseBegin(self,fixture)
  table.insert(self.sense_list, 1, fixture)
end

function ExeRanchCow.senseEnd(self,fixture)
  for i,v in pairs(self.sense_list) do
    if v == fixture then
      table.remove(self.sense_list,i)
      break
    end
  end
end

function ExeRanchCow.collideBegin(self,fixture)
  local other = fixture:getBody().entity
  if other.cow == nil then
    --local x,y = arbiter:getContactNormal()
    --print("Bump: "..x.."x"..y)
    local fixax, fixay = self.body:getLinearVelocity()
    local fixbx, fixby = other.body:getLinearVelocity()
    --print("Velocity: "..math.sin(DISTANCE(fixax,fixay,fixbx,fixby)).." - "..(fixax+fixbx).."x"..(fixay+fixby))
    self.health = self.health - math.max(0,(math.sin(math.abs(DISTANCE(fixax,fixay,fixbx,fixby)))*0.65)-0.01)
    print(self.health)
  else
    -- add the colliding cow to my herd
    if self.herd[other.name] == nil then
      self.herd[other.name] = other
      self.herd_size = self.herd_size + 1
    end
  end
end

function ExeRanchCow.collideEnd(self,fixture)
  local other = fixture:getBody().entity
  if other.cow == true then
    if self.herd[other.name] ~= nil then
      self.herd[other.name] = nil
      self.herd_size = self.herd_size - 1
    end
  end
end

function ExeRanchCow.onCollide(phase, fix_a, fix_b, arbiter)
  if phase == MOAIBox2DArbiter.BEGIN then
    if fix_a:getBody().entity ~= nil and fix_b:getBody().entity ~= nil then
      if fix_a:getBody().entity.cow == true then
        ExeRanchCow.collideBegin(fix_a:getBody().entity,fix_b)
      end
      if fix_b:getBody().entity.cow == true then
        ExeRanchCow.collideBegin(fix_b:getBody().entity,fix_a)
      end
    end
	end
	if phase == MOAIBox2DArbiter.END then
    if fix_a:getBody().entity ~= nil and fix_b:getBody().entity ~= nil then
      if fix_a:getBody().entity.cow == true then
        ExeRanchCow.collideEnd(fix_a:getBody().entity,fix_b)
      end
      if fix_b:getBody().entity.cow == true then
        ExeRanchCow.collideEnd(fix_b:getBody().entity,fix_a)
      end
    end
	end
end

function ExeRanchCow.onSensorCollide(phase, fix_a, fix_b, arbiter)
  if phase == MOAIBox2DArbiter.BEGIN then
    if fix_a:getBody().entity ~= nil and fix_b:getBody().entity ~= nil then
      if fix_a:getBody().entity.cow == true then
        fix_a:getBody().entity.senseBegin(fix_a:getBody().entity,fix_b)
      end
      if fix_b:getBody().entity.cow == true then
        fix_b:getBody().entity.senseBegin(fix_b:getBody().entity,fix_a)
      end
    end
	end
	if phase == MOAIBox2DArbiter.END then
    if fix_a:getBody().entity ~= nil and fix_b:getBody().entity ~= nil then
      if fix_a:getBody().entity.cow == true and fix_b:getBody().entity.cow == nil then
        fix_a:getBody().entity.senseEnd(fix_a:getBody().entity,fix_b)
      end
      if fix_b:getBody().entity.cow == true and fix_a:getBody().entity.cow == nil then
        fix_b:getBody().entity.senseEnd(fix_b:getBody().entity,fix_a)
      end
    end
	end
end

return ExeRanchCow