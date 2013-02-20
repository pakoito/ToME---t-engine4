-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

return {
	name = "Slime Tunnels",
	level_range = {45, 55},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 250, height = 30,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "Together We Are Strong.ogg",
	no_level_connectivity = true,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/slime-tunnels",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 10},
		},
	},
	post_process = function(level, zone)
		-- Make sure we have all pedestals
		local dragon, undead, elements, destruction = nil, nil, nil, nil
		for x = 0, level.map.w - 1 do for y = 0, level.map.h - 1 do
			local g = level.map(x, y, level.map.TERRAIN)
			if g then
				if g.define_as == "ORB_DRAGON" then dragon = g g.x, g.y = x, y
				elseif g.define_as == "ORB_DESTRUCTION" then destruction = g g.x, g.y = x, y
				elseif g.define_as == "ORB_ELEMENTS" then elements = g g.x, g.y = x, y
				elseif g.define_as == "ORB_UNDEATH" then undead = g g.x, g.y = x, y
				end
			end
		end end

		if not dragon or not undead or not elements or not destruction then
			print("Slime Tunnels generated with too few pedestals!", dragon, undead, elements, destruction)
			level.force_recreate = true
			return
		end

		local Astar = require "engine.Astar"
		local a = Astar.new(level.map, game:getPlayer())
		if not a:calc(level.default_up.x, level.default_up.y, dragon.x, dragon.y) then
			print("Slime Tunnels generated with unreachable dragon pedestal!")
			level.force_recreate = true
			return
		end
		if not a:calc(level.default_up.x, level.default_up.y, undead.x, undead.y) then
			print("Slime Tunnels generated with unreachable undead pedestal!")
			level.force_recreate = true
			return
		end
		if not a:calc(level.default_up.x, level.default_up.y, elements.x, elements.y) then
			print("Slime Tunnels generated with unreachable elements pedestal!")
			level.force_recreate = true
			return
		end
		if not a:calc(level.default_up.x, level.default_up.y, destruction.x, destruction.y) then
			print("Slime Tunnels generated with unreachable destruction pedestal!")
			level.force_recreate = true
			return
		end
	end,
}
