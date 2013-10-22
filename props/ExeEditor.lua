--[[
    FILE: ExeEditor.lua
    DESCRIPTION: Editor controller object.
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 2013-10-10
]]

local ExeEditor = {}
ExeEditor.__index = ExeEditor

setmetatable(ExeEditor, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ExeEditor.new()
    local self = setmetatable({}, ExeEditor)
    
    print('Editor Created')
    
    self.max_speed = 2.5
    self.speed_lfrt = 0
    self.speed_updn = 0
    self.keys = {right = 97, left = 100, up = 119, down = 115}

    self.dragged = nil
    self.dragMouseJoint = nil
    self.dragMouseBody = nil
    self.mouseWorldX, self.mouseWorldY = 0

    -- add the sprite to draw a chain for:
    local ent_texture = MOAIGfxQuad2D.new ()
    ent_texture:setTexture ( 'resources/sprites/map5.png' )
    ent_texture:setRect ( -4096/worldScale, -256/worldScale, 4096/worldScale, 256/worldScale )

    self.ent_sprite = MOAIProp2D.new ()
    self.ent_sprite:setDeck ( ent_texture )
    ExeMap.layer:insertProp ( self.ent_sprite )
    
    local texture = MOAIGfxQuad2D.new ()
    texture:setTexture ( 'moai.png' )
    texture:setRect ( -0.5, -0.5, 0.5, 0.5 )

    self.sprite = MOAIProp2D.new ()
    self.sprite:setDeck ( texture )
    ExeMap.layer:insertProp ( self.sprite )
    
    ExeEditor.points_chain = ExeMap.spawnEntity("ExeEditorPointsChain",{x=0,y=0,name="points chain"})
    
    ExeInput.addPointerEvent(self.pointerCallback,self)
    ExeInput.addMouseLeftEvent(self.leftClickCallback,self)
    ExeInput.addMouseRightEvent(self.rightClickCallback,self)
    
    if (nil ~= widgets.editorBtnSave) then
	local button = widgets.editorBtnSave.window
	button:registerEventHandler(button.EVENT_BUTTON_CLICK, nil, ExeEditor.save)
    end
    
    -- editor control thread
    self.thread = MOAIThread.new()
    self.thread:run( function()
        while true do
            if ExeInput.keys[self.keys.right] then
                self.speed_lfrt = (math.max(-self.max_speed,self.speed_lfrt - 0.01))
            elseif ExeInput.keys[self.keys.left] then
                self.speed_lfrt = (math.min(self.max_speed,self.speed_lfrt + 0.01))
            else
                self.speed_lfrt = self.speed_lfrt * 0.5
            end

            if ExeInput.keys[self.keys.up] then
                self.speed_updn = (math.max(-self.max_speed,self.speed_updn + 0.01))
            elseif ExeInput.keys[self.keys.down] then
                self.speed_updn = (math.min(self.max_speed,self.speed_updn - 0.01))
            else
                self.speed_updn = self.speed_updn * 0.5
            end
            
            local sx, sy = self.sprite:getLoc()
            self.sprite:setLoc(sx+(self.speed_lfrt),sy+(self.speed_updn))
            
            coroutine.yield()
        end
    end )

    --self.keyEventHandle = ExeInput.addKeyboardEvent(function(key,down)
    --    print ("Pressed: " .. key)
    --end)
    
    ExeMap.player = self

    return self
end

function ExeEditor.pointerCallback(self,x, y)
    self.mouseWorldX, self.mouseWorldY = ExeMap.layer:wndToWorld ( x, y )
    if self.dragged then
        self.dragMouseJoint:setTarget(self.mouseWorldX, self.mouseWorldY)
    end
end

function ExeEditor.leftClickCallback(self,down)
    if down then
        local prop = ExeMap.layer:getPartition():propForPoint ( self.mouseWorldX, self.mouseWorldY )
        --print(prop)
        if prop and prop.body then
            self.dragged = prop
            self.dragMouseBody = ExeMap.physWorld:addBody( MOAIBox2DBody.DYNAMIC )
            self.dragMouseBody:setTransform(self.mouseWorldX, self.mouseWorldY)
            
            self.dragMouseJoint = ExeMap.physWorld:addMouseJoint(self.dragMouseBody, self.dragged.body, self.mouseWorldX, self.mouseWorldY,  10000.0 * self.dragged.body:getMass())
            self.dragMouseJoint:setDampingRatio(0);
        end
    else
        if self.dragged then
            --also destroys joint
            self.dragMouseBody:destroy()
            self.dragMouseBody = nil
            self.dragged = nil
        end
    end
end

function ExeEditor.rightClickCallback(self,down)
    if down == false then
        ExeEditor.points_chain:createPoint(self.mouseWorldX,self.mouseWorldY)
    end
end

function ExeEditor:deactivate(camera)
  self.active = false
  camera:removeAnchor(self.sprite)
end

function ExeEditor:activate(camera)
    self.active = true
    camera:addAnchor(self.sprite)
end

function ExeEditor.save()
    local points = json.encode(ExeEditor.points_chain.points)
    
    local f,err = io.open("data/entity.js","w")
    if not f then
        return print(err) 
    end
    
    f:write(points) 
    f:close()
end

function ExeEditor:destroy()
    ExeInput.removeKeyboardEvent(self.keyEventHandle)
    self.thread:stop()
    self.thread = nil
end

return ExeEditor