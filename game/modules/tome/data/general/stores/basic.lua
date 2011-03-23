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
	name = "heavy armour smith",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		min_fill = 10,
		max_fill = 20,
		filters = function()
			return {type="armor", subtype="heavy", id=true, tome_drops="store"}
			return {type="armor", subtype="massive", id=true, tome_drops="store"}
		end,
	},
}

newEntity{
	define_as = "ARMOR",
	name = "tanner",
	display = '2', color=colors.LIGHT_UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		min_fill = 10,
		max_fill = 20,
		filters = function()
			return {type="armor", subtype="light", id=true, tome_drops="store"}
		end,
	},
}

newEntity{
	define_as = "ARMOR",
	name = "tailor",
	display = '2', color=colors.WHITE,
	store = {
		purse = 25,
		empty_before_restock = false,
		min_fill = 10,
		max_fill = 20,
		filters = function()
			return {type="armor", subtype="cloth", id=true, tome_drops="store"}
		end,
	},
}

newEntity{
	define_as = "WEAPON",
	name = "weapon smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		min_fill = 10,
		max_fill = 20,
		filters = function()
			return {type="weapon", subtype="sword", id=true, tome_drops="store"}
		end,
	},
}

newEntity{
	define_as = "POTION",
	name = "infusion store",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		purse = 10,
		empty_before_restock = false,
		min_fill = 4,
		max_fill = 7,
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
		empty_before_restock = false,
		min_fill = 4,
		max_fill = 7,
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
		empty_before_restock = false,
		min_fill = 20,
		max_fill = 30,
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
		empty_before_restock = false,
		min_fill = 15,
		max_fill = 25,
		filters = function()
			return rng.table{
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="wand", subtype="wand", id=true, tome_drops="store"},
			}
		end,
	},
}

newEntity{
	define_as = "ANGOLWEN_JEWELRY",
	name = "jewelry store",
	display = '2', color=colors.BLUE,
	store = {
		purse = 20,
		empty_before_restock = false,
		min_fill = 15,
		max_fill = 25,
		filters = {
			{type="jewelry", id=true},
		},
		filters = function()
			return rng.table{
				{type="jewelry", subtype="ring", id=true, ego_chance=-1000},
				{type="jewelry", id=true, tome_drops="store"},
				{type="jewelry", id=true, tome_drops="store"},
				{type="jewelry", id=true, tome_drops="store"},
			}
		end,
	},
}

newEntity{
	define_as = "ANGOLWEN_SCROLL",
	name = "rune store and library",
	display = '5', color=colors.WHITE,
	store = {
		purse = 10,
		empty_before_restock = false,
		min_fill = 5,
		max_fill = 9,
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
		empty_before_restock = false,
		sell_percent = 240,
		min_fill = 10,
		max_fill = 20,
		filters = function()
			return {id=true, ignore={type="money"}, add_levels=10, tome_drops="boss"}
		end,
	},
}

newEntity{
	define_as = "LAST_HOPE_LIBRARY",
	name = "library",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 5,
		empty_before_restock = false,
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
		empty_before_restock = false,
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
		empty_before_restock = false,
		min_fill = 20,
		max_fill = 30,
		filters = function()
			return {type="armor", id=true, tome_drops="store"}
		end,
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
		empty_before_restock = false,
		min_fill = 20,
		max_fill = 30,
		filters = function()
			return {type="weapon", id=true, tome_drops="store"}
		end,
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}
