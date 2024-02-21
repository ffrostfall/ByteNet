local types = require(script.Parent.Parent.types)
local packet = require(script.Parent.packet)

return function(props: types.packetProps<any>)
	return function(id: number)
		return packet(props, id)
	end
end
