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

local Sapling = {}

function Sapling.loadServices(parent: Instance, descendants: boolean)
	local instances = if descendants then parent:GetDescendants() else parent:GetChildren()
	local modules = filterArray(instances, instanceOf("ModuleScript"))

	for _, v in modules do
		ServiceManager.addService(v)
	end
end

function Sapling.fireLifecycle(name: string, ...: any)
	local lifecycle = Lifecycle.new(name)
	lifecycle:fire(...)
end

function Sapling.createLifecycle(name: string, dispatcher: BaseDispatcher.BaseDispatcher?)
	return Lifecycle.new(name, dispatcher)
end

function Sapling.extendBaseDispatcher()
	local newDispatcher = setmetatable({}, BaseDispatcher)
	newDispatcher.__index = newDispatcher

	function newDispatcher.new()
		local self = setmetatable(BaseDispatcher.new(), newDispatcher)
		return self
	end

	return newDispatcher
end

Sapling.Dispatchers = Dispatchers

return Sapling
