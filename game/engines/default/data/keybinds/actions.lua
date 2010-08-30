-- TE4 - T-Engine 4
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

defineAction{
	default = { "uni:<", "uni:>" },
	type = "CHANGE_LEVEL",
	group = "actions",
	name = "Go to next/previous level",
}

defineAction{
	default = { "uni:G" },
	type = "LEVELUP",
	group = "actions",
	name = "Levelup window",
}
defineAction{
	default = { "uni:m" },
	type = "USE_TALENTS",
	group = "actions",
	name = "Use talents",
}

defineAction{
	default = { "sym:113:true:false:false:false" },
	type = "SHOW_QUESTS",
	group = "actions",
	name = "Show quests",
}

defineAction{
	default = { "uni:R" },
	type = "REST",
	group = "actions",
	name = "Rest for a while",
}

defineAction{
	default = { "sym:115:true:false:false:false" },
	type = "SAVE_GAME",
	group = "actions",
	name = "Save game",
}

defineAction{
	default = { "sym:120:true:false:false:false" },
	type = "QUIT_GAME",
	group = "actions",
	name = "Quit game",
}

defineAction{
	default = { "sym:116:false:true:false:false" },
	type = "TACTICAL_DISPLAY",
	group = "actions",
	name = "Tactical display on/off",
}

defineAction{
	default = { "uni:l" },
	type = "LOOK_AROUND",
	group = "actions",
	name = "Look around",
}

defineAction{
	default = { "sym:9:false:false:false:false" },
	type = "TOGGLE_MINIMAP",
	group = "actions",
	name = "Toggle minimap",
}

defineAction{
	default = { "sym:116:true:false:false:false" },
	type = "SHOW_TIME",
	group = "actions",
	name = "Show game calendar",
}

defineAction{
	default = { "uni:C" },
	type = "SHOW_CHARACTER_SHEET",
	group = "actions",
	name = "Show character sheet",
}

defineAction{
	default = { "sym:115:false:false:true:false" },
	type = "SWITCH_GFX",
	group = "actions",
	name = "Switch graphical modes",
}

defineAction{
	default = { "uni:?" },
	type = "HELP",
	group = "actions",
	name = "Help",
}

defineAction{
	default = { "sym:13:false:false:false:false", "sym:271:false:false:false:false" },
	type = "ACCEPT",
	group = "actions",
	name = "Accept action",
}

defineAction{
	default = { "sym:27:false:false:false:false" },
	type = "EXIT",
	group = "actions",
	name = "Exit menu",
}
