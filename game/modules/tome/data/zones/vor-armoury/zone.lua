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
	name = "Vor Armoury",
	level_range = {35, 50},
	level_scheme = "player",
	max_level = 2,
--	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
	persistent = "zone",
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "New Dawn.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			tunnel_chance = 100,
			['.'] = "FLOOR",
			['#'] = "WALL",
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
		},
	},
	post_process = function(level)
		for uid, e in pairs(level.entities) do e.faction="orc-pride" end
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			},
			trap = {nb_object = {20, 20},},
			},
		},
		[2] = {
			width = 40, height = 40,
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/vor-armoury-last",
			}, },
		},
	},
}
