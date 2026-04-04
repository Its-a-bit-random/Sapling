local CollectionService = game:GetService("CollectionService")

local BaseObject = require(script.Parent.roblox_packages.BaseObject)

--[=[
	@interface ClassInterface<T>
	.new (instance: Instance) -> T
	.Destroy (T) -> ()
	@within Binder

	Basic requiremnts for a class to be able to be used by a Binder
]=]
type ClassInterface<T> = {
	new: (instance: Instance) -> T,
	Destroy: (T) -> (),
}

--[=[
	@interface BinderConfig
	.Tags { string }
	.Ancestors { Instance }
	@within Binder

	```lua
	local config = {
		Tags = { "Blue", "Red" }, -- Has tag "Blue" AND "Red"
		Ancestors = { Workspace, ReplicatedStorage } -- In Workspace OR ReplicatedStorage
	}
	```
]=]
type BinderConfig = {
	Tags: { string },
	Ancestors: { Instance },
}

--[=[
	@class Binder
	A binder allows you to bind a Luau class to instances with certain tags. For example:

	```lua
	local MyClass = {}
	MyClass.__index = MyClass

	function MyClass.new(robloxInstance)
		print("New tagged instance of ", robloxInstance)
		return setmetatable({}, MyClass)
	end

	function MyClass:Destroy()
		print("Cleaning up")
		setmetatable(self, nil)
	end

	-- bind to every instance with tag of "Yellow"
	local binder = Binder.new("Yellow", MyClass)
	binder:Start() -- listens for new instances and connects events
	```
]=]
local Binder = setmetatable({}, BaseObject)
Binder.ClassName = "Binder"
Binder.__index = Binder

export type Binder<T> =
	typeof(setmetatable(
		{} :: {
			_Class: ClassInterface<T>,
			_Tag: string,
			_ClassInstances: { [Instance]: ClassInterface<T> },
			_Predicate: (instance: Instance) -> boolean,
		},
		Binder
	))
	& BaseObject.BaseObject

--[=[
	@prop _Tag string
	@private
	@within Binder

	The [CollectionService] tag to bind to
]=]

--[=[
	@prop _Class ClassInterface<T>
	@private
	@within Binder

	Class table which should contain the constructor & destructor of the class.
]=]

--[=[
	@prop _ClassInstances { [Instance]: ClassInterface<T> }
	@private
	@within Binder

	A map of instances to their class instances.
]=]

--[=[
	Create a new binder You can either pass a single tag string, or you can pass a config which
	gives more fine-grain control over what instances you would like.
]=]
function Binder.new<T>(tag: string | BinderConfig, class: ClassInterface<T>): Binder<T>
	if typeof(tag) == "string" then
		tag = {
			Tags = { tag },
			Ancestors = { game },
		}
	end
	local config = tag :: BinderConfig

	local self: Binder<T> = setmetatable(BaseObject.new(), Binder)
	self._Class = class
	self._Tag = tag
	self._ClassInstances = {}
	self._Predicate = function(instance: Instance)
		local hasTag = true
		for _, v in config.Tags do
			hasTag = instance:HasTag(v)
			if not hasTag then
				return false
			end

			local isDescendant = false
			for _, v in config.Ancestors do
				isDescendant = instance:IsDescendantOf(v)
				if not isDescendant then
					return false
				end
			end
		end
		return true
	end

	self._Sweeper:Add(function()
		for _, v in self._ClassInstances do
			v:Destroy()
		end
	end)

	return self
end

--[=[
	Connects the [CollectionService] events needed to listen to tags.
]=]
function Binder.Start<T>(self: Binder<T>)
	for _, v in CollectionService:GetTagged(self._Tag) do
		self._ClassInstances[v] = self._Class.new(v)
	end

	self._Sweeper:Add(CollectionService:GetInstanceAddedSignal(self._Tag):Connect(function(instance: Instance)
		if self._ClassInstances[instance] ~= nil then
			warn("Already has class binded")
			return
		end
		if not self._Predicate(instance) then
			return
		end

		self._ClassInstances[instance] = self._Class.new(instance)
	end))

	self._Sweeper:Add(CollectionService:GetInstanceRemovedSignal(self._Tag):Connect(function(instance: Instance)
		local class = self._ClassInstances[instance]
		if class == nil then
			return
		end

		self._Class.Destroy(class)
		self._ClassInstances[instance] = nil
	end))
end

return Binder
