--[[
    FILE: ExeInput.lua
    DESCRIPTION: Input
    AUTHOR: Dewald Bodenstein
    VERSION: 0.2
    MOAI VERSION: v1.4p0
    CREATED: 18-08-13
    Changes:
        -- Added the object parameter to the add{}Event functions:
           -- If object is passed then callback should be a string of the member functions name.
]]

local _M = {}

function _M.init()
  
  _M.keyboardEvents = {}
  _M.pointerEvents = {}
  _M.mouseLeftEvents = {}
  _M.mouseMiddleEvents = {}
  _M.mouseRightEvents = {}
  
  _M.keboardEventCount = 0
  _M.pointerEventCount = 0
  _M.mouseLeftEventCount = 0
  _M.mouseMiddleEventCount = 0
  _M.mouseRightEventCount = 0
  
  _M.mousePos = {x=0,y=0}
  
  -- Register the callbacks for input
  MOAIInputMgr.device.keyboard:setCallback(_M.onKeyboardEvent)
  MOAIInputMgr.device.pointer:setCallback(_M.onPointerEvent)
  MOAIInputMgr.device.mouseLeft:setCallback(_M.onMouseLeftEvent)
  MOAIInputMgr.device.mouseMiddle:setCallback(_M.onMouseMiddleEvent)
  MOAIInputMgr.device.mouseRight:setCallback(_M.onMouseRightEvent)
  
  _M.buttons = {}
  for x = 1, 3 do
    _M.buttons[x] = false
  end
  _M.keys = {}
  for x = 1, 256 do
    _M.keys[x] = false
  end
end


function _M.addKeyboardEvent(callback,object)
  _M.keboardEventCount = _M.keboardEventCount+1
  local handle = "KeyEvent_".._M.keboardEventCount
  _M.keyboardEvents[handle] = {func=callback,obj=object}
  return handle
end

function _M.addPointerEvent(callback,object)
  _M.pointerEventCount = _M.pointerEventCount+1
  local handle = "PointEvent_".._M.pointerEventCount
  _M.pointerEvents[handle] = {func=callback,obj=object}
  return handle
end

function _M.addMouseLeftEvent(callback,object)
  _M.mouseLeftEventCount = _M.mouseLeftEventCount+1
  local handle = "MLeftEvent_".._M.mouseLeftEventCount
  _M.mouseLeftEvents[handle] = {func=callback,obj=object}
  return handle
end

function _M.addMouseMiddleEvent(callback,object)
  _M.mouseMiddleEventCount = _M.mouseMiddleEventCount+1
  local handle = "MMiddleEvent_".._M.mouseMiddleEventCount
  _M.mouseMiddleEvents[handle] = {func=callback,obj=object}
  return handle
end

function _M.addMouseRightEvent(callback,object)
  _M.mouseRightEventCount = _M.mouseRightEventCount+1
  local handle = "MRightEvent_".._M.mouseRightEventCount
  _M.mouseRightEvents[handle] = {func=callback,obj=object}
  return handle
end




function _M.removeKeyboardEvent(handle)
  _M.keyboardEvents[handle] = nil
end

function _M.removePointerEvent(handle)
  _M.pointerEvents[handle] = nil
end

function _M.removeMouseLeftEvent(handle)
  _M.mouseLeftEvents[handle] = nil
end

function _M.removeMouseMiddleEvent(handle)
  _M.mouseMiddleEvents[handle] = nil
end

function _M.removeMouseRightEvent(handle)
  _M.mouseRightEvents[handle] = nil
end



function _M.onKeyboardEvent(key, down)
  -- table size: table.getn(a)
  _M.keys[key] = down
  for i,group in pairs(_M.keyboardEvents) do
    if group.obj ~= nil then
        group.func(group.obj,key, down)
    else 
        group.func(key, down)
    end
  end
end

function _M.onPointerEvent(x, y)
  _M.mousePos = {x=x,y=y}
  for i,group in pairs(_M.pointerEvents) do
    if group.obj ~= nil then
        group.func(group.obj,x, y)
    else 
        group.func(x, y)
    end
  end
end

function _M.onMouseLeftEvent(down)
  _M.buttons[1] = down
  for i,group in pairs(_M.mouseLeftEvents) do
    if group.obj ~= nil then
        group.func(group.obj,down)
    else 
        group.func(down)
    end
  end
end

function _M.onMouseMiddleEvent(down)
  _M.buttons[2] = down
  for i,group in pairs(_M.mouseMiddleEvents) do
    if group.obj ~= nil then
        group.func(group.obj,down)
    else 
        group.func(down)
    end
  end
end

function _M.onMouseRightEvent(down)
  _M.buttons[3] = down
  for i,group in pairs(_M.mouseRightEvents) do
    if group.obj ~= nil then
        group.func(group.obj,down)
    else 
        group.func(down)
    end
  end
end

return _M