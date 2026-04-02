local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sapling = require(script.Parent.Parent.packages.sapling)

sapling.loadPackages(ReplicatedStorage.packages)
sapling.loadServices(script.Parent.Services, true)
sapling.fireLifecycle("OnStart")
