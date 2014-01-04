--[[
    FILE: ExeGame.lua
    DESCRIPTION: Game handler to initialize viewport and all required classes.
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 23-10-2013
]]

local _M = {}

function _M.init()
    -- Setup your basic window
    MOAISim.openWindow("Window",screenWidth,screenHeight)
    
    _M.viewport = MOAIViewport.new()
    _M.viewport:setSize(screenWidth,screenHeight)
    _M.viewport:setScale ( screenWidth/worldScale, screenHeight/worldScale )

    function onResize ( width, height )
      _M.viewport:setSize ( width, height )
      _M.viewport:setScale ( width, height )
    end

    _M.layer_background = MOAILayer2D.new ()
    _M.layer_background:setViewport ( _M.viewport )
    MOAISim.pushRenderPass ( _M.layer_background )

    _M.layer_behind = MOAILayer2D.new ()
    _M.layer_behind:setViewport ( _M.viewport )
    MOAISim.pushRenderPass ( _M.layer_behind )
    
    _M.layer = MOAILayer2D.new ()
    _M.layer:setViewport ( _M.viewport )
    MOAISim.pushRenderPass ( _M.layer )

    _M.layer_infront = MOAILayer2D.new ()
    _M.layer_infront:setViewport ( _M.viewport )
    MOAISim.pushRenderPass ( _M.layer_infront )
    
    _M.layer_debug = MOAILayer2D.new ()
    _M.layer_debug:setViewport ( _M.viewport )
    --MOAISim.pushRenderPass ( _M.layer_debug )

    _M.layer_gui = nil -- placeholder for the gui layer

    MOAIGfxDevice.setListener ( MOAIGfxDevice.EVENT_RESIZE, onResize )
end

return _M