local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local packets = require(ReplicatedStorage.shared.packets)

local testSender = packets.test.send

RunService.Heartbeat:Connect(function()
	debug.profilebegin("send")
	for _ = 1, 10 do
		testSender({ true, false })
	end
	debug.profileend()
end)
