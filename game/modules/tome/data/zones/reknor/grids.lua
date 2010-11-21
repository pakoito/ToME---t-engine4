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

newEntity{
	define_as = "FAR_EAST_PORTAL",
	name = "Farportal: the Far East",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use. You have no idea if it is even two-way.
This one seems to go to the Far East, a continent of which only rumours are known...]],

	orb_portal = {
		change_level = 1,
		change_zone = "unremarkable-cave",
		change_wilderness = {
			level_name = "wilderness-1",
			spot = {type="farportal-end", subtype="fareast"},
		},
		after_zone_teleport = {
			x = 98, y = 25,
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on an unfamiliar cave, with no trace of the portal...",
		on_use = function(self, who)
			game.state:goneEast()
			who:setQuestStatus("wild-wild-east", engine.Quest.DONE)
		end,
	},
}

newEntity{
	define_as = "IRON_THRONE_EDICT",
	name = "Iron Throne Edict", lore="iron-throne-reknor-edict",
	desc = [["AN EDICT TO ALL CITIZENS OF THE IRON THRONE. LONG MAY OUR EMPIRE ENDURE"]],
	image = "terrain/marble_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, who)
		if who.player then who:learnLore(self.lore) end
	end,
}
