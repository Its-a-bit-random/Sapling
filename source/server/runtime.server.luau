local BlockingDispatcher = require(script.Parent.BlockingDispatcher)
local binder = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.binder.binder)
local queryBuilder = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.queryBuilder)
local sapling = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.sapling)

sapling.loadServices(script.Parent.services)
sapling.fireLifecycle("onStart")

sapling.createLifecycle("blockingTest", BlockingDispatcher.new())
sapling.fireLifecycle("blockingTest")
print("Post lifecycle fire call")

print(queryBuilder.new():withTag("CoolTag"):query())

local RainbowEffect = {}
RainbowEffect.__index = RainbowEffect

function RainbowEffect.new(instance: Part)
    local self = setmetatable({}, RainbowEffect)
    self.p = instance
    self.p.Color = Color3.fromRGB(255, 255, 0)
    return self
end

function RainbowEffect.Destroy(self)
    self.p.Color = Color3.fromRGB(255, 0, 0)
end

local coolBinder = binder.new("Rainbow", RainbowEffect)
coolBinder:Start()

task.wait(5)

coolBinder:Destroy()
