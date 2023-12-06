return function(packetStructure: { [string]: any })
	local unique = ""

	for key in packetStructure do
		unique ..= key
	end

	return unique
end
