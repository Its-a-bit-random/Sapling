local ExampleService = {}

function ExampleService.onStart()
	print("Hello World")
end

function ExampleService.blockingTest()
	print("waiting 1 second")
	task.wait(1)
end

return ExampleService
