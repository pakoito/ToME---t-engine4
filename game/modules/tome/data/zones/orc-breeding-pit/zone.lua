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
	name = "Orc breeding pits",
	level_range = {30, 60},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "Thrall's Theme.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 23,
			min_floor = 900,
			floor = "UNDERGROUND_FLOOR",
			wall = {"UNDERGROUND_TREE","UNDERGROUND_TREE2","UNDERGROUND_TREE3","UNDERGROUND_TREE4","UNDERGROUND_TREE5","UNDERGROUND_TREE6","UNDERGROUND_TREE7","UNDERGROUND_TREE8","UNDERGROUND_TREE9","UNDERGROUND_TREE10","UNDERGROUND_TREE11","UNDERGROUND_TREE12","UNDERGROUND_TREE13","UNDERGROUND_TREE14","UNDERGROUND_TREE15","UNDERGROUND_TREE16","UNDERGROUND_TREE17","UNDERGROUND_TREE18","UNDERGROUND_TREE19","UNDERGROUND_TREE20",},
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_LADDER_DOWN",
			door = "UNDERGROUND_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 50},
			guardian = "GREATMOTHER",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 6},
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		if level.level > 1 then game:placeRandomLoreObject("BREEDING_HISTORY"..level.level) end

		for uid, e in pairs(level.entities) do e.faction="orc-pride" end
	end,
	on_enter = function(lev, old_lev, newzone)
		if newzone and not game.level.shown_warning then
			require("engine.ui.Dialog"):simplePopup("Orc Breeding Pit", "You arrive in a small underground structure. There are orcs there and as soon as they notice you they scream 'Protect the mothers!'.")
			game.level.shown_warning = true
		end
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/orc-breeding-pit-first",
			}, actor = {
				nb_npc = {0, 0},
			}, },
		},
		[3] = { width = 25, height = 25, generator = {map = {min_floor=300}} },
		[4] = { width = 20, height = 20, generator = {map = {min_floor=200}} },
		[5] = { width = 15, height = 15, generator = {map = {min_floor=120}} },
	},
}
