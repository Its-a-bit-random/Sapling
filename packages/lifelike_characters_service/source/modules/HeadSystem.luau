local NECK_MOTOR_NAME = "__NECK_MOTOR__"
local R15_HEAD_OFFSET = 1.2
local R6_HEAD_OFFET = 1.4

local customOffset: number?
local customLowerBound: number?
local customUpperBound: number?

local function createNeckMotor(character: Model)
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if head == nil or torso == nil or humanoid == nil then
        return
    end

    local offset = if humanoid.RigType.Name == "R6" then R6_HEAD_OFFET else R15_HEAD_OFFSET
    if customOffset ~= nil then
        offset = customOffset
    end

    local motor = Instance.new("Motor6D")
    motor.Name = NECK_MOTOR_NAME
    motor.Part0 = torso
    motor.Part1 = head
    motor.C0 = CFrame.new(0, offset, 0)
    motor.Parent = character
end

local function getNeckMotor(character: Model)
    return character:FindFirstChild(NECK_MOTOR_NAME)
end

--[=[
	@class HeadSystem
	@client
	Handles [Motor6D] objects to control neck rotations.
]=]
local HeadSystem = {}

--[=[
	Sets a custom offset for the head. By default the system can handle R6 and R15 rigs automatically however when using
	custom rigs then you can use this function to set a custom offset. If `headoffset` defualt behaviour is restored.
]=]
function HeadSystem.setCustomHeadOffset(headOffset: number?)
    customOffset = headOffset
end

--[=[
	Sets the clamping values of how far the head can look up and down. Set to nil for default behaviour.
]=]
function HeadSystem.setBounds(lower: number?, upper: number?)
    customLowerBound, customUpperBound = lower, upper
end

--[=[
	Calculates the head look angles from the given `cameraCFrame` in relation to the `rootCFrame`.
]=]
function HeadSystem.calculateLookAngles(cameraCFrame: CFrame, rootCFrame: CFrame): (number, number)
    local cameraDireaction = rootCFrame:ToObjectSpace(cameraCFrame).LookVector
    local yAngle = -math.asin(cameraDireaction.X)
    local xAngle = math.clamp(math.asin(cameraDireaction.Y), customLowerBound or -0.5, customUpperBound or 0.9)
    return yAngle, xAngle
end

--[=[
	Updates the head rotation for the `character`, the `yAngle` and `xAngle` should be normalized and everything before
	being passed into this function.
]=]
function HeadSystem.updateLookAngles(character: Model, yAngle: number, xAngle: number)
    local neckMotor = getNeckMotor(character)
    if neckMotor == nil then
        createNeckMotor(character)
        neckMotor = getNeckMotor(character)
        if neckMotor == nil then
            return
        end
    end

    local head = character:FindFirstChild("Head")
    head.CanCollide = true

    local yOffset = neckMotor.C0.Y
    neckMotor.C0 = CFrame.new(0, yOffset, 0) * CFrame.Angles(0, yAngle, 0) * CFrame.Angles(xAngle, 0, 0)
end

return HeadSystem
