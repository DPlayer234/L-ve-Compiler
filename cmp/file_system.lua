--[[
Basic filesystem functions
]]
return {
	isDir  = function(path) return love.filesystem.getInfo(path, "directory") ~= nil end,
	isFile = function(path) return love.filesystem.getInfo(path, "file") ~= nil end,
	getDir = love.filesystem.getDirectoryItems,
	newDir = love.filesystem.createDirectory
}
