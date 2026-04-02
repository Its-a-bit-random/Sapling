local types = require(script.Parent.Parent.types)
type Service = types.Service
local safeRequire = require(script.Parent.safeRequire)

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
function ServiceManager.addService(module: ModuleScript, service: Service?)
	if service == nil then
		local sucess, requiredService = safeRequire(module)
		if not sucess then
			error(`[SAPLING] Error while requiring module: {module:GetFullName()}: {requiredService}`)
			return
		end

		if typeof(requiredService) ~= "table" then
			warn(
				`Skipping: {module:GetFullName()} as it doesnt return a table but instead returns {typeof(
					requiredService
				)}`
			)
			return
		end

		service = requiredService :: Service
	end

	services[module] = service
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

		table.insert(functions, fn)
	end

	return functions
end

return ServiceManager
