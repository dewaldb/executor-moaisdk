--[[
    FILE: ExeEditorPointsChain.lua
    DESCRIPTION: 
    AUTHOR: Dewald Bodenstein
    VERSION: 0.2
    MOAI VERSION: v1.4p0
    CREATED: 16-08-13
]]

local ExeEditorPointsChain = {}
ExeEditorPointsChain.__index = ExeEditorPointsChain

setmetatable(ExeEditorPointsChain, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function ExeEditorPointsChain.new(args)
    local self = setmetatable({}, ExeEditorPointsChain)
    
    self.name = args.name
    
    ExeEditorPointsChain.points = {}
    self.phys_points = {}
    
    self.scriptDeck = MOAIScriptDeck.new ()
    self.scriptDeck:setRect ( -4096/worldScale, -4096/worldScale, 4096/worldScale, 4096/worldScale )
    self.scriptDeck:setDrawCallback ( ExeEditorPointsChain.onDraw )
    
    self.color = MOAIColor.new()
    self.color:setColor(1, 0, 0, 1)
    
    self.prop = MOAIProp2D.new ()
    self.prop:setDeck ( self.scriptDeck )
    self.prop:setAttrLink(MOAIColor.INHERIT_COLOR, self.color, MOAIColor.COLOR_TRAIT)
    
    ExeGame.layer:insertProp ( self.prop )
    
    -- points chain control thread
    self.thread = MOAIThread.new()
    self.thread:run( function()
        while true do
            self:listPoints()
            
            coroutine.yield()
        end
    end )
    
    return self
end

function ExeEditorPointsChain:destroy()
  ExeGame.layer:removeProp ( self.prop )
  self.prop = nil
end

function ExeEditorPointsChain:createPoint(posx,posy)
    table.insert(self.phys_points,ExeMap.spawnEntity("ExeEditorPoint",{x=posx,y=posy,name="point_"..#self.phys_points}))
end

function ExeEditorPointsChain:listPoints()
    ExeEditorPointsChain.points = {}
    for i,point in ipairs(self.phys_points) do
        local px,py = point.body:getPosition()
        table.insert(ExeEditorPointsChain.points,px)
        table.insert(ExeEditorPointsChain.points,py)
    end
end

function ExeEditorPointsChain.onDraw ( index, xOff, yOff, xFlip, yFlip )
    MOAIDraw.drawLine ( unpack ( ExeEditorPointsChain.points ) )
end

return ExeEditorPointsChain