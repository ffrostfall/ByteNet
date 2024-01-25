local RunService = game:GetService("RunService")

return if RunService:IsServer() then "server" else "client"
