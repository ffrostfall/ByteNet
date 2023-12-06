local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

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

testPackets.a:send({ testing = math.random(1, 16), testing2 = math.random(1, 16) })
testPackets.b:send({ testing3 = math.random(1, 16), testing4 = math.random(1, 16), testingaa = false })
testPackets.c:send({ testing5 = math.random(1, 16), testing6 = math.random(1, 16) })
testPackets.d:send({ testing7 = math.random(1, 16), testing8 = math.random(1, 16) })
