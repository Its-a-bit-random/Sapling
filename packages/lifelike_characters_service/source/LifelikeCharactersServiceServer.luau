local Players = game:GetService("Players")

local Network = require(script.Parent.modules.Network)

local isSetup = false
local isReplicationEnabled = true

--[=[
    @class LifelikeCharactersServiceServer
    @server

    Can be accessed via [LifelikeCharactersService.getServer].

    Handles the replication of character's head rotations.
]=]
local LifelikeCharactersServiceServer = {}

--[=[
    Disable replication of character's head rotations between all players in the game.
]=]
function LifelikeCharactersServiceServer.disableReplication()
    isReplicationEnabled = false
end

--[=[
    Enable replication of character's head rotations between all players in the game.
]=]
function LifelikeCharactersServiceServer.enableReplication()
    isReplicationEnabled = true
end

--[=[
    @private
    This function is called for you when the package starts. You do NOT need to call this.
    
    If you call this function it will error.
]=]
function LifelikeCharactersServiceServer.setup()
    assert(not isSetup, "Setup has already been called")
    isSetup = true

    Network.UpdateLookAnglesRemote.OnServerEvent:Connect(function(player: Player, buf: buffer)
        if not isReplicationEnabled then
            return
        end

        if typeof(buf) ~= "buffer" then
            return
        end

        if buffer.len(buf) < 4 then
            return
        end

        local yAngle, xAngle = Network.desLookAngles(buf)

        -- This is just here to stop players sending garbage data through the event. It clamps between 1 and -1 instead of actually the bounds we want, we do that client side.
        local newBuf = Network.serLookAngles(math.clamp(yAngle, -1, 1), math.clamp(xAngle, -1, 1))

        for _, v in Players:GetPlayers() do
            if v.UserId == player.UserId then
                continue
            end
            Network.UpdateLookAnglesRemote:FireClient(v, player.Character, newBuf)
        end
    end)
end

return LifelikeCharactersServiceServer
