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
	.Classes { string }
	@within Binder

	```lua
	local config = {
		Tags = { "Blue", "Red" }, -- Has tag "Blue" AND "Red"
		Classes = { "BasePart", "Model" }, -- Is a BasePart OR Model
		Ancestors = { Workspace, ReplicatedStorage } -- In Workspace OR ReplicatedStorage
	}
	```
]=]
type BinderConfig = {
    Tags: { string },
    Classes: { string },
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
            _Config: BinderConfig,
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
            Classes = {},
        }
    end
    local config = tag :: BinderConfig

    local self: Binder<T> = setmetatable(BaseObject.new(), Binder)
    self._Class = class
    self._Config = tag
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

        if #config.Classes == 0 then
            return true
        end

        for _, class in config.Classes do
            if instance:IsA(class) then
                return true
            end
        end

        return false
    end

    self._Sweeper:Add(function()
        for _, v in self._ClassInstances do
            v:Destroy()
        end
        table.clear(self._ClassInstances)
    end)

    return self
end

--[=[
	@private
	Check if `instance` has a class creted for it.
]=]
function Binder._HasInstanceGotAClass<T>(self: Binder<T>, instance: Instance): boolean
    return self._ClassInstances[instance] ~= nil
end

--[=[
	@private
	Create a class for the `instance`, as well as checking if it fits the [BinderConfig] and it doesn
	not yet have a class.
]=]
function Binder._Add<T>(self: Binder<T>, instance: Instance)
    local hasClass = self:_HasInstanceGotAClass(instance)
    local canAdd = self._Predicate(instance)

    if hasClass or not canAdd then
        return
    end

    local class = self._Class.new(instance)
    self._ClassInstances[instance] = class
end

--[=[
	@private
	Destroys the `instance`'s class if it has one.
]=]
function Binder._Remove<T>(self: Binder<T>, instance: Instance)
    local hasClass = self:_HasInstanceGotAClass(instance)

    if not hasClass then
        return
    end

    local class = self._ClassInstances[instance]
    class:Destroy()
    self._ClassInstances[instance] = nil
end

--[=[
	Connects the [CollectionService] events needed to listen to tags.
]=]
function Binder.Start<T>(self: Binder<T>)
    for _, tag in self._Config.Tags do
        for _, v in CollectionService:GetTagged(tag) do
            self:_Add(v)
        end

        self._Sweeper:Add(CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
            self:_Add(instance)
        end))

        self._Sweeper:Add(CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance: Instance)
            self:_Remove(instance)
        end))
    end
end

return Binder
