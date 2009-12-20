require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level)
	engine.Generator.init(self, zone, map)
	self.level = level
	local data = level.data.generator.actor
	self.npc_list = zone:computeRarities(zone.npc_list, level.level, data.ood, nil)
	if data.adjust_level_to_player and game:getPlayer() then
		self.adjust_level_to_player = {base=game:getPlayer().level, min=data.adjust_level_to_player[1], max=data.adjust_level_to_player[2]}
	end
	self.nb_npc = data.nb_npc or {10, 20}
	self.level_range = data.level_range or {level, level}
end

function _M:generate()
	for i = 1, rng.range(self.nb_npc[1], self.nb_npc[2]) do
		local m = self.zone:pickEntity(self.npc_list)
		if m then
			m = m:clone()
			m:resolve()
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
				tries = tries + 1
			end
			if tries < 100 then
				m:move(x, y, true)
				self.level:addEntity(m)

				-- Levelup ?
				if self.adjust_level_to_player then
					local newlevel = self.adjust_level_to_player.base + rng.avg(self.adjust_level_to_player.min, self.adjust_level_to_player.max)
					m:forceLevelup(newlevel)
				end
			end
		end
	end
end
