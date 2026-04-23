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

local function loadSaplingPackages()
    local packagesFolder = nil :: Folder
    do
        local parent = script
        while parent and parent:FindFirstChild(".pesde") == nil do
            parent = parent.Parent
        end
        if parent == nil then
            warn([[
                [SAPLING] Cannot locate packages folder
                    Sapling could not find the packages folder. Currently this only works if sapling is installed
                    with the PESDE package manager. If you encouter this error please submit a bug report at
                        https://github.com/Its-a-bit-random/Sapling/issues/new/choose
            ]])
            return
        end
        packagesFolder = parent
    end

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
    if not havePackagesBeenStarted then
        loadSaplingPackages()
    end

    local instances = if recursive then parent:GetDescendants() else parent:GetChildren()
    local modules = filterArray(instances, instanceOf("ModuleScript")) :: { ModuleScript }

    for _, v in modules do
        Sapling.loadService(v)
    end
end

--[=[
	@deprecated v1.1.0 -- Function is obsolete and will be removed in the next MAJOR version.
]=]
function Sapling.loadPackages(_p: any)
    warn(`Sapling.loadPackages() has been deprecated in 1.1.0 and no longer needs to be called`)
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
