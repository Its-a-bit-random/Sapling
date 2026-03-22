local types = require(script.Parent.Parent.types)
type Service = types.Service
local safeRequire = require(script.Parent.safeRequire)

local services = {} :: { [ModuleScript]: Service }

local ServiceManager = {}

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

function ServiceManager.collectFunctions(name: string)
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
