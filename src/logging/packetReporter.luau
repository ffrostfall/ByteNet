local formatter = require(script.Parent.formatter)
local packetReporterPrototype = {}
local packetReporterMetatable = { __index = packetReporterPrototype }
export type packetReporterType = typeof(setmetatable({} :: {
	_id: number,
}, packetReporterMetatable))

function packetReporterPrototype.error(self: packetReporterType, message: string)
	error(formatter(`{"packet" .. self._id} {message}`), 3)
end

function packetReporterPrototype.raiseTypeError(
	self: packetReporterType,
	key: string,
	expectedType: string,
	actualType: string
)
	self:error(`Expected key {key} to be {expectedType}, but got {actualType} instead.`)
end

function packetReporterPrototype.raiseBoundsError(self: packetReporterType, key, min, max, value)
	self:error(`Expected key {key} to be within the bounds of {min} and {max}, but got {value} instead.`)
end

return function(packetID: number): packetReporterType
	local self = setmetatable({}, packetReporterMetatable)

	self._id = packetID

	return self
end
