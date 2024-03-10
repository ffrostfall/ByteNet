--!native
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testPackets = require(ReplicatedStorage.shared.testPackets)

--ReplicatedStorage.RemoteEvent.OnClientEvent:Connect(function()
--print(data)
--end)

testPackets.myPacket.listen(function(_)
	--print("Confirming server -> client")
	--print(data)
end)
--
task.wait(2)
