local TypeUtils = require(script.Parent.roblox_packages.TypeUtils)

local function WaitForChildWithPredicate(parent: Instance, predicate: (instance: Instance) -> boolean)
    for _, v in parent:GetChildren() do
        if predicate(v) then
            return v
        end
    end

    local thread = coroutine.running()

    local conn
    conn = parent.ChildAdded:Connect(function(child: Instance)
        if predicate(child) then
            task.spawn(thread, child)
        end
    end)

    local instance = coroutine.yield()
    conn:Disconnect()

    return instance
end

--[=[
	@class InstanceUtils
	:::warning
	Functions like `WaitForChildWithAttributeSetTo` will NOT work if you set the attribute after it is re-parented.
	This means that the thing you are waiting for needs to have the attribute already set when it gets parented.
	:::
]=]
local InstanceUtils = {}

--[=[
	Wait for a child which is of class `class` (Does a `:IsA()` check).
]=]
function InstanceUtils.WaitForChildWhichIsA(instance: Instance, class: string)
    return WaitForChildWithPredicate(instance, function(v: Instance)
        return v:IsA(class)
    end)
end

--[=[
	Waits for a child which has the `attribute` set to `value`. Note that if the attribute is set after the child is added
	it will not work as intended. The attribute must already exist before the parent is set to `instance`.
]=]
function InstanceUtils.WaitForChildWithAttributeSetTo(
    instance: Instance,
    attribute: string,
    value: TypeUtils.PossibleAttributeValue
)
    return WaitForChildWithPredicate(instance, function(v: Instance)
        return v:GetAttribute(attribute) == value
    end)
end

return InstanceUtils
