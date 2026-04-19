--[=[
    @class Registry
    A registry is a centralized collection of validated data.

    :::info
    The type `T` is the type of the items in the registry.
    :::
]=]
local Registry = {}
Registry.__index = Registry

export type Registry<T> = typeof(setmetatable(
    {} :: {
        _Items: { [string]: T },
        _ValidateFn: (obj: any) -> boolean,
        _ProcessFn: (obj: Instance) -> T,
    },
    Registry
))

--[=[
    Create a new registry. The `parent` paramater if passed will just call [Registry.loadFromParent], pass nil to skip this.
    You can pass a `validationFunction` which gets asserted on every object to ensure its the correct type.
    Finally a `processFunction` can be passed which gets run on every object and can convert objects into something else, for
    example you could create a processFunction like this:
    ```lua
    Registry.new(script.Parent.ItemModels, nil, function(instance: Model)
        local item = {}
        for k, v in instance:GetAttributes() do
            items[k] = v
        end
        item.model = instance
        return item
    end)
    ```

    :::info
    If your data is stored as module scripts this will automatically pick that up and require the module scripts for you. However
    if you have a folder with mixed instance (e.g. ModuleScripts and Folders) if will not work properly and require the module scripts
    but add the raw instacne folders themselves (if no validationFunction is present).
    :::
]=]
function Registry.new<T>(
    parent: Instance?,
    validationFunction: (obj: any) -> boolean?,
    processFunction: (obj: Instance) -> T?
)
    local self = setmetatable({}, Registry) :: Registry<T>

    self._Items = {}
    self._ValidateFn = validationFunction or function()
        return true
    end

    self._ProcessFn = processFunction
        or function(obj: Instance)
            if obj:IsA("ModuleScript") then
                return require(obj)
            end
            return obj :: T
        end

    if parent ~= nil then
        self:loadFromParent(parent)
    end

    return self
end

--[=[
    @method add
    @param name string
    @param obj T
    @within Registry

    Adds something to the registry.
    @error "Object did not pass validation function" -- The `obj` passed doesnt pass the `validationFunction` after the `processFunction`
]=]
function Registry.add<T>(self: Registry<T>, name: string, obj: T)
    local processed = self._ProcessFn(obj)
    assert(self._ValidateFn(processed), "Object did not pass validation function")
    self._Items[name] = processed
end

--[=[
    @method loadFromParent
    @param instance Instance
    @within Registry

    Load all the instacnes from the given `instance`. Note that this only calls `:GetChildren()` on the `instance`.
]=]
function Registry.loadFromParent<T>(self: Registry<T>, instance: Instance)
    for _, v in instance:GetChildren() do
        self:add(v.Name, v)
    end
end

--[=[
    @method doesExist
    @param name string
    @return boolean
    @within Registry

    Check if an item with the name `name` exists in the repository.
]=]
function Registry.doesExist<T>(self: Registry<T>, name: string)
    return self._Items[name] ~= nil
end

--[=[
    @method getItem
    @param name string
    @return T
    @within Registry
    
    Gets an item with the name `name` from the registry, if it doesn't exist this function will error.

    @error "Object with the name "{name}" doesn't exist in the repository." -- No object with the name `name` exist in the repository. You should use "doesExist" if you are cannot guarantee if an object will exist.
]=]
function Registry.getItem<T>(self: Registry<T>, name: string)
    assert(self:doesExist(name), `Object with the name "{name}" doesn't exist in the repository.`)
    return self._Items[name] :: T
end

return Registry
