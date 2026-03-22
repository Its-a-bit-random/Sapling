local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local isSetup = false
local CAN_DO_FOOTSTEPS = SoundService.CharacterSoundsUseNewApi == Enum.RolloutState.Enabled

local player = Players.LocalPlayer

type HumanoidRootPart = Part & {
	Climbing: AudioPlayer,
	Died: AudioPlayer,
	FreeFalling: AudioPlayer,
	GettingUp: AudioPlayer,
	Jumping: AudioPlayer,
	Landing: AudioPlayer,
	Running: AudioPlayer,
	Splash: AudioPlayer,
	Swimming: AudioPlayer,
}

local defaultSounds = {
	Dirt = "rbxassetid://178054124",
	Wood = "rbxassetid://177940988",
	Concrete = "rbxassetid://277067660",
	Grass = "rbxassetid://4776173570",
	Metal = "rbxassetid://4790537991",
	Sand = "rbxassetid://4777003964",
	Fabric = "rbxassetid://4776951843",
	Gravel = "rbxassetid://4776998555",
	Marble = "rbxassetid://4776962643",
}

local config = {
	fallbackSound = "rbxasset://sounds/action_footsteps_plastic.mp3",
	materialSounds = {
		[Enum.Material.Slate] = defaultSounds.Gravel,
	} :: { [Enum.Material]: string },
}

local function onCharacterAdded(character: Model)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: HumanoidRootPart
	local humanoid = character:FindFirstChildWhichIsA("Humanoid") :: Humanoid

	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		local floorMaterial = humanoid.FloorMaterial
		local sound = config.materialSounds[floorMaterial] or config.fallbackSound
		humanoidRootPart:WaitForChild("Running").Asset = sound
	end)

	local floorMaterial = humanoid.FloorMaterial
	local sound = config.materialSounds[floorMaterial] or config.fallbackSound
	humanoidRootPart:WaitForChild("Running").Asset = sound
end

local function setupFootsteps()
	if not CAN_DO_FOOTSTEPS then
		warn(
			`[LifelikeCharactersService] Cannot use Footstep sounds as SoundService.CharacterSoundsUseNewApi is not set to Enabled.`
		)
		return
	end

	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character ~= nil then
		onCharacterAdded(player.Character)
	end
end

--[=[
    @class LifelikeCharactersServiceClient
    @client
]=]
local LifelikeCharactersServiceClient = {}

--[=[
    @private
    This function is called for you when the package starts. You do NOT need to call this.
    
    If you call this function it already
]=]
function LifelikeCharactersServiceClient.setup()
	assert(not isSetup, "Setup has already been called")
	isSetup = true
	setupFootsteps()
end

return LifelikeCharactersServiceClient
