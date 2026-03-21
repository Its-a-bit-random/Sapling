local Dispatchers = require(script.Dispatchers)
local BaseDispatcher = require(script.classes.BaseDispatcher)
local Lifecycle = require(script.classes.Lifecycle)
local ServiceManager = require(script.modules.ServiceManager)
local filterArray = require(script.modules.filterArray)
local types = require(script.types)

export type Service = types.Service
export type BaseDispatcher = BaseDispatcher.BaseDispatcher
export type Lifecycle = Lifecycle.Lifecycle

local function instanceOf(className: string)
	return function(instance: Instance)
		return instance:IsA(className)
	end
end

--[=[
	@class Sapling
	The main / core package of the Sapling framework.
]=]
local Sapling = {}

--[=[
	Loads all module scripts under `parent` ignoring anything which isn't a [ModuleScript] instance.
]=]
function Sapling.loadServices(parent: Instance, recursive: boolean?)
	local instances = if recursive then parent:GetDescendants() else parent:GetChildren()
	local modules = filterArray(instances, instanceOf("ModuleScript"))

	for _, v in modules do
		ServiceManager.addService(v)
	end
end

--[=[
	Utility function to quickly fire a lifecycle, this is so you dont need to create a lifecycle object
	to fire it and whatever. You can just call this function with the name and any paramaters you want to
	pass.
]=]
function Sapling.fireLifecycle(name: string, ...: any)
	local lifecycle = Lifecycle.new(name)
	lifecycle:fire(...)
end

--[=[
	@param dispatcher BaseDispatcher
	@return Lifecycle

	Just calls [Lifecycle.new]
]=]
function Sapling.createLifecycle(name: string, dispatcher: BaseDispatcher.BaseDispatcher?): Lifecycle.Lifecycle
	return Lifecycle.new(name, dispatcher)
end

--[=[
	This function returns a new class that extends the [BaseDispatcher]. Here is a basic example of a blocking dispatcher:

	```lua
	local BlockingDispatcher = Sapling.extendBaseDispatcher()

	function BlockingDispatcher.dispatch(
		self: typeof(BlockingDispatcher),
		name: string,
		...: any
	)
		-- The :collectFunctions() is a method on the baseDispatcher class, you can override it yourself
		-- if you really want but there is simply no point to.
		local functions = self:collectFunctions(name)

		-- Loop through all the functiosn and call them
		for _, fn in functions do
			fn(...)
		end
	end

	return BlockingDispatcher
	```
]=]
function Sapling.extendBaseDispatcher()
	local newDispatcher = setmetatable({}, BaseDispatcher)
	newDispatcher.__index = newDispatcher

	function newDispatcher.new()
		local self = setmetatable(BaseDispatcher.new(), newDispatcher)
		return self
	end

	return newDispatcher
end

--[=[
	@readonly
	@prop Dispatchers any 
	@within Sapling

	All the built-in dispatchers lifecycle dispatchers.
]=]
Sapling.Dispatchers = Dispatchers

return Sapling
