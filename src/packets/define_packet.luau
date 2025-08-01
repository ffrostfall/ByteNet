--!native
--!optimize 2

--[[
	Exists so that the namespace can set the ID of the packet

	Packet shouldnt need to care about making its own ID
]]
local packet = require("./packet")
local types = require("../types")

@native
local function define_packet(props: types.PacketProps<any>)
	return @native function(id: number)
		return packet(props, id)
	end
end

return define_packet
