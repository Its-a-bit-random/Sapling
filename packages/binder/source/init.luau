local CollectionService = game:GetService("CollectionService")

local BaseObject = require(script.Parent.roblox_packages.BaseObject)

type ClassInterface<T> = {
	new: (instance: Instance) -> T,
	Destroy: (T) -> (),
}

local Binder = setmetatable({}, BaseObject)
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
	self._ClassInstances = {}

	self._Sweeper:Add(function()
		for _, v in self._ClassInstances do
			v:Destroy()
		end
	end)

	return self
end

function Binder.Start<T>(self: Binder<T>)
	for _, v in CollectionService:GetTagged(self._Tag) do
		self._ClassInstances[v] = self._Class.new(v)
	end

	self._Sweeper:Add(CollectionService:GetInstanceAddedSignal(self._Tag):Connect(function(instance: Instance)
		if self._ClassInstances[instance] ~= nil then
			warn("Already has class binded")
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
