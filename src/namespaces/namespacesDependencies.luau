--[[
	Basic dependency graph for structs created within a namespace
]]

local current: { [number]: any }?
local currentName: string

local namespacesDependencies = {}

function namespacesDependencies.start(name: string)
	current = {} :: { [number]: any }
	currentName = name
end

function namespacesDependencies.add(data)
	if not current then
		return
	end

	table.insert(current, data)
end

function namespacesDependencies.currentLength()
	return if current then #current else 0
end

function namespacesDependencies.currentName()
	return currentName
end

function namespacesDependencies.empty(): { [number]: any }
	if current == nil then
		return {}
	end

	local result = current
	current = nil

	return result
end

return namespacesDependencies
