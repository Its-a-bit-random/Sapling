------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CloneTrooper1019, 2020
-- Realism Server
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local getRemote = require(script.Parent.Parent.modules.getRemote)

local setLookAngles = getRemote("SetLookAngles")

local function onReceiveLookAngles(player, pitch, yaw)
	if typeof(pitch) ~= "number" or pitch ~= pitch then
		return
	end

	if typeof(yaw) ~= "number" or yaw ~= yaw then
		return
	end

	pitch = math.clamp(pitch, -1, 1)
	yaw = math.clamp(yaw, -1, 1)

	setLookAngles:FireAllClients(player, pitch, yaw)
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 10)

	if humanoid and humanoid:IsA("Humanoid") then
		CollectionService:AddTag(humanoid, "RealismHook")
	end
end

local function onPlayerAdded(player)
	if player.Character then
		onCharacterAdded(player.Character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

local Server = {}

function Server.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	setLookAngles.OnServerEvent:Connect(onReceiveLookAngles)
end

return Server

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
