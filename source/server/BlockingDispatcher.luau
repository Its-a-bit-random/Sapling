local sapling = require(script.Parent.Parent.Parent.ReplicatedStorage.packages.sapling)

--[[
    An example dispatcher which calls each function normally without task.spawn
    so that they are blocking.
]]

local BlockingDispatcher = sapling.extendBaseDispatcher()

function BlockingDispatcher.dispatch(self: typeof(BlockingDispatcher), name: string, ...)
	local functions = self:collectFunctions(name)
	for _, fn in functions do
		fn(...)
	end
end

return BlockingDispatcher
