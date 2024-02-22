local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local replicatedValuePrototype = {}
local replicatedValueMetatable = { __index = replicatedValuePrototype }
export type replicatedValueType = typeof(setmetatable(
	{} :: {
		_luauData: {},
		_value: StringValue,
	},
	replicatedValueMetatable
))

function replicatedValuePrototype.write(self: replicatedValueType, value: {})
	assert(runContext == "server", "cannot write to replicatdvalue on client")

	self._luauData = value

	-- self._value.Value :(
	self._value.Value = HttpService:JSONEncode(value)
end

function replicatedValuePrototype.read(self: replicatedValueType)
	return self._luauData
end

return function(valueObject: StringValue): replicatedValueType
	local self = setmetatable({}, replicatedValueMetatable)

	self._luauData = {}
	self._value = valueObject

	-- important note: We freeze the table on the client to ensure that it never is modified
	-- We initialize _luauData as an empty table because on the server, we don't need to freeze it.
	if runContext == "client" then
		self._luauData = table.freeze(HttpService:JSONDecode(valueObject.Value))

		valueObject.Changed:Connect(function(value: string)
			if not value then
				return
			end

			self._luauData = table.freeze(HttpService:JSONDecode(value))
		end)
	end

	return self
end
