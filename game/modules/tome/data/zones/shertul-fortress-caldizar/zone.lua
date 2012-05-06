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
	name = "Unknown Sher'Tul Fortress",
	display_name = function(x, y)
		local zn = game.level.map.attrs(x or game.player.x, y or game.player.y, "zonename")
		if zn then return "Unknown Sher'Tul Fortress ("..zn..")"
		else return "Unknown the Sher'Tul Fortress" end
	end,
	variable_zone_name = true,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	level_range = {100, 100},
	max_level = 1,
	width = 40, height = 20,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Dreaming of Flying.ogg",
	no_level_connectivity = true,
	no_worldport = true,
	zero_gravity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/shertul-fortress-caldizar",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	post_process = function(level)
		-- Setup zones
		for _, z in ipairs(level.custom_zones) do
			if z.type == "zonename" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "zonename", z.subtype)
				end end
			elseif z.type == "particle" then
				if z.reverse then z.x1, z.x2, z.y1, z.y2 = z.x2, z.x1, z.y2, z.y1 end
				level.map:particleEmitter(z.x1, z.y1, math.max(z.x2-z.x1, z.y2-z.y1) + 1, z.subtype, {
					tx = z.x2 - z.x1,
					ty = z.y2 - z.y1,
				})
			end
		end

		local Map = require "engine.Map"
		level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
		level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
	end,
	on_enter = function(lev, old_lev, zone)
		local Dialog = require("engine.ui.Dialog")
		Dialog:simpleLongPopup("Unknown Sher'Tul Fortress", "With a sudden jolt you find yourself... somewhere familiar. The smooth walls and gentle lighting remind you of your fortress. And yet it feels different too. There is a gentle humming noise in the background, and your whole body feels light, almost weightless, such that the slightest movement propels you into the air. You have the odd feeling that you are not on Maj'Eyal any longer... From ahead you sense something both terrible and wonderful, and trepidation fills every corner of your being.", 500)
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle1.ps:toScreen(x, y, true, 1)
		local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
		level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
	end,
}
