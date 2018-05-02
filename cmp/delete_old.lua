--[[
Deletes the old files
]]
local fs = require "cmp.file_system"

local function recursivelyDelete(item, depth)
	if fs.isDir(item) then
		for _, child in pairs(fs.getDir(item)) do
			recursivelyDelete(item .. '/' .. child, depth + 1);
			love.filesystem.remove(item .. '/' .. child);
		end
	elseif fs.isFile(item) then
		love.filesystem.remove(item);
	end
	love.filesystem.remove(item)
end

return function()
	if fs.isDir("out") then recursivelyDelete("out", 0) end
end
