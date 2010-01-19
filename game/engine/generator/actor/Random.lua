require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level)
	engine.Generator.init(self, zone, map)
	self.level = level
	local data = level.data.generator.actor

	-- Setup the entities list
	level:setEntitiesList("actor", zone:computeRarities("actor", zone.npc_list, level, nil))

	if data.adjust_level and game:getPlayer() then
		self.adjust_level = {base=zone.base_level, min=data.adjust_level[1], max=data.adjust_level[2]}
	end
	self.filters = data.filters
	self.nb_npc = data.nb_npc or {10, 20}
	self.guardian = data.guardian
end

function _M:generate()
	for i = 1, rng.range(self.nb_npc[1], self.nb_npc[2]) do
		local f = nil
		if self.filters then f = self.filters[rng.range(1, #self.filters)] end
		local m = self.zone:makeEntity(self.level, "actor", f)
		if m then
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
				tries = tries + 1
			end
			if tries < 100 then
				m:move(x, y, true)
				self.level:addEntity(m)
				m:added()

				-- Levelup ?
				if self.adjust_level then
					local newlevel = self.adjust_level.base + rng.avg(self.adjust_level.min, self.adjust_level.max)
					m:forceLevelup(newlevel)
				end
			end
		end
	end

	if self.level.level < self.zone.max_level then return end

	if self.guardian then
		local m = self.zone:makeEntityByName(self.level, "actor", self.guardian)
		if m then
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
				tries = tries + 1
			end
			if tries < 100 then
				m:move(x, y, true)
				self.level:addEntity(m)
				m:added()

				-- Levelup ?
				if self.adjust_level then
					local newlevel = self.adjust_level.base + rng.avg(self.adjust_level.min, self.adjust_level.max)
					m:forceLevelup(newlevel)
				end
				print("Guardian allocated: ", self.guardian, m.uid, m.name)
			end
		else
			print("WARNING: Guardian not found: ", self.guardian)
		end
	end
end
