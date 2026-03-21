local ServiceManager = require(script.Parent.Parent.modules.ServiceManager)

--[=[
	@class BaseDispatcher
]=]
local BaseDispatcher = {}
BaseDispatcher.__index = BaseDispatcher

export type BaseDispatcher = typeof(setmetatable(
	{} :: {
		__ClassName: string,
	},
	BaseDispatcher
))

--[=[
	@method collectFunctions
	@param name string
	@return { () -> () }
	@within BaseDispatcher

	Returns all function on services which have the passed `name`.
]=]
function BaseDispatcher.collectFunctions(self: BaseDispatcher, name: string)
	return ServiceManager.collectFunctions(name)
end

--[=[
	@method dispatch
	@param name string
	@param ... any
	@within BaseDispatcher

	This is the method which is called by a lifecycle to actually call all the functions.
]=]
function BaseDispatcher.dispatch(self: BaseDispatcher, name: string, ...: any)
	error("No dispatch impl")
end

--[=[
	@function new
	@return BaseDispatcher
	@within BaseDispatcher

	Create a new dispatcher. This should NOT be called directly on the base dispatcher unless you are creating
	your own dispatcher.
]=]
function BaseDispatcher.new()
	local self = setmetatable({}, BaseDispatcher) :: BaseDispatcher
	self.__ClassName = "BaseDispatcher"
	return self
end

--[=[
	@function is
	@param obj T
	@return bool
	@within BaseDispatcher

	Check if the passed `obj` is a dispatcher, this can be either the [BaseDispatcher] or any class which extends [BaseDispatcher].
]=]
function BaseDispatcher.is<T>(obj: T)
	if typeof(obj) ~= "table" then
		return false
	end

	return obj["__ClassName"] == "BaseDispatcher"
end

return BaseDispatcher
