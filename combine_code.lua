--[[
This returns a function which combines a table of code-strings into a larger code-string
]]
local BASE = {}

BASE.TOP = [[
------------------------------------
-- Computer Generated Merged Code --
------------------------------------

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
				local path = PACKAGE[i]:gsub("%?", modulePath)
				local file = virtual[path]

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
	-- Inject love.filesystem.load to check the virtual files.
	local love_filesystem_load = love.filesystem.load
	local love_filesystem_getInfo = love.filesystem.getInfo

	love.filesystem.load = function(filepath)
		local file = virtual[filepath]

		if file ~= nil then
			return file()
		end

		return love_filesystem_load(filepath)
	end

	love.filesystem.getInfo = function(filepath, filter)
		local file = virtual[filepath]

		if file ~= nil and (filter == "file" or filter == nil) then
			return {
				type = "file",
				size = 0,
				modtime = 0
			}
		end

		return love_filesystem_getInfo(filepath, filter)
	end
end

return virtual["conf.lua"]()()
]]

BASE.FOREACH = [[
[%q] = function()
	return function(...)
		%s
	end
end,
]]

-- The actual function doing the work
-- My lord.
return function(codeList)
	local totalCode = {}

	totalCode[#totalCode + 1] = BASE.TOP

	for i=1, #codeList do
		totalCode[#totalCode + 1] = BASE.FOREACH:format(codeList[i].filepath, codeList[i].code)
	end

	totalCode[#totalCode + 1] = BASE.BOTTOM

	return table.concat(totalCode, "\r\n")
end
