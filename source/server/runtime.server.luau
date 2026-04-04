local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockingDispatcher = require(script.Parent.BlockingDispatcher)
local binder = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.binder.binder)
local queryBuilder = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.queryBuilder)
local sapling = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.sapling)

sapling.loadPackages(ReplicatedStorage.packages)
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
	self.thread = task.spawn(function()
		while true do
			task.wait(1)
			instance.BrickColor = BrickColor.random()
		end
	end)
end

function RainbowEffect.Destroy(self)
	task.cancel(self.thread)
end

local coolBinder = binder.new("Rainbow", RainbowEffect)
coolBinder:Start()

task.wait(5)

coolBinder:Destroy()
