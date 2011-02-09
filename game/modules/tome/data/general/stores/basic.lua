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
	define_as = "ARMOR",
	name = "armour smith",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		restock_after = 1000,
		empty_before_restock = true,
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
	name = "infusion store",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		purse = 10,
		restock_after = 1000,
		empty_before_restock = true,
		min_fill = 2,
		max_fill = 4,
		filters = {
			{type="scroll", subtype="infusion", id=true},
		},
	},
}

newEntity{
	define_as = "SCROLL",
	name = "rune store",
	display = '5', color=colors.WHITE,
	store = {
		purse = 10,
		restock_after = 1000,
		empty_before_restock = true,
		min_fill = 2,
		max_fill = 4,
		filters = {
			{type="scroll", subtype="rune", id=true},
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
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="gem", id=true},
		},
	},
}


-------------------------------------------------------------
-- Angolwen
-------------------------------------------------------------
newEntity{
	define_as = "ANGOLWEN_STAFF_WAND",
	name = "staves and wands store",
	display = '6', color=colors.RED,
	store = {
		purse = 25,
		restock_after = 1000,
		empty_before_restock = true,
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
		min_fill = 15,
		max_fill = 25,
		filters = {
			{type="jewelry", id=true},
		},
	},
}

newEntity{
	define_as = "ANGOLWEN_SCROLL",
	name = "rune store and library",
	display = '5', color=colors.WHITE,
	store = {
		purse = 10,
		restock_after = 1000,
		empty_before_restock = true,
		min_fill = 2,
		max_fill = 4,
		filters = {
			{type="scroll", subtype="rune", id=true},
		},
		fixed = {
			{id=true, defined="LINANIIL_LECTURE"},
		},
	},
}

-------------------------------------------------------------
-- Last Hope
-------------------------------------------------------------
newEntity{
	define_as = "LOST_MERCHANT",
	name = "rare goods",
	display = '7', color=colors.BLUE,
	store = {
		purse = 35,
		restock_after = 1000,
		empty_before_restock = true,
		sell_percent = 140,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{ego_chance=80, id=true, ignore={type="money"}},
		},
	},
}

newEntity{
	define_as = "LAST_HOPE_LIBRARY",
	name = "library",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 5,
		restock_after = 1000,
		empty_before_restock = true,
		sell_percent = 100,
		min_fill = 40,
		max_fill = 40,
		filters = {
			{id=true, defined="FOUNDATION_NOTE1"},
			{id=true, defined="FOUNDATION_NOTE2"},
			{id=true, defined="FOUNDATION_NOTE3"},
			{id=true, defined="FOUNDATION_NOTE4"},
			{id=true, defined="FOUNDATION_NOTE5"},
			{id=true, defined="FOUNDATION_NOTE6"},
		},
	},
}

-------------------------------------------------------------
-- Last Hope
-------------------------------------------------------------
newEntity{
	define_as = "ZIGUR_LIBRARY",
	name = "library",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 5,
		restock_after = 1000,
		empty_before_restock = true,
		sell_percent = 100,
		min_fill = 40,
		max_fill = 40,
		filters = {
			{id=true, defined="ZIGUR_HISTORY"},
		},
	},
}

newEntity{
	define_as = "ZIGUR_ARMOR",
	name = "armour smith",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		restock_after = 1000,
		empty_before_restock = true,
		min_fill = 20,
		max_fill = 30,
		filters = {
			{type="armor", id=true, ego_chance={ego_chance=1000, properties={"greater_ego"}}},
		},
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_WEAPON",
	name = "weapon smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		restock_after = 1000,
		empty_before_restock = true,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="weapon", id=true},
			{type="ammo", id=true},
		},
	},
}
