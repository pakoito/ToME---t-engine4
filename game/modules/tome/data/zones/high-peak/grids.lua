-- ToME - Tales of Middle-Earth
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
This one seems to go to the Far East.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness-arda-fareast",
		change_wilderness = {
			x = 9, y = 5,
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on the Far East, with no trace of the portal...",
		on_use = function(self, who)
		end,
	},
}

newEntity{
	define_as = "WEST_PORTAL",
	name = "Farportal: Misty Mountains",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use. You have no idea if it is even two-way.
This one seems to go to the Misty Mountains in the West.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			x = 41, y = 33,
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on the slopes of the Misty Mountains, with no trace of the portal...",
		on_use = function(self, who)
		end,
	},
}

newEntity{
	define_as = "VOID_PORTAL",
	name = "Farportal: the Void",
	display = '&', color=colors.DARK_GREY, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use. You have no idea if it is even two-way.
This one seems to go to an unknown place, seemingly out of this world. You dare not use it.]],
}

local invocation_close = function(self, who)
	if not who:hasQuest("high-peak") or who:hasQuest("high-peak"):isCompleted() then return end
	game.logPlayer(who, "#LIGHT_BLUE#You use the orb on the portal, shutting it down easily.")
	-- Remove the level spot
	local spot = game.level:pickSpot{type="portal", subtype=self.summon}
	for i = 1, #game.level.spots do if game.level.spots[i] == spot then table.remove(game.level.spots, i) break end end
	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
	g.name = g.name .. " (disabled)"
	who:setQuestStatus("high-peak", engine.Quest.COMPLETED, "closed-portal-"..self.summon)
end

newEntity{
	define_as = "PORTAL_UNDEAD",
	name = "Invocation Portal: Undeath",
	display = '&', color=colors.GREY, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[An invocation portal, perpetualy summoning beings through it.]],
	orb_portal = {
		summon = "undead",
		special = invocation_close,
	},
}

newEntity{
	define_as = "PORTAL_ELEMENTS",
	name = "Invocation Portal: Elements",
	display = '&', color=colors.LIGHT_RED, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[An invocation portal, perpetualy summoning beings through it.]],
	orb_portal = {
		summon = "elemental",
		special = invocation_close,
	},
}

newEntity{
	define_as = "PORTAL_DRAGON",
	name = "Invocation Portal: Dragons",
	display = '&', color=colors.LIGHT_BLUE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[An invocation portal, perpetualy summoning beings through it.]],
	orb_portal = {
		summon = "dragon",
		special = invocation_close,
	},
}

newEntity{
	define_as = "PORTAL_DESTRUCTION",
	name = "Invocation Portal: Destruction",
	display = '&', color=colors.WHITE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[An invocation portal, perpetualy summoning beings through it.]],
	orb_portal = {
		summon = "demon",
		special = invocation_close,
	},
}

newEntity{
	define_as = "PORTAL_BOSS",
	name = "Portal: The Sanctum",
	display = '&', color=colors.LIGHT_BLUE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal seems to connect to an other part of this level.]],
	orb_portal = {
		teleport_level = {x=25, y=8},
		message = "#VIOLET#You enter the swirling portal and appear in a large room with other portals and the two wizards.",
		on_use = function()
			local Chat = require "engine.Chat"
			local chat = Chat.new("istari-fight", {name="Alatar, the Blue"}, game.player)
			chat:invoke()
			game.player:hasQuest("high-peak"):start_end_combat()
		end,
	},
}
