--!strict
--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local testPackets = require(ReplicatedStorage.shared.testPackets)

--[[local data = {
	a = false,
	b = { true, false, false },
	c = { { false }, { true } },
	d = nil,
	e = { [8] = 4 },
	f = {
		[Vector3.new(15, 15, 15)] = 2554,
	},
}]]

local out = {}
for _ = 1, 1000 do
	table.insert(out, if math.random(1, 2) == 1 then true else false)
end

RunService.Heartbeat:Connect(function()
	--[[[for _ = 1, 100 do
		ReplicatedStorage.RemoteEvent:FireAllClients(data)
	end]]

	debug.profilebegin("send")
	for _ = 1, 1000 do
		--ReplicatedStorage.RemoteEvent:FireAllClients(out)
		testPackets.myPacket.sendToAll(out)
	end
	debug.profileend()
end)

Players.PlayerAdded:Connect(function()
	task.wait(1)
	--testPackets.myPacket.sendToAll()
end)

testPackets.myPacket.listen(function(a)
	print("Confirming client -> server")
	print(a)
end)
