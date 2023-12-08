local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local testPackets = require(ReplicatedStorage.shared.testPackets)

testPackets.a:listen(function(data)
	print(data)
end)

RunService.Heartbeat:Connect(function()
	for _ = 1, 200 do
		-- Roblox
		--[[ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer({
			1,
			"test",
		} :: { any })]]

		-- ByteNet
		testPackets.a:send({ first = "test", second = 1 })
	end
end)
