local RunService = game:GetService("RunService")

local function getRemote(name: string)
    return script:FindFirstChild(name)
end

local function doesRemoteExist(name: string)
    return getRemote(name) ~= nil
end

local function getRemoteServer(name: string)
    if not doesRemoteExist(name) then
        local remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = script
    end

    return getRemote(name) :: RemoteEvent
end

local function getRemoteClient(name: string)
    return script:WaitForChild(name) :: RemoteEvent
end

return function(name: string)
    if RunService:IsServer() then
        return getRemoteServer(name)
    end

    return getRemoteClient(name)
end
