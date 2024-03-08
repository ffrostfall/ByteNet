--!native
--!optimize 2

--[[
	Exists so that the namespace can set the ID of the packet

	Packet shouldnt need to care about making its own ID
]]
local types = require(script.Parent.Parent.types)
local packet = require(script.Parent.packet)

return function(props: types.packetProps<any>)
	return function(id: number)
		return packet(props, id)
	end
end
