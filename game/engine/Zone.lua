module(..., package.seeall, class.make)

-- Static method
-- Setup classes to use for entities
function _M:setup(t)
	self.npc_class = require(t.npc_class)
	self.grid_class = require(t.grid_class)
	self.object_class = require(t.object_class)
end

function _M:init(short_name)
	self.short_name = short_name
	self:load()
	self.levels = self.levels or {}
	self.npc_list = self.npc_class:loadList("/data/zones/"..self.short_name.."/npcs.lua")
	self.grid_list = self.grid_class:loadList("/data/zones/"..self.short_name.."/grids.lua")
	self.object_list = self.object_class:loadList("/data/zones/"..self.short_name.."/objects.lua")
end

function _M:load()
	local f, err = loadfile("/data/zones/"..self.short_name.."/zone.lua")
	if err then error(err) end
	local data = f()

end
