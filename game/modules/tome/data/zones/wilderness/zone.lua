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
	name = "World of Eyal",
	display_name = function() return game.level.map.attrs(game.player.x, game.player.y, "zonename") or "Eyal" end,
	variable_zone_name = true,
	level_range = {1, 1},
	max_level = 1,
	width = 170, height = 100,
	all_remembered = true,
	all_lited = true,
	persistant = "memory",
	ambiant_music = "Remembrance.ogg",
	wilderness = true,
--	wilderness_see_radius = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "wilderness/eyal",
		},
	},
	post_process = function(level)
		for _, z in ipairs(level.custom_zones) do
			if z.type == "zonename" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "zonename", z.subtype)
				end end
			end
		end

		-- The shield protecting the sorcerer hideout
		local spot = level:pickSpot{type="zone-pop", subtype="high-peak"}
		local p = level.map:particleEmitter(spot.x, spot.y, 3, "istari_shield_map")
	end,
}
