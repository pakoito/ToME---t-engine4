local base = _G
require("string")
require("table")

module("config")

settings = {}

function loadFunction(fct)
	local old_mt = base.getmetatable(settings)
	local loader = { active = true }
	base.setmetatable(settings,
	{
		__index = function(table, key)
			local t = {}
			base.setmetatable(t, base.getmetatable(table))
			if loader.active and base.rawget(table, key) == nil then base.rawset(table, key, t) end
			return base.rawget(table, key)
		end,
	})

	base.setfenv(fct, settings)
	local ret, err = base.pcall(fct)
	--base.print("====", ret,err)
	loader.active = false

	if ret then return true
	else return false, err end
end

function loadString(str)
	local fct = base.loadstring(str)
	if fct then
		return loadFunction(fct)
	end
	return nil, "Could not load string"
end

function loadFile(file)
	local fct = base.loadfile(file)
	if fct then
		return loadFunction(fct)
	end
	return nil, "Could not load file"
end

load = loadFile
