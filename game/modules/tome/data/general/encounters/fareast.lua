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

newEntity{
	name = "Underwater Cave",
	type = "harmless", subtype = "special", unique = true,
	level_range = {30, 40},
	rarity = 1,
	special_filter = function(self)
		return self:findSpotGeneric(game.player, function(map, x, y) local enc = map:checkAllEntities(x, y, "can_encounter") return enc and enc == "water" end) and true or false
	end,
	on_encounter = function(self, who)
		local x, y = self:findSpotGeneric(who, function(map, x, y) local enc = map:checkAllEntities(x, y, "can_encounter") return enc and enc == "water" end)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Entrance to an underwater cave",
			display='>', color=colors.AQUAMARINE,
			notice = true,
			change_level=1, change_zone="flooded-cave"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to an underwater cave.")
		return true
	end,
}

newEntity{
	name = "Shadow Crypt",
	type = "hostile", subtype = "special", unique = true,
	level_range = {34, 45},
	rarity = 6,
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Entrance to a dark crypt",
			display='>', color=colors.GREY,
			notice = true,
			change_level=1, change_zone="shadow-crypt"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to a dark crypt. Fetid wind seems to come out of it.")
		return true
	end
}
