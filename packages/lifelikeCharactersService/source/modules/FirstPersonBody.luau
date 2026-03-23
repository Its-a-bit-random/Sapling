local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local FirstPersonBody = {}

function FirstPersonBody.makeCharacterVisible()
	local character = player.Character
	if character == nil then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	humanoid.CameraOffset = Vector3.new(0, 0, -0.5)

	if character then
		local tab = {
			"LowerTorso",
			"UpperTorso",
			"RightFoot",
			"LeftLowerArm",
			"LeftFoot",
			"LeftLowerLeg",
			"RightLowerArm",
			"LeftHand",
			"LeftUpperArm",
			"RightUpperLeg",
			"RightUpperArm",
			"RightHand",
			"LeftUpperLeg",
			"RightLowerLeg",
		}

		for i, limb in character:GetChildren() do
			if limb:IsA("BasePart") then
				if table.find(tab, limb.Name) then
					limb.Transparency = 0
					limb.LocalTransparencyModifier = 0
				end
			end
		end
	end
end

function FirstPersonBody.setup()
	RunService:BindToRenderStep("FirstPerson", Enum.RenderPriority.Camera.Value, FirstPersonBody.makeCharacterVisible)
end

return FirstPersonBody
