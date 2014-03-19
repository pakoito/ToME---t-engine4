-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	default = { "sym:_TAB:true:false:false:false" },
	type = "TOGGLE_NPC_LIST",
	group = "actions",
	name = "Toggle list of seen creatures",
}

defineAction{
	default = { "sym:=h:false:false:false:false", "sym:=m:true:false:false:false" },
	type = "SHOW_MESSAGE_LOG",
	group = "actions",
	name = "Show message log",
}

defineAction{
	default = { "sym:_PRINTSCREEN:false:false:false:false" },
	type = "SCREENSHOT",
	group = "actions",
	name = "Take a screenshot",
}

defineAction{
	default = { "sym:_TAB:false:false:false:false" },
	type = "SHOW_MAP",
	group = "actions",
	name = "Show map",
}
