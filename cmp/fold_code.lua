--[[
Returns a function that folds constants into the code
]]
local log = require "cmp.log"

return function(inpath)
	if _args.nofold then
		return love.filesystem.read(inpath)
	end

	local include = true

	local constants = {}

	-- Replace constants in line
	local function replaceConstants(line)
		if (line:find("^%s*$")) then return "" end

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

					if s and (load("return "..value)) then
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

	local conccont = table.concat(content, "\r\n")

	return conccont
end
