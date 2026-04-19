local getRemote = require(script.Parent.getRemote)

local function packFloatSigned(v)
    return math.floor(math.clamp(v, -1, 1) * 32767 + 0.5)
end

local function unpackFloatSigned(v)
    return v / 32767
end

--[=[
    @class Network
    Simple network interface with serdes.
]=]
local Network = {}

--[=[
    @prop UpdateLookAnglesRemote RemoteEvent
    @within Network
]=]
Network.UpdateLookAnglesRemote = getRemote("UpdateLookAngles")

--[=[
	Encode look angles into a buffer.
]=]
function Network.serLookAngles(yAngle: number, xAngle: number)
    local buf = buffer.create(4)
    buffer.writei16(buf, 0, packFloatSigned(xAngle))
    buffer.writei16(buf, 2, packFloatSigned(yAngle))
    return buf
end

--[=[
	Decode look agnles from buffer.
]=]
function Network.desLookAngles(buf: buffer): (number, number)
    local x = unpackFloatSigned(buffer.readi16(buf, 0))
    local y = unpackFloatSigned(buffer.readi16(buf, 2))
    return y, x
end

return Network
