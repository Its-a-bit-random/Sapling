local CollectionService = game:GetService("CollectionService")

local BaseObject = require(script.Parent.roblox_packages.BaseObject)

type ClassInterface<T> = {
	new: (instance: Instance) -> T,
	Destroy: (T) -> (),
}

local Binder = {}
Binder.ClassName = "Binder"
Binder.__index = Binder

export type Binder<T> =
	typeof(setmetatable(
		{} :: {
			_Class: ClassInterface<T>,
			_Tag: string,
			_ClassInstances: { [Instance]: ClassInterface<T> },
		},
		Binder
	))
	& BaseObject.BaseObject

function Binder.new<T>(tag: string, class: ClassInterface<T>)
	local self: Binder<T> = setmetatable(BaseObject.new(), Binder)
	self._Class = class
	self._Tag = tag
	return self
end

function Binder.Start<T>(self: Binder<T>)
	self._Sweeper:Add(CollectionService:GetInstanceAddedSignal(self._Tag):Connect(function(instance: Instance)
		if self._ClassInstances[instance] ~= nil then
			return
		end
		self._ClassInstances[instance] = self._Class.new(instance)
	end))
	self._Sweeper:Add(CollectionService:GetInstanceRemovedSignal(self._Tag):Connect(function(a0: Instance)
		local class = self._ClassInstances[a0]
		if class == nil then
			return
		end
		class:Destroy()
	end))
end

return Binder
