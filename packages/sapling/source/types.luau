--[=[
	@class types
	Just a types module.
]=]

--[=[
	@type Service { [string | unknown]: unknown } & { ["ServiceName"]: string }
	@within types
]=]
export type Service = { [string | unknown]: unknown } & { ["ServiceName"]: string }

--[=[
	@interface InjectedAPI
	.addModule (module: ModuleScript) -> ()
	@within types

	This is the type which gets injected into `_G`. This allows packages to just be loaded with [Sapling.loadPackages] without manually
	calling `require` on every single pacakge you use in your game.
]=]
export type InjectedAPI = {
    addModule: (module: ModuleScript) -> (),
}

return nil
