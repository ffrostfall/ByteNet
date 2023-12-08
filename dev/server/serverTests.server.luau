local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

local t = Instance.new("RemoteEvent")

t.Parent = ReplicatedStorage

t.OnServerEvent:Connect(function() end)

Players.PlayerAdded:Connect(function()
	--[[task.wait(1)
	testPackets.a:send({ first = "testB", second = math.random(1, 8) }, player)]]
end)

testPackets.a:listen(function()
	--print(data)
end)
