local types = require(script.Parent.Parent.types)

local SaplingUtils = {}

function SaplingUtils.MakeMethodFunctionCall<A..., R...>(
    service: types.Service & { [string]: ((A...) -> R...)? },
    methodName: string
): (A...) -> R...
    local fn = assert(service[methodName], `Method {methodName} not found on {service.ServiceName}`)
    return function(...: A...)
        return fn(service, ...)
    end
end

return SaplingUtils
