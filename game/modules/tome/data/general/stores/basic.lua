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
		purse = 10,
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
		purse = 25,
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
	name = "weapon smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
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
		purse = 10,
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
		purse = 10,
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


newEntity{
	define_as = "GEMSTORE",
	name = "gem store",
	display = '9', color=colors.BLUE,
	store = {
		purse = 30,
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="gem", id=true},
		},
	},
}

newEntity{
	define_as = "ANGOLWEN_STAFF_WAND",
	name = "staves and wands store",
	display = '6', color=colors.RED,
	store = {
		purse = 25,
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 15,
		max_fill = 25,
		filters = {
			{type="weapon", subtype="staff", id=true},
			{type="weapon", subtype="staff", id=true},
			{type="weapon", subtype="staff", id=true},
			{type="wand", subtype="wand", id=true},
		},
	},
}

newEntity{
	define_as = "ANGOLWEN_JEWELRY",
	name = "jewelry store",
	display = '2', color=colors.BLUE,
	store = {
		purse = 20,
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 15,
		max_fill = 25,
		filters = {
			{type="jewelry", id=true},
		},
	},
}

----------- Lost Merchant
newEntity{
	define_as = "LOST_MERCHANT",
	name = "rare goods",
	display = '7', color=colors.BLUE,
	store = {
		purse = 35,
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		sell_percent = 140,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{ego_chance=80, id=true, ignore={type="money"}},
		},
	},
}
