local types = require("../types")

local channel_state: types.ChannelState = {
	buff = buffer.create(0),
	ref_map = {},
	cursor = 0,
}

return channel_state
