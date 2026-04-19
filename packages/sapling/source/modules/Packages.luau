local Lifecycle = require(script.Parent.Parent.classes.Lifecycle)
local types = require(script.Parent.Parent.types)

local packageModules = {} :: { ModuleScript }

--[=[
    @class Packages
]=]
local Packages = {}

--[=[
	Returns the global API that should be put into `_G`.
]=]
function Packages.getGlobalAPI()
    return {
        addModule = function(module: ModuleScript)
            table.insert(packageModules, module)
        end,
    } :: types.InjectedAPI
end

--[=[
	Returns all the modules that registered themselves with the `_G` api.
]=]
function Packages.getModules()
    return packageModules
end

--[=[
	Calls the entry point of every package.
]=]
function Packages.callLifecycles()
    local lf = Lifecycle.new("saplingPackageStart")
    lf:fire()
end

return Packages
