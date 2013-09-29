--[[
  FILE: ExeInput.lua
	DESCRIPTION: Input
	AUTHOR: Dewald Bodenstein
	VERSION: 0.1
	MOAI VERSION: v1.4p0
	CREATED: 18-08-13
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



function _M.addKeyboardEvent(callback)
  _M.keboardEventCount = _M.keboardEventCount+1
  local handle = "KeyEvent_".._M.keboardEventCount
  _M.keyboardEvents[handle] = callback
  return handle
end

function _M.addPointerEvent(callback)
  _M.pointerEventCount = _M.pointerEventCount+1
  local handle = "PointEvent_".._M.pointerEventCount
  _M.pointerEvents[handle] = callback
  return handle
end

function _M.addMouseLeftEvent(callback)
  _M.mouseLeftEventCount = _M.mouseLeftEventCount+1
  local handle = "MLeftEvent_".._M.mouseLeftEventCount
  _M.mouseLeftEvents[handle] = callback
  return handle
end

function _M.addMouseMiddleEvent(callback)
  _M.mouseMiddleEventCount = _M.mouseMiddleEventCount+1
  local handle = "MMiddleEvent_".._M.mouseMiddleEventCount
  _M.mouseMiddleEvents[handle] = callback
  return handle
end

function _M.addMouseRightEvent(callback)
  _M.mouseRightEventCount = _M.mouseRightEventCount+1
  local handle = "MRightEvent_".._M.mouseRightEventCount
  _M.mouseRightEvents[handle] = callback
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
  for i,callback in pairs(_M.keyboardEvents) do
    callback(key, down)
  end
end

function _M.onPointerEvent(x, y)
  _M.mousePos = {x=x,y=y}
  for i,callback in pairs(_M.pointerEvents) do
    callback(x, y)
  end
end

function _M.onMouseLeftEvent(down)
  _M.buttons[1] = down
  for i,callback in pairs(_M.mouseLeftEvents) do
    callback(down)
  end
end

function _M.onMouseMiddleEvent(down)
  _M.buttons[2] = down
  for i,callback in pairs(_M.mouseMiddleEvents) do
    callback(down)
  end
end

function _M.onMouseRightEvent(down)
  _M.buttons[3] = down
  for i,callback in pairs(_M.mouseRightEvents) do
    callback(down)
  end
end

return _M