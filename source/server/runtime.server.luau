local BlockingDispatcher = require(script.Parent.BlockingDispatcher)
local sapling = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.sapling)

sapling.loadServices(script.Parent.services)
sapling.fireLifecycle("onStart")

sapling.createLifecycle("blockingTest", BlockingDispatcher.new())
sapling.fireLifecycle("blockingTest")
print("Post lifecycle fire call")
