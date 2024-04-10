local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packets = require(ReplicatedStorage.shared.packets)

packets.test.listen(function(a, b)
	--print(a, b)
end)
