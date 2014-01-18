--[[
    FILE: ExeGame.lua
    DESCRIPTION: Game handler to initialize viewport and all required classes.
    AUTHOR: Dewald Bodenstein
    VERSION: 0.1
    MOAI VERSION: v1.4p0
    CREATED: 23-10-2013
]]

-- CONSTANTS AND UTILITIES
DEGTORAD = (math.pi/180)
DISTANCE = function(point1X,point1Y,point2X,point2Y)
  return math.sqrt(math.pow((point2X-point1X),2) + math.pow((point2Y-point1Y),2))
end
math.round = function (num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
table.deepCopy = function(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = table.deepCopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end