--[[
Returns a list of all files in the directory
]]
local fs = require "file_system"

function enumFiles(path, cont, orig)
   if not cont then cont = {} end
   if not orig then orig = "^"..path.."/" end
   for k,v in pairs(fs.getDir(path)) do
	   local fullpath = path.."/"..v
	   if fs.isDir(fullpath) then
		   enumFiles(fullpath, cont, orig)
	   else
		   local ins = fullpath:gsub(orig,"")
		   table.insert(cont, ins)
	   end
   end
   return cont
end

return enumFiles
