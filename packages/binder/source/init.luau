local CollectionService = game:GetService("CollectionService")

local Sweeper = require(script.Parent.roblox_packages.Sweeper)

--[=[
    Function which takes in an instance and returns another function
    to cleanup
]=]
type BinderCallback = (instance: Instance) -> () -> ()

--[=[
    A simple package which allows you to bind a function to a tag. For example here is how you
    can create a rainbow tag to make any part rainbow:

    ```luau
    binder.bind("Rainbow", function(instance: Instance)
        assert(instance:IsA("BasePart"), "Cannot make a non BasePart rainbow")
        local thread = task.spawn(function()
            while task.wait(1) do
                instance.BrickColor = BrickColor.random()
            end
        end)

        -- Return a cleanup function
        return function()
            task.cancel(thread)
        end
    end)
    ```
]=]
local Binder = {}

--[=[
    @yields

    Little utility function to allow you to yield the current thread until the passed tag
    has been removed from the given instance, we need this because roblox doesnt have a proper
    way to *wait* nor detect if a tag is removed from a certain instance.

    @param tag the tag to check against
    @param instance the instance to check on
]=]
function Binder.yieldUntilTagIsRemoved(tag: string, instance: Instance)
    if not instance:HasTag(tag) then
        return
    end

    local thread = coroutine.running()

    -- NOTE:
    -- Instead of polling we use events to save performance, however if many binders exist this could use a lot of
    -- memory. In the future we could make it so that there is only 1 GetInstanceRemovedSignal for each tag. Polling is not
    -- an option here becuase if there are a lot of binders it will cause performance issues.
    local conn = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(taggedInstance: Instance)
        if taggedInstance == instance then
            coroutine.resume(thread)
        end
    end)

    coroutine.yield()

    conn:Disconnect()

    return
end

--[=[
    Binds the passed `callback` to the `instance` & `tag`. This is a small untility function to wrap around the
    functionality of calling the cleanup function if the instance is destroyed or tag is removed.

    @param tag the tag which should be bound
    @param instance the instance which should be bound
    @param callback function which handles the bound `instance` and `tag`
]=]
local function bindCallbackToInstance(tag: string, instance: Instance, callback: BinderCallback)
    local sweeper = Sweeper.new()

    local cleanup = callback(instance)

    sweeper:Add(cleanup)
    sweeper:Add(instance.Destroying:Connect(cleanup))

    do
        local thread = task.spawn(function()
            Binder.yieldUntilTagIsRemoved(tag, instance)
            cleanup()
        end)
        sweeper:Add(function()
            task.cancel(thread)
        end)
    end
end

--[=[
    Bind the `fn` to the passed `tag`. Keep in mind that if an instance is deleted rather than the tag removed
    the instance may be nil by the time the cleanup function is called.

    @param tag The tag to bind the `fn` to
    @param fn Function which returns a cleanup function
]=]
function Binder.bind(tag: string, fn: BinderCallback)
    for _, v in CollectionService:GetTagged(tag) do
        bindCallbackToInstance(tag, v, fn)
    end

    CollectionService:GetInstanceAddedSignal(tag):Connect(function(taggedInstance: Instance)
        bindCallbackToInstance(tag, taggedInstance, fn)
    end)
end

return Binder
