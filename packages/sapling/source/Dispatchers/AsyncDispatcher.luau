local BaseDispatcher = require(script.Parent.Parent.classes.BaseDispatcher)

--[=[
	@class AsyncDispatcher
	A built-in dispatcher that extends the [BaseDispatcher], if you are using this as a refrence for your own dispatcher,
	please use [Sapling.extendBaseDispatcher] to handle this metatable stuff for you.
]=]
local AsyncDispatcher = setmetatable({}, BaseDispatcher)
AsyncDispatcher.__index = AsyncDispatcher

export type AsyncDispatcher = typeof(setmetatable({} :: BaseDispatcher.BaseDispatcher, AsyncDispatcher))

--[=[
]=]
function AsyncDispatcher.new()
    local self = setmetatable(BaseDispatcher.new(), AsyncDispatcher) :: AsyncDispatcher
    return self
end

--[=[
	@method dispatch
	@param name string
	@param ... any
	@within AsyncDispatcher
]=]
function AsyncDispatcher.dispatch(self: AsyncDispatcher, name: string, ...: any)
    local functions = self:collectFunctions(name)
    for _, fn in functions do
        task.spawn(fn, ...)
    end
end

return AsyncDispatcher
