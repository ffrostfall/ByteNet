local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	testPackets.a:send({ testing = math.random(1, 16), testing2 = math.random(1, 16) }, player)
	testPackets.b:send({ testing3 = math.random(1, 16), testing4 = math.random(1, 16), testingaa = false }, player)
	testPackets.c:send({ testing5 = math.random(1, 16), testing6 = math.random(1, 16), testingbb = "testing" }, player)
	testPackets.d:send({ testing7 = math.random(1, 16), testing8 = math.random(1, 16) }, player)
end)

testPackets.a:listen(function(data)
	print(data)
end)

testPackets.b:listen(function(data)
	print(data)
end)

testPackets.c:listen(function(data)
	print(data)
end)

testPackets.d:listen(function(data)
	print(data)
end)
