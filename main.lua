--[[
Main file
]]
function love.run() end

_args = require "cmp.args"

local checkInclude = require "cmp.check_include"
local combineCode  = require "cmp.combine_code"
local deleteOld    = require "cmp.delete_old"
local enumFiles    = require "cmp.enum_files"
local fs           = require "cmp.file_system"
local foldCode     = require "cmp.fold_code"
local log          = require "cmp.log"

if _args.help or not fs.isDir("in") then
	return print [[
love . [args]

Put your project in a folder called "in" located in the same directory as this
tool's main.lua and run this.

--help:      Display help.
--nofold:    Disables constant folding and removal of code marked to be excluded.
--nocombine: Do not combine code files.
]]
end

local utf8 = require "utf8"

deleteOld()

local ensureParent = function(outpath)
	local parent = string.match(outpath, "^(.*)[/\\].-$") or ""

	if not fs.isDir(parent) then
		fs.newDir(parent)
	end
end

fs.newDir("out")
love.filesystem.write("out/main.lua", string.dump(loadstring("")))

local codeList = {}

-- Iterate over all files
for _, path in pairs(enumFiles("in")) do
	outpath = "out/" .. path
	inpath = "in/" .. path

	if path:find("!") then
		-- Files including ! are excluded.
	elseif path:find("%.lua$") then
		-- Compile Lua file
		if not _args.nocombine and checkInclude(path) then
			log(">><\t" .. path)

			codeList[#codeList + 1] = {
				filepath = path,
				code = foldCode(inpath)
			}
		else
			log("~#~\t" .. path)
			local foldedCode = foldCode(inpath)
			local compiledChunk, errormsg = loadstring(foldedCode, path)

			if compiledChunk ~= nil then
				ensureParent(outpath)

				local dumpedChunk = string.dump(compiledChunk)
				love.filesystem.write(outpath, dumpedChunk)
			else
				log(errormsg)
			end
		end
	else
		ensureParent(outpath)

		-- Copy other files
		log("+++\t" .. path)

		local d = love.filesystem.newFileData(inpath)
		if not love.filesystem.write(outpath, d) then
			log("Could not copy " .. path .. "!?")
		end
	end
end

if not _args.nocombine then
	local totalCode = combineCode(codeList)

	log("Compiling Code...")

	love.filesystem.write("game.compiled.lua", totalCode)
	local compiledChunk, errormsg = love.filesystem.load("game.compiled.lua")

	if compiledChunk ~= nil then
		local dumpedChunk = string.dump(compiledChunk)
		love.filesystem.write("out/conf.lua", dumpedChunk)
	else
		log(errormsg)
	end
end

love.filesystem.write("log.txt", table.concat(log, "\n"))
