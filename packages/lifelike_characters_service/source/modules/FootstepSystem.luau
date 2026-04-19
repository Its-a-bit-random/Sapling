local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

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
        [Enum.Material.Mud] = defaultSounds.Dirt,
        [Enum.Material.Pebble] = defaultSounds.Dirt,
        [Enum.Material.Ground] = defaultSounds.Dirt,

        [Enum.Material.Sand] = defaultSounds.Sand,
        [Enum.Material.Snow] = defaultSounds.Sand,
        [Enum.Material.Sandstone] = defaultSounds.Sand,

        [Enum.Material.Rock] = defaultSounds.Gravel,
        [Enum.Material.Basalt] = defaultSounds.Gravel,
        [Enum.Material.Asphalt] = defaultSounds.Gravel,
        [Enum.Material.Glacier] = defaultSounds.Gravel,
        [Enum.Material.Slate] = defaultSounds.Gravel,

        [Enum.Material.Ice] = defaultSounds.Marble,
        [Enum.Material.Salt] = defaultSounds.Marble,
        [Enum.Material.Marble] = defaultSounds.Marble,
        [Enum.Material.Pavement] = defaultSounds.Marble,
        [Enum.Material.Limestone] = defaultSounds.Marble,

        [Enum.Material.Foil] = defaultSounds.Metal,
        [Enum.Material.DiamondPlate] = defaultSounds.Metal,
        [Enum.Material.CorrodedMetal] = defaultSounds.Metal,

        [Enum.Material.WoodPlanks] = defaultSounds.Wood,
        [Enum.Material.LeafyGrass] = defaultSounds.Grass,
        [Enum.Material.Fabric] = defaultSounds.Fabric,
        [Enum.Material.Carpet] = defaultSounds.Fabric,
    } :: { [Enum.Material]: string },
}

--[=[
    @class FootStepSystem
    @client
]=]
local FootStepSystem = {}

local function updateSoundSpeedAndVolume(humanoid: Humanoid, humanoidRootPart: HumanoidRootPart)
    if humanoidRootPart:FindFirstChild("Running") == nil then
        return
    end

    local hipHeight = humanoid.HipHeight
    if humanoid.RigType.Name == "R6" then
        hipHeight = 2.8
    end

    local scale = hipHeight / 3
    local speed = (humanoidRootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude
    local volume = ((speed - 4) / 12) * scale

    humanoidRootPart.Running.Volume = volume
    humanoidRootPart.Running.PlaybackSpeed = 1 / ((scale * 15) / speed)
end

local function updateSound(humanoid: Humanoid, humanoidRootPart: HumanoidRootPart)
    local floorMaterial = humanoid.FloorMaterial
    local sound = config.materialSounds[floorMaterial] or config.fallbackSound
    humanoidRootPart:WaitForChild("Running").Asset = sound
end

local function onCharacterAdded(character: Model)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: HumanoidRootPart
    local humanoid = character:FindFirstChildWhichIsA("Humanoid") :: Humanoid

    local heartbeatConn = RunService.Heartbeat:Connect(function()
        updateSoundSpeedAndVolume(humanoid, humanoidRootPart)
    end)

    humanoid.Destroying:Once(function()
        heartbeatConn:Disconnect()
    end)

    humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
        updateSound(humanoid, humanoidRootPart)
    end)
    updateSound(humanoid, humanoidRootPart)
end

--[=[
    @param material Material

    Sets the sound for the passed `material` to be `sound` where if `sound` is nil then the fallback sound is used, this by default is
    the normal roblox walking sound however this can be overrided with [LifelikeCharactersServiceClient.changeFallbackSound].
]=]
function FootStepSystem.updateSoundForMaterial(material: Enum.Material, sound: string?)
    config.materialSounds[material] = sound
end

--[=[
    Change the default footstep sound that is used when a [Material] doesnt have a sound set.
]=]
function FootStepSystem.changeFallbackSound(sound: string)
    config.fallbackSound = sound
end

--[=[
    Connects the needed events.
]=]
function FootStepSystem.setupFootsteps()
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

return FootStepSystem
