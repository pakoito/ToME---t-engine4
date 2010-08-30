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
	default = { "uni:i", },
	type = "SHOW_INVENTORY",
	group = "inventory",
	name = "Show inventory",
}
defineAction{
	default = { "uni:e", },
	type = "SHOW_EQUIPMENT",
	group = "inventory",
	name = "Show equipment",
}

defineAction{
	default = { "uni:g" },
	type = "PICKUP_FLOOR",
	group = "actions",
	name = "Pickup items",
}
defineAction{
	default = { "uni:d" },
	type = "DROP_FLOOR",
	group = "actions",
	name = "Drop items",
}

defineAction{
	default = { "uni:w", },
	type = "WEAR_ITEM",
	group = "inventory",
	name = "Wield/wear items",
}
defineAction{
	default = { "uni:t", },
	type = "TAKEOFF_ITEM",
	group = "inventory",
	name = "Takeoff items",
}

defineAction{
	default = { "uni:u", },
	type = "USE_ITEM",
	group = "inventory",
	name = "Use items",
}

defineAction{
	default = { "uni:x", },
	type = "QUICK_SWITCH_WEAPON",
	group = "inventory",
	name = "Quick switch weapons set",
}
