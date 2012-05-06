-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Golem Graveyard",
	level_range = {14, 20},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "Rainy Day.ogg",
	min_material_level = 2,
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 4,
			sqrt_percent = 70,
			noise = "fbm_perlin",
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			wall = "TREE",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {6, 8},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 4},
		},
	},
	post_process = function(level)
		local Map = require "engine.Map"
		local a = game.zone:makeEntityByName(level, "terrain", "ATAMATHON_BROKEN")
		if a then
			local x, y = rng.range(10, level.map.w-11), rng.range(10, level.map.h-11)
			local tries = 0
			while (level.map:checkEntity(x, y, Map.TERRAIN, "block_move") or level.map(x, y, Map.OBJECT)) and tries < 100 do
				x, y = rng.range(10, level.map.w-11), rng.range(10, level.map.h-11)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(level, a, "terrain", x, y)
				level.spots[#level.spots+1] = {x=x, y=y, check_connectivity="entrance", type="special", subtype="atamathon"}
			else
				level.force_recreate = true
			end
		end
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				up = "GRASS_UP_WILDERNESS",
			}, },
		},
	},
}
