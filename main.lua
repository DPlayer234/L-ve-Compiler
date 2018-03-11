local getmetatable, ipairs, pairs, print, pcall, love = getmetatable, ipairs, pairs, print, pcall, love

-- If true, will keep the modified Lua source files instead of immediately deleting them
local KEEP_STRIPPED = true

--[[
Remove old files
]]
do
	local function recursivelyDelete(item, depth)
		if love.filesystem.isDirectory(item) then
			for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
				recursivelyDelete(item .. '/' .. child, depth + 1);
				love.filesystem.remove(item .. '/' .. child);
			end
		elseif love.filesystem.isFile(item) then
			love.filesystem.remove(item);
		end
		love.filesystem.remove(item)
	end

	if love.filesystem.isDirectory("out") then recursivelyDelete("out", 0) end
	if love.filesystem.isDirectory("code") then recursivelyDelete("code", 0) end
end
love.filesystem.createDirectory("out")
love.filesystem.createDirectory("code")

local isDir = love.filesystem.isDirectory
local getDir = love.filesystem.getDirectoryItems
local newDir = love.filesystem.createDirectory
local utf8 = require "utf8"

-- Gets a list of files in a directory
local function enum(path, cont, orig)
	if not cont then cont = {} end
	if not orig then orig = "^"..path.."/" end
	for k,v in pairs(getDir(path)) do
		local fullpath = path.."/"..v
		if isDir(fullpath) then
			enum(fullpath, cont, orig)
		else
			local ins = fullpath:gsub(orig,"")
			table.insert(cont, ins)
		end
	end
	return cont
end

-- Logging functions
local log = setmetatable({}, {
	__call = function(t, value)
		print(value)
		table.insert(t, tostring(value))
	end
})

-- Iterate over all files
for k,v in pairs(enum("in")) do
	outpath = "out/"..v
	inpath = "in/"..v

	local parent = string.match(outpath, "^(.*)[/\\].-$") or ""
	if not isDir(parent) then
		newDir(parent)
	end

	if v:find("!") then
		-- Files including ! are excluded.
	elseif v:find("%.lua$") then
		-- Compile lua file
		log("~#~\t"..v)

		local s, data = pcall(function()
			local include = true

			local constants = {}

			-- Replace constants in line
			local function replaceConstants(line)
				if not (line:find("^%s*$")) then
					local depth = #line:match("^(%s*)")
					for i=#constants, 1, -1 do
						local v = constants[i]

						if v.depth > depth then
							table.remove(constants, i)
						else
							local a, b = 0, 0
							repeat
								a, b = line:find(v.name, b + 1)

								if a then
									local charA, charB = line:sub(a - 1, a - 1), line:sub(b + 1, b + 1)
									if not (charA:find("[_a-zA-Z0-9]")) and not (charB:find("[_a-zA-Z0-9]")) then
										line = line:sub(1, a - 1) .. v.value .. line:sub(b + 1, #line)
									end
								end
							until not a
						end
					end
				end

				return line
			end

			local content = {}
			for line in love.filesystem.lines(inpath) do
				if (line:find("%-%-#")) then
					-- Special directives
					if (line:find("%-%-#exclude line")) then
						line = ""
					elseif (line:find("%-%-#exclude start")) then
						include = false
					elseif (line:find("%-%-#exclude end")) then
						include = true
					elseif (line:find("%-%-#const")) then
						local depth, name, value = replaceConstants(line):match("^(%s*)local ([_a-zA-Z0-9]+)%s*=%s*(.-)%s*%-%-#const%s*$")
						if name == "const" then
							log("Constant variable name cannot be 'const'.")
						elseif name and value then
							local s, r = pcall(function()
								local v = load("return " .. value)()
								if type(v) == "string" then
									value = ("%q"):format(v)
								else
									value = "(" .. tostring(v) .. ")"
								end
							end)
						
							if s then
								constants[#constants+1] = {
									name = name,
									value = value,
									depth = #depth
								}
								line = depth .. "--c_" .. name .. " = " .. value
								log("\t#const: '"..name.."' = '"..value.."'")
							else
								log("Cannot evaluate #const ("..line..")")
							end
						else
							log("Incorrect #const ("..line..")")
						end
					else
						log("Incorrect --# directive ("..line..")")
					end
				end

				if include then
					content[#content+1] = replaceConstants(line)
				else
					content[#content+1] = ""
				end
			end

			content[#content+1] = ""

			local temppath = v:gsub("%.[^%.]+", ""):gsub("/", ".")
			local conccont = table.concat(content, "\r\n")
			love.filesystem.write(temppath, conccont)

			if KEEP_STRIPPED then love.filesystem.write("code/"..temppath..".lua", conccont) end

			local f = love.filesystem.load(temppath)
			love.filesystem.remove(temppath)

			return string.dump(f)
		end)

		if s then
			if not love.filesystem.write(outpath, data) then
				log("Could not write file "..v.."!?")
			end
		else
			log("\t"..data)
		end
	else
		-- Copy other files
		log("+++\t"..v)

		local d = love.filesystem.newFileData(inpath)
		if not love.filesystem.write(outpath, d) then
			log("Could not copy "..v.."!?")
		end
	end
end

love.filesystem.write("log.txt", table.concat(log, "\n"))

function love.run() end
