local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

testPackets.a:listen(function(data)
	print("Confirming server -> client")
	print(data)
end)

task.wait(2)

testPackets.a:send({
	first = "hello world",
	second = 5,
})
