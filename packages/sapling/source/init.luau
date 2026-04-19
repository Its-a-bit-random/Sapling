local BaseDispatcher = require(script.classes.BaseDispatcher)
local Dispatchers = require(script.Dispatchers)
local Lifecycle = require(script.classes.Lifecycle)
local Packages = require(script.modules.Packages)
local ServiceManager = require(script.modules.ServiceManager)
local filterArray = require(script.modules.filterArray)
local safeRequire = require(script.modules.safeRequire)
local types = require(script.types)

export type Service = types.Service
export type BaseDispatcher = BaseDispatcher.BaseDispatcher
export type Lifecycle = Lifecycle.Lifecycle

local function instanceOf(className: string)
    return function(instance: Instance)
        return instance:IsA(className)
    end
end

local havePackagesBeenStarted = false

--[=[
	@class Sapling
	The main / core package of the Sapling framework.
]=]
local Sapling = {}

--[=[
	Load a single service from a module
]=]
function Sapling.loadService(serviceModule: ModuleScript)
    local isValid, service = safeRequire(serviceModule)
    if not isValid then
        warn(`[SAPLING] Failed to require module: {serviceModule:GetFullName()}: {service}`)
        return
    end

    if typeof(service) ~= "table" then
        warn(`[SAPLING] Module {serviceModule:GetFullName()} does not return a table; ignoring.`)
        return
    end

    if service.ServiceName == nil then
        warn(`[SAPLING] Service {serviceModule:GetFullName()} has no "ServiceName"`)
        service.ServiceName = serviceModule.Name
    end

    ServiceManager.addService(service)
end

--[=[
	Loads all module scripts under `parent` ignoring anything which isn't a [ModuleScript] instance.
]=]
function Sapling.loadServices(parent: Instance, recursive: boolean?)
    local instances = if recursive then parent:GetDescendants() else parent:GetChildren()
    local modules = filterArray(instances, instanceOf("ModuleScript")) :: { ModuleScript }

    for _, v in modules do
        Sapling.loadService(v)
    end
end

--[=[
	This function only needs to be called if you are using any other Sapling Framework packages,
	simply point it to your Packages folder and Sapling will handle the rest.

	If you do not call this function at the right time, or at all, pacakges will throw an error and tell you that
	you have not called this function.

	:::warning
	This function **NEEDS** to be called before you call `loadServices` otherwise packages will error.
	:::

	:::danger
	If you use [Actor] you will need to call this in every [Actor] to avoid errors.
	:::

	@error "You can only call loadPackages one time" -- You should only call this function once, before you call `loadService`.
]=]
function Sapling.loadPackages(packagesFolder: Folder)
    assert(not havePackagesBeenStarted, "You can only call loadPackages one time")

    local instances = packagesFolder:GetChildren()
    local modules = filterArray(instances, instanceOf("ModuleScript")) :: { ModuleScript }

    _G.Sapling = Packages.getGlobalAPI()
    for _, v in modules do
        -- We use safe require here and discard any errors because some modules may
        -- have some asserts about being on the server/client.
        safeRequire(v)
    end
    _G.Sapling = nil

    local packageModules = Packages.getModules()
    for _, v in packageModules do
        Sapling.loadService(v)
    end

    Packages.callLifecycles()
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
