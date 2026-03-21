local BaseDispatcher = require(script.Parent.BaseDispatcher)
local Dispatchers = require(script.Parent.Parent.Dispatchers)

local lifecycles = {} :: { [string]: Lifecycle }

local Lifecycle = {}
Lifecycle.__index = Lifecycle

export type Lifecycle = typeof(setmetatable(
	{} :: {
		_Name: string,
		_Dispatcher: BaseDispatcher.BaseDispatcher,
	},
	Lifecycle
))

function Lifecycle.new(name: string, dispatcher: BaseDispatcher.BaseDispatcher?)
	if lifecycles[name] ~= nil then
		return lifecycles[name]
	end

	if dispatcher == nil then
		-- Should we default to async or blocking?
		dispatcher = Dispatchers.AsyncDispatcher.new()
	end

	assert(typeof(name) == "string", "Name of a lifecycle must be a string")
	assert(
		BaseDispatcher.is(dispatcher),
		"Passed dispatcher is not a dispatcher object, did you extend the base dispatcher class?"
	)
	assert(name ~= "", "Lifecycle name cannot be empty")

	local self = setmetatable({}, Lifecycle) :: Lifecycle
	self._Name = name
	self._Dispatcher = dispatcher

	lifecycles[name] = self

	return self
end

function Lifecycle.fire(self: Lifecycle, ...)
	self._Dispatcher:dispatch(self._Name, ...)
end

return Lifecycle
