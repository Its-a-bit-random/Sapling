local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FirstPersonBody = require(script.Parent.modules.FirstPersonBody)
local FootstepSystem = require(script.Parent.modules.FootstepSystem)
local HeadSystem = require(script.Parent.modules.HeadSystem)
local Network = require(script.Parent.modules.Network)

local isSetup = false
local player = Players.LocalPlayer
local firstPersonOffset = -1.5

local headReplication = {
    rate = 1 / 30,
    lastSent = 0,
    lastXAngleSent = 0,
    lastYAngleSent = 0,
}

--[=[
    @class LifelikeCharactersServiceClient
    @client

    Can be accessed via [LifelikeCharactersService.getClient].
]=]
local LifelikeCharactersServiceClient = {}

--[=[
	Override the head replication rate, by default the rate is `1/20`.

	:::warning
	You shouldn't mess with this too much as higher values can cause bandwidth issues.
	:::
]=]
function LifelikeCharactersServiceClient.setHeadRotationReplicationRate(rate: number)
    headReplication.rate = rate
end

--[=[
	Sets how far farward the camera will be in first person compared to normal. Note that
	the negative scale is farward relative to the head.
]=]
function LifelikeCharactersServiceClient.setFirstPersonOffset(offset: number)
    firstPersonOffset = offset
end

--[=[
	[HeadSystem.setBounds]
]=]
function LifelikeCharactersServiceClient.setHeadRotationClampValues(lower: number?, upper: number?)
    HeadSystem.setBounds(lower, upper)
end

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

    RunService:BindToRenderStep("FirstPerson", Enum.RenderPriority.Camera.Value + 1, function()
        local character = player.Character
        if character == nil then
            return
        end

        FirstPersonBody.makeCharacterVisible(character)

        local distance = (character.Head.Position :: Vector3 - Workspace.CurrentCamera.CFrame.Position).Magnitude
        if distance <= 1.6 then
            FirstPersonBody.setOffset(firstPersonOffset)
        else
            FirstPersonBody.setOffset(0)
        end
    end)

    Network.UpdateLookAnglesRemote.OnClientEvent:Connect(function(character: Model, buf: buffer)
        if character == nil then
            return
        end
        local yAngle, xAngle = Network.desLookAngles(buf)
        HeadSystem.updateLookAngles(character, yAngle, xAngle)
    end)

    local count = 0
    RunService.Heartbeat:Connect(function(dt)
        count += dt

        local character = player.Character
        if character == nil then
            return
        end

        local camera = Workspace.CurrentCamera
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: Part

        local yAngle, xAngle = HeadSystem.calculateLookAngles(camera.CFrame, humanoidRootPart.CFrame)
        HeadSystem.updateLookAngles(character, yAngle, xAngle)

        if count >= headReplication.rate then
            if headReplication.lastXAngleSent == xAngle or headReplication.lastYAngleSent == yAngle then
                return
            end
            Network.UpdateLookAnglesRemote:FireServer(Network.serLookAngles(yAngle, xAngle))
            headReplication.lastXAngleSent, headReplication.lastYAngleSent = xAngle, yAngle
        end
    end)
end

return LifelikeCharactersServiceClient
