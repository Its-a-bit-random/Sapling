--[=[
    @class SweeperUtils
]=]
local SweeperUtils = {}

--[=[
    Check if the passed `obj` is something which can be handled by a Sweeper.
]=]
function SweeperUtils.IsValid(obj: any, destroyMethod: string?)
    if typeof(obj) == "function" then
        return true
    end

    if typeof(obj) == "Instance" then
        return true
    end

    if typeof(obj) == "table" then
        return typeof(obj[destroyMethod]) == "function"
    end

    return false
end

return SweeperUtils
