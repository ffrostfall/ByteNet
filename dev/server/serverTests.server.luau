--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local testPackets = require(ReplicatedStorage.shared.testPackets)

local data = {
	a = false,
	b = { true, false, false },
	c = { { false }, { true } },
	d = nil,
	e = { [8] = 4 },
	f = {
		[Vector3.new(15, 15, 15)] = 2554,
	},
}

RunService.Heartbeat:Connect(function()
	debug.profilebegin("send")
	for _ = 1, 100 do
		testPackets.a:sendToAll(data)
	end
	debug.profileend()
end)

Players.PlayerAdded:Connect(function()
	task.wait(1)
	testPackets.a:sendToAll({
		a = false,
		b = { true, false, false },
		c = { { false }, { true } },
		d = nil,
		e = { [8] = 4 },
		f = {
			[Vector3.new(15, 15, 15)] = 2554,
		},
	})
end)

testPackets.a:listen(function(a)
	print("Confirming client -> server")
	print(a)
end)
