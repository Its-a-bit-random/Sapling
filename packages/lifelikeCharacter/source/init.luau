local RunService = game:GetService("RunService")

local sapling = _G.Sapling
assert(sapling, "Cannot find sapling, have you called, loadPackages?")
sapling.addModule(script)

--[=[
	@class LifelikeCharacters
	A simple package to automatically bring characters to life by doing the following:
	- Better footstep sounds
	- Seeing your body in first person
	- Head following camera angle in first & third person.

	*Note: Under the hood the system uses [MaximumADHD/Character-Realism](https://github.com/MaximumADHD/Character-Realism/tree/14021f7c4d0c89dd99d5a5af5f64b363c903767c)*
]=]
local LifelikeCharacter = {}

function LifelikeCharacter.saplingPackageStart()
	if RunService:IsClient() then
		local client = require(script.characterRealism.client)
		client:Start()
	else
		local Server = require(script.characterRealism.Server)
		Server.start()
	end
end

return LifelikeCharacter
