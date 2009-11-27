require "engine.class"

--- Handles dialog windows
module(..., package.seeall, class.make)

--- List all available modules
-- Static
function _M:listModules()
	local ms = {}
	for i, short_name in ipairs(fs.list("/modules/")) do
		local dir = "/modules/"..short_name
		if fs.exists(dir.."/init.lua") then
			local mod = self:loadDefinition(dir.."/init.lua")
			-- Make a function to activate it
			mod.load = function()
				fs.mount(fs.getRealPath(dir), "/mod", false);
				fs.mount(fs.getRealPath(dir).."/data/", "/data", false);

				return require(mod.starter)
			end
			table.insert(ms, mod)
		end
	end

	table.sort(ms, function(a, b)
		if a.short_name == "tome" then return 1
		elseif b.short_name == "tome" then return nil
		else return a.name < b.name
		end
	end)

	return ms
end

function _M:loadDefinition(file)
	local mod_def = loadfile(file)
	if mod_def then
		-- Call the file body inside its own private environment
		local mod = {}
		setfenv(mod_def, mod)
		mod_def()

		if not mod.long_name or not mod.name or not mod.short_name or not mod.version or not mod.starter then return end
		return mod
	end
end
