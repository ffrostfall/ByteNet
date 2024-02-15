local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

--[[ReplicatedStorage.RemoteEvent.OnClientEvent:Connect(function(data)
	--print(data)
end)]]

testPackets.a:listen(function()
	--print("Confirming server -> client")
	--print(data)
end)

task.wait(2)

testPackets.a:send({
	a = true,
	b = { true, false, true, false, false, true },
	c = { { false }, { true } },
	d = true,
	chained = "test",
})
