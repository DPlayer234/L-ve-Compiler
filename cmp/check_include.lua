--[[
Returns a function to check whether or not to include a compiled file
]]
local fs = require "cmp.file_system"

local dontCompile = {}

if fs.isFile("in/.ignore") then
	-- Escape pattern characters
	local patternEscape = function(s)
		return "%" .. s
	end

	-- Wild-cards
	local wildCard = function(s)
		return "." .. s
	end

	local escape = function(card)
		return "^" .. card:gsub("[%.%[%]%(%)%^%$%%]", patternEscape):gsub("[%*%+%-%?]", wildCard) .. "$"
	end

	for line in love.filesystem.lines("in/.ignore") do
		dontCompile[#dontCompile + 1] = escape(line)
	end
end

-- Function to check whether or not to compile
return function(path)
	for i=1, #dontCompile do
		if path:match(dontCompile[i]) then
			return false
		end
	end
	return true
end
