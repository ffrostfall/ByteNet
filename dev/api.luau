local RunService = game:GetService("RunService")

local ByteNet: any = ...

RunService.Heartbeat:Connect(function()
	ByteNet.frame.receive()

	-- Game here

	ByteNet.frame.send()
end)
