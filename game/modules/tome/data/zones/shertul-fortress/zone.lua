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
	width = 60, height = 60,
	persistent = "memory",
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Dreaming of Flying.ogg",
	no_level_connectivity = true,
	no_worldport = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/shertul-fortress",
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
			if z.type == "no-teleport" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "no_teleport", true)
				end end
			elseif z.type == "zonename" then
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
			if z.sort_drops then
				level.data.drop_zone = z
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "on_drop", function(...) game.level.data.process_drops(...) end)
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

	-- Handle drop sorting
	process_drops = function(who, dx, dy, idx, o)
		if not game.level.data.drop_zone then return end
		local map = game.level.map
		local z = game.level.data.drop_zone
		local typ = o.type.."/"..o.subtype

		map:removeObject(dx, dy, idx)

		-- Scan the room for spot
		for x = z.x1, z.x2 do for y = z.y1, z.y2 do
			local gtyp = map.attrs(x, y, "sort_drop_type")
			if not gtyp or gtyp == typ or map:getObjectTotal(x, y) == 0 then
				map.attrs(x, y, "sort_drop_type", typ)
				map:addObject(x, y, o)
				map:particleEmitter(x, y, 1, "demon_teleport")

				if  map:getObjectTotal(x, y) == 1 then
					game.logPlayer(who, "Your %s is magically sorted by the storage room.", o:getName{do_color=true})
				else
					game.logPlayer(who, "Your %s is magically sorted by the storage room and put in a pile with the others items of the same type.", o:getName{do_color=true})
				end
				return
			end
		end end

		game.logPlayer(who, "It seems the room has no more space to sort your %s.", o:getName{do_color=true})
		map:addObject(dx, dy, o) -- Add the object back, no room, so dont loose it
	end,
}
