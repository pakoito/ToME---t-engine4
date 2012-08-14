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
	name = "Shadow Crypt",
	level_range = {34,45},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.6, 0.6, 0.6, 1},
	color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
	ambient_music = {"Anne_van_Schothorst_-_Passed_Tense.ogg","weather/dungeon_base.ogg"},
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			tunnel_chance = 100,
			['.'] = "OLD_FLOOR",
			['#'] = {"OLD_WALL","WALL","WALL","WALL","WALL"},
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 20},
--			guardian = "CULTIST_RAK_SHOR",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS_FAREAST",
			}, },
		},
		[3] = {
			all_remembered = true,
			all_lited = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/shadow-crypt-last",
				},
				actor = { nb_npc = {0, 0}, },
				object = { nb_object = {0, 0}, },
				trap = { nb_trap = {0, 0}, },
			},
		},
	},
	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
	end,
}
