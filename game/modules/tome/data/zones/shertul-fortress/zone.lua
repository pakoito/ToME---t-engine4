-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	name = "Yiilkgur, the Sher'Tul Fortress",
	display_name = function(x, y)
		local zn = game.level.map.attrs(x or game.player.x, y or game.player.y, "zonename")
		if zn then return "Yiilkgur, the Sher'Tul Fortress ("..zn..")"
		else return "Yiilkgur, the Sher'Tul Fortress" end
	end,
	variable_zone_name = true,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	level_range = {18, 25},
	max_level = 1,
	width = 30, height = 30,
	persistant = "zone",
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	ambiant_music = "Dreaming of Flying.ogg",
	no_level_connectivity = true,
	no_worldport = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/shertul-fortress",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	post_process = function(level)
		-- Setup no teleport
		for _, z in ipairs(level.custom_zones) do
			if z.type == "no-teleport" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "no_teleport", true)
				end end
			elseif z.type == "zonename" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "zonename", z.subtype)
				end end
			end
		end
	end,
	on_enter = function(lev, old_lev, zone)
		-- Update the stairs
		local spot = game.level:pickSpot{type="portal", subtype="back"}
		if spot then game.level.map(spot.x, spot.y, engine.Map.TERRAIN).change_zone = game.player.last_wilderness end

		local Dialog = require("engine.ui.Dialog")
		if not game.level.shown_warning then
			Dialog:simplePopup("Yiilkgur", "This level seems to be removed from the rest of the ruins. The air is fresh and the level is lighted. You hear the distant crackling of magical energies.")
			game.level.shown_warning = true
		end
	end,
}
