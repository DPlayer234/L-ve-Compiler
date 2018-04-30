--[[
Main file
]]
local utf8 = require "utf8"

local combineCode = require "combine_code"
local deleteOld = require "delete_old"
local enumFiles = require "enum_files"
local fs = require "file_system"
local foldCode = require "fold_code"
local log = require "log"

deleteOld()

local dontCompile = {}

if fs.isFile("in/_ignore.txt") then
	for line in love.filesystem.lines("in/_ignore.txt") do
		dontCompile[#dontCompile + 1] = line
	end
end

local doCompile = function(path)
	for i=1, #dontCompile do
		if path:match(dontCompile[i]) then
			return false
		end
	end
	return true
end

local ensureParent = function(outpath)
	local parent = string.match(outpath, "^(.*)[/\\].-$") or ""

	if not fs.isDir(parent) then
		fs.newDir(parent)
	end
end

fs.newDir("out")
love.filesystem.write("out/main.lua", "")

local codeList = {}

-- Iterate over all files
for k,v in pairs(enumFiles("in")) do
	outpath = "out/"..v
	inpath = "in/"..v

	if v:find("!") then
		-- Files including ! are excluded.
	elseif v:find("%.lua$") then
		-- Read Lua file
		log("~#~\t"..v)

		if doCompile(v) then
			codeList[#codeList + 1] = {
				filepath = v,
				code = foldCode(inpath)
			}
		else
			local compiledChunk, errormsg = love.filesystem.load(inpath)

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
		log("+++\t"..v)

		local d = love.filesystem.newFileData(inpath)
		if not love.filesystem.write(outpath, d) then
			log("Could not copy "..v.."!?")
		end
	end
end

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

love.filesystem.write("log.txt", table.concat(log, "\n"))

function love.run() end
