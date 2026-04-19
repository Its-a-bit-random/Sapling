local cameraOffset = 0

local FirstPersonBody = {}

function FirstPersonBody.setOffset(offset: number)
    cameraOffset = offset
end

function FirstPersonBody.makeCharacterVisible(character: Model)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid == nil then
        return
    end

    humanoid.CameraOffset = Vector3.new(0, 0, cameraOffset)

    local characterParts = {
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
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        "Torso",
    }

    for _, limb in character:GetChildren() do
        if limb:IsA("BasePart") then
            if table.find(characterParts, limb.Name) then
                limb.LocalTransparencyModifier = 0
            end
        end
    end
end

return FirstPersonBody
