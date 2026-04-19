local Sweeper = require(script.Parent.roblox_packages.Sweeper)

--[=[
    @class BaseObject
    A base object that you should extend. It provides a sweeper for you as well as a Destroy function so you
    don't need to do all of that.
    
    For example here is a class which extends BaseObject:
    ```lua
    local MyClass = setmetatable({}, BaseObject)
    MyClass.ClassName = "MyClass"
    MyClass.__index = MyClass

    export type MyClass = typeof(setmetatable({} :: {}, BaseObject)) & BaseObject.BaseObject

    function MyClass.new()
        local self: MyClass = setmetatable(BaseObject.new(), MyClass)
        return self
    end
    ```

    Notice how we dont need to define a `Destroy` method, as well as it automatically having a sweeper object at `self._Sweeper`
]=]

local BaseObject = {}
BaseObject.ClassName = "BaseObject"
BaseObject.__index = BaseObject

export type BaseObject = typeof(setmetatable(
    {} :: {
        _Sweeper: Sweeper.Sweeper,
    },
    BaseObject
))

--[=[]=]
function BaseObject.new()
    local self: BaseObject = setmetatable({}, BaseObject)
    self._Sweeper = Sweeper.new()
    return self
end

--[=[]=]
function BaseObject.Destroy(self: BaseObject)
    self._Sweeper:Destroy()
    setmetatable(self, nil)
end

return BaseObject
