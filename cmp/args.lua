-- Parses arguments to be more easily accessible
local type, tonumber, insert = type, tonumber, table.insert

if type(arg) == "table" then
	local args = {}
	local last, had

	local function conv(t)
		if     t == "true" then return true
		elseif t == "false"then return false
		elseif t == "nil"  then return nil
		elseif tonumber(t) then return tonumber(t)
		else return t end
	end

	local function loop(v)
		if v:find("^%-+") then
			if last and not had then args[last] = true end
			last = v:gsub("^%-+", "")
			had = false
		elseif last then
			if had then
				if type(args[last]) ~= "table" then
					args[last] = {args[last]}
				end
				insert(args[last], conv(v))
			else
				args[last] = conv(v)
				had = true
			end
		end
	end

	for i=1, #arg do
		loop(arg[i])
	end
	loop("-")

	return args
else
	return {}
end
