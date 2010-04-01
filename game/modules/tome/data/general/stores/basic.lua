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

newEntity{
	define_as = "GENERAL_STORE",
	name = "general store",
	display = '1', color=colors.LIGHT_UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="potion", id=true},
			{type="scroll", id=true},
		},
--		fixed = {
--		},
	},
}

newEntity{
	define_as = "ARMOR",
	name = "armour smith",
	display = '2', color=colors.UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="armor", id=true},
		},
	},
}

newEntity{
	define_as = "WEAPON",
	name = "weapon mith",
	display = '3', color=colors.UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="weapon", id=true},
			{type="ammo", id=true},
		},
	},
}

newEntity{
	define_as = "POTION",
	name = "alchemist store",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="potion", id=true},
		},
	},
}

newEntity{
	define_as = "SCROLL",
	name = "scribe store",
	display = '5', color=colors.WHITE,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="scroll", id=true},
		},
	},
}
