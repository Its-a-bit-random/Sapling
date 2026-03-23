local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FirstPersonBody = require(script.Parent.modules.FirstPersonBody)
local FootstepSystem = require(script.Parent.modules.FootstepSystem)
local HeadSystem = require(script.Parent.modules.HeadSystem)
local getRemote = require(script.Parent.modules.getRemote)

local isSetup = false
local player = Players.LocalPlayer

--[=[
    @class LifelikeCharactersServiceClient
    @client

    Can be accessed via [LifelikeCharactersService.getClient].
]=]
local LifelikeCharactersServiceClient = {}

--[=[
	[HeadSystem.setCustomHeadOffset]
]=]
function LifelikeCharactersServiceClient.setCustomHeadOffset(headOffset: number?)
	HeadSystem.setCustomHeadOffset(headOffset)
end

--[=[
    @param material Material

    Sets the sound for the passed `material` to be `sound` where if `sound` is nil then the fallback sound is used, this by default is
    the normal roblox walking sound however this can be overrided with [LifelikeCharactersServiceClient.changeFallbackSound].
]=]
function LifelikeCharactersServiceClient.updateSoundForMaterial(material: Enum.Material, sound: string?)
	FootstepSystem.updateSoundForMaterial(material, sound)
end

--[=[
    Change the default footstep sound that is used when a [Material] doesnt have a sound set.
]=]
function LifelikeCharactersServiceClient.changeFallbackSound(sound: string)
	FootstepSystem.changeFallbackSound(sound)
end

--[=[
    @private
    This function is called for you when the package starts. You do NOT need to call this.
    
    If you call this function it will error.
]=]
function LifelikeCharactersServiceClient.setup()
	assert(not isSetup, "Setup has already been called")
	isSetup = true
	FootstepSystem.setupFootsteps()

	RunService:BindToRenderStep("FirstPerson", Enum.RenderPriority.Camera.Value, FirstPersonBody.makeCharacterVisible)

	local updateLookAnglesRemote = getRemote("UpdateLookAngles")
	updateLookAnglesRemote.OnClientEvent:Connect(function(character: Model, yAngle: number, xAngle: number)
		if character == nil then
			return
		end
		HeadSystem.updateLookAngles(character, yAngle, xAngle)
	end)

	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if character == nil then
			return
		end

		local camera = Workspace.CurrentCamera
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: Part

		local cameraDireaction = humanoidRootPart.CFrame:ToObjectSpace(camera.CFrame).LookVector
		local yAngle = -math.asin(cameraDireaction.X)
		local xAngle = math.asin(cameraDireaction.Y)
		HeadSystem.updateLookAngles(character, yAngle, xAngle)
		updateLookAnglesRemote:FireServer(yAngle, xAngle)
	end)
end

return LifelikeCharactersServiceClient
