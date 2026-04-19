local BaseDispatcher = require(script.Parent.BaseDispatcher)
local Dispatchers = require(script.Parent.Parent.Dispatchers)

local lifecycles = {} :: { [string]: Lifecycle }

--[=[
	@class Lifecycle

	A lifecycle is a class that allows you to call a certain function on every service. For example,
	you could have an "onStart" lifecycle.
]=]
local Lifecycle = {}
Lifecycle.__index = Lifecycle

export type Lifecycle = typeof(setmetatable(
    {} :: {
        _Name: string,
        _Dispatcher: BaseDispatcher.BaseDispatcher,
    },
    Lifecycle
))

--[=[
	@param dispatcher BaseDispatcher
 
	Create a new Lifecycle with the given `name`. You can optionally pass a dispatcher to use,
	it defaults to an AsyncDispatcher if nothing is passed.
]=]
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

--[=[
	@method fire
	@param ... any
	@within Lifecycle
	
	Fires the lifecycle, anything passed into `...` will also be passed to every function which this
	lifecycle invokes.
]=]
function Lifecycle.fire(self: Lifecycle, ...: any)
    self._Dispatcher:dispatch(self._Name, ...)
end

return Lifecycle
