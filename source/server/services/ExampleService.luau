local ExampleService = {}

export type ExampleService = typeof(setmetatable({} :: {}, typeof({ __index = ExampleService })))

function ExampleService.onStart(self: ExampleService)
	print("Hello World")
end

function ExampleService.blockingTest(self: ExampleService)
	print("waiting 1 second")
	task.wait(1)
end

return ExampleService
