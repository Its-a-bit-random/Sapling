local RunService = game:GetService("RunService")
local sweeper = require(script.Parent.Parent.Parent.packages.sweeper)

local SweeperTestService = {}
SweeperTestService.ServiceName = "SweeperTestService"

export type SweeperTestService = typeof(SweeperTestService)

function SweeperTestService.OnStart(self: SweeperTestService)
	local gc = sweeper.new()
	gc:Add(RunService.Heartbeat:Connect(print))
	gc:Add(function()
		print("Cleanup")
	end)
	task.delay(1, function()
		gc:Clean()
	end)
end

return SweeperTestService
