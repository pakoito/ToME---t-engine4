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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

newEntity{
	define_as = "OLD_FOREST",
	name = "way to the old forest", image = "terrain/way_next_8.png",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 7, change_zone = "old-forest", force_down = true,
}

newEntity{
	define_as = "SHERTUL_FORTRESS",
	name = "entrance to the Sher'Tul ruins",
	display = '>', color=colors.PURPLE, image = "terrain/stair_down.png",
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "shertul-fortress",
	change_level_check = function(self, who)
		if who:knownLore("old-forest-note-6") then
			game.logPlayer(who, "#ANTIQUE_WHITE#You notice a hole that could fit the gem key you found earlier, inserting it reveals the passage to the next level.")
			who:setQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "entered")
		else
			game.logPlayer(who, "#ANTIQUE_WHITE#The way seems closed, maybe you need a key.")
			return true
		end
	end,
}

newEntity{
	define_as = "WATER_FLOOR_BUBBLE",
	name = "underwater air bubble", image = "terrain/water_floor_bubbles.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	air_level = 15, nb_charges = resolvers.rngrange(4, 7),
	force_clone = true,
	on_stand = function(self, x, y, who)
		if ((who.can_breath.water and who.can_breath.water <= 0) or not who.can_breath.water) and not who:attr("no_breath") then
			self.nb_charges = self.nb_charges - 1
			if self.nb_charges <= 0 then
				game.logSeen(who, "#AQUAMARINE#The air bubbles are depleted!")
				local g = game.zone:makeEntityByName(game.level, "terrain", "WATER_FLOOR")
				game.zone:addEntity(game.level, g, "terrain", x, y)
			end
		end
	end,
}
