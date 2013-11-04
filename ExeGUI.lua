--[[
    FILE: ExeGUI.lua
    DESCRIPTION: MoaiGUI wrapper class.
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 26-10-2013
]]

-- Load MoaiGUI
require "gui/support/class"
local gui = require "gui/gui"
local resources = require "gui/support/resources"
local filesystem = require "gui/support/filesystem"
local inputconstants = require "gui/support/inputconstants"
local layermgr = require "layermgr"

local _M = {}

function _M.init()
    -- Create the GUI, passing in the dimensions of the screen
    _M.gui = gui.GUI(screenWidth, screenHeight)
    
    -- Search through these for specified resources
    _M.gui:addToResourcePath(filesystem.pathJoin("resources", "fonts"))
    _M.gui:addToResourcePath(filesystem.pathJoin("resources", "gui"))
    _M.gui:addToResourcePath(filesystem.pathJoin("resources", "media"))
    _M.gui:addToResourcePath(filesystem.pathJoin("resources", "themes"))
    _M.gui:addToResourcePath(filesystem.pathJoin("resources", "layouts"))

    _M.gui:setTheme("basetheme.lua")
    _M.gui:setCurrTextStyle("default")
    
    ExeGame.layer_gui = _M.gui:layer()
    MOAISim.pushRenderPass ( ExeGame.layer_gui )
    
    _M.keyEventHandle = ExeInput.addKeyboardEvent(function(key, down)
        if (down == true) then
            _M.gui:injectKeyDown(key)
        else
            _M.gui:injectKeyUp(key)
        end
    end)
    
    _M.pointerEventHandle = ExeInput.addPointerEvent(function(x, y)
        _M.gui:injectMouseMove(x, y)
    end)
    
    _M.mouseLeftEventHandle = ExeInput.addMouseLeftEvent(function(down)
        if (down) then
            _M.gui:injectMouseButtonDown(inputconstants.LEFT_MOUSE_BUTTON)
        else
            _M.gui:injectMouseButtonUp(inputconstants.LEFT_MOUSE_BUTTON)
        end
    end)
    
    _M.mouseMiddleEventHandle = ExeInput.addMouseMiddleEvent(function(down)
        if (down) then
            _M.gui:injectMouseButtonDown(inputconstants.MIDDLE_MOUSE_BUTTON)
        else
            _M.gui:injectMouseButtonUp(inputconstants.MIDDLE_MOUSE_BUTTON)
        end
    end)
    
    _M.mouseRightEventHandle = ExeInput.addMouseRightEvent(function(down)
        if (down) then
            _M.gui:injectMouseButtonDown(inputconstants.RIGHT_MOUSE_BUTTON)
        else
            _M.gui:injectMouseButtonUp(inputconstants.RIGHT_MOUSE_BUTTON)
        end
    end)
    
    -- Load the widgets from the specified file
    -- Parameter 1: filename of the layout
    -- Parameter 2: (optional) a prefix added to the name (from the layout file) of each widget; this
    --		is to help avoid name collisions
    -- Returns three values, but the second is the only one we're really interested in
    _M.roots, _M.widgets, _M.groups = _M.gui:loadLayout(resources.getPath("entity_editor.lua"), "editor")
end

return _M