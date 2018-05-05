--[[
This returns a function which combines a table of code-strings into a single module file
]]
local BASE = {}

BASE.TOP = [[
---------------------------------------------------
----- Computer Generated Merged Code          -----
---------------------------------------------------
----- Please use this file for debugging only -----
---------------------------------------------------
local _COMPILED = true

-- Add the module components to package.preload
local package_preload = package.preload
]]

BASE.BOTTOM = [[
-- Resume execution of main file
return package_preload[(...) .. "." .. %q](...)
]]

BASE.FOREACH = [[
package_preload[(...) .. "." .. %q] = function(...)
----------------------------------------------------------------------------------------------------
--=== % -88s ===--
----------------------------------------------------------------------------------------------------
%s
----------------------------------------------------------------------------------------------------
end
]]

BASE.FOREACHINIT = [[
package_preload[(...) .. "." .. %q] = package_preload[(...) .. "." .. %q]
]]

return function(codeList, mainFile)
	local toRPath = function(path)
		return (path:gsub("%.lua", ""):gsub("[/\\]", "."))
	end

	local totalCode = {}

	totalCode[#totalCode + 1] = BASE.TOP

	for i=1, #codeList do
		totalCode[#totalCode + 1] = BASE.FOREACH:format(toRPath(codeList[i].filepath), codeList[i].filepath, codeList[i].code)

		if codeList[i].filepath:find("[/\\]init%.lua$") then
			totalCode[#totalCode + 1] = BASE.FOREACHINIT:format(toRPath(codeList[i].filepath):gsub("%.init$", ""), toRPath(codeList[i].filepath))
		end
	end

	totalCode[#totalCode + 1] = BASE.BOTTOM:format(toRPath(mainFile))

	return table.concat(totalCode, "\r\n")
end
