local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	testPackets.a:send({ first = "testB", second = math.random(1, 8) }, player)
end)

testPackets.a:listen(function(data)
	print("Confirming client -> server")
	print(data)
end)
