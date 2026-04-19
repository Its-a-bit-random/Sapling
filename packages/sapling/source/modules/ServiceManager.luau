local SaplingUtils = require(script.Parent.SaplingUtils)
local types = require(script.Parent.Parent.types)
type Service = types.Service

local services = {} :: { [ModuleScript]: Service }

--[=[
	@class ServiceManager
	Container around all services.
]=]
local ServiceManager = {}

--[=[
	Adds a service, you can either pass just the module script itself and it will require it for you
	using `safeRequire` and throws a custom, better error message.
]=]
function ServiceManager.addService(service: Service)
    assert(service.ServiceName, "Service has no name")
    services[service.ServiceName] = service
end

--[=[
	Gets every function in the service which has the name `name`.
]=]
function ServiceManager.collectFunctions(name: string): { (...any) -> () }
    local functions = {} :: { (...any) -> () }

    for _, v in services do
        local fn = v[name]
        if fn == nil then
            continue
        end

        table.insert(functions, SaplingUtils.MakeMethodFunctionCall(v, name))
    end

    return functions
end

return ServiceManager
