--[[
This returns a function which combines a table of code-strings into a larger code-string
]]
local BASE = {}

BASE.TOP = [[
------------------------------------------
----- Computer Generated Merged Code -----
------------------------------------------
local _COMPILED = true

-- A table of functions, returning functions
local virtual = {
]]

BASE.BOTTOM = [[
}

-- Add a metatable to package.loaded to load the virtual files.
do
	-- Require paths
	local PACKAGE = {
		"?.lua",
		"?/init.lua"
	}

	-- Set metatable and __index method
	setmetatable(package.preload, {
		__index = function(preload, module)
			-- Adjust module name
			local modulePath = module:gsub("[%./\\]+", "/")

			for i=1, #PACKAGE do
				local filePath = PACKAGE[i]:gsub("%?", modulePath)
				local file = virtual[filePath]

				-- Load module if there is any
				if file ~= nil then
					return file()
				end
			end

			return nil
		end
	})
end

do
	local filesystem = require "love.filesystem"

	-- Inject love.filesystem.load to check the virtual files.
	local filesystem_load = filesystem.load
	local filesystem_getInfo = filesystem.getInfo

	filesystem.load = function(filePath)
		local file = virtual[filePath]

		if file ~= nil then
			return file()
		end

		return filesystem_load(filePath)
	end

	filesystem.getInfo = function(filePath, filter)
		local file = virtual[filePath]

		if file ~= nil and (filter == "file" or filter == nil) then
			return {
				type = "file",
				size = 0,
				modtime = 0
			}
		end

		return filesystem_getInfo(filePath, filter)
	end
end
]]

BASE.RETURN = [[
-- Resume execution of main file
return virtual[%q]()()
]]

BASE.FOREACH = [[
[%q] = function() return function(...)
----------------------------------------------------------------------------------------------------
--=== % -88s ===--
----------------------------------------------------------------------------------------------------
%s
----------------------------------------------------------------------------------------------------
end end,
]]

-- The actual function doing the work
-- My lord.
return function(codeList, mainFile)
	local totalCode = {}

	totalCode[#totalCode + 1] = BASE.TOP

	for i=1, #codeList do
		totalCode[#totalCode + 1] = BASE.FOREACH:format(codeList[i].filepath, codeList[i].filepath, codeList[i].code)
	end

	totalCode[#totalCode + 1] = BASE.BOTTOM

	totalCode[#totalCode + 1] = BASE.RETURN:format(mainFile)

	return table.concat(totalCode, "\r\n")
end
