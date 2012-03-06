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
	name = "Derth (Southeast)",
	level_range = {5, 12},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 17, height = 16,
	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	ambient_music = "a_lomos_del_dragon_blanco.ogg",
	no_level_connectivity = true,
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/arena-unlock",
		},
	},
	post_process = function(level)
		local m = game.zone:makeEntityByName(game.level, "actor", "SLINGER")
		if m then
			game.zone:addEntity(game.level, m, "actor", 8, 2)
		end
	end
}
