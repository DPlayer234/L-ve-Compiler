--[[
Logging function
]]
return setmetatable({}, {
	__call = function(t, value)
		print(value)
		table.insert(t, tostring(value))
	end
})
