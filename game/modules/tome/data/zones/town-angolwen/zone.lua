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
	name = "Angolwen",
	level_range = {20, 50},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"Dreaming of Flying.ogg", "weather/town_medium_base.ogg"},

	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/angolwen",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			town_medium={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/town/town_medium1","ambient/town/town_medium2","ambient/town/town_medium3","ambient/town/town_medium4"}},
		})
	end,

	on_enter = function(lev, old_lev, zone)
		-- Update the stairs
		local spot = game.level:pickSpot{type="portal", subtype="back"}
		if spot then game.level.map(spot.x, spot.y, engine.Map.TERRAIN).change_zone = game.player.last_wilderness end
	end,
}
