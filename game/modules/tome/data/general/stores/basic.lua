-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	define_as = "HEAVY_ARMOR",
	name = "heavy armour smith",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="armor", subtype="heavy", id=true, tome_drops="store"},
			{type="armor", subtype="massive", id=true, tome_drops="store"},
			{type="armor", subtype="shield", id=true, tome_drops="store"},
			{type="armor", subtype="head", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "LIGHT_ARMOR",
	name = "tanner",
	display = '2', color=colors.LIGHT_UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="armor", subtype="light", id=true, tome_drops="store"},
			{type="armor", subtype="hands", id=true, tome_drops="store"},
			{type="armor", subtype="feet", id=true, tome_drops="store"},
			{type="armor", subtype="belt", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "CLOTH_ARMOR",
	name = "tailor",
	display = '2', color=colors.WHITE,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="armor", subtype="cloth", id=true, tome_drops="store"},
			{type="armor", subtype="robe", id=true, tome_drops="store"},
			{type="armor", subtype="cloak", id=true, tome_drops="store"},
			{type="armor", subtype="belt", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "SWORD_WEAPON",
	name = "sword smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="greatsword", id=true, tome_drops="store"},
			{type="weapon", subtype="longsword", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "AXE_WEAPON",
	name = "axe smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="waraxe", id=true, tome_drops="store"},
			{type="weapon", subtype="battleaxe", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "MAUL_WEAPON",
	name = "mace smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="greatmaul", id=true, tome_drops="store"},
			{type="weapon", subtype="mace", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "TWO_HANDS_WEAPON",
	name = "two handed weapons",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{special=function(o) return o.type == "weapon" and o.twohanded end, id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ONE_HAND_WEAPON",
	name = "one handed weapons",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{special=function(o) return o.type == "weapon" and not o.twohanded end, id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ARCHER_WEAPON",
	name = "archery",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="longbow", id=true, tome_drops="store"},
			{type="weapon", subtype="sling", id=true, tome_drops="store"},
			{type="ammo", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "KNIFE_WEAPON",
	name = "knife smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = function()
			return {type="weapon", subtype="dagger", id=true, tome_drops="store"}
		end,
	},
}
newEntity{
	define_as = "STAFF_WEAPON",
	name = "staff carver",
	display = '3', color=colors.RED,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = function()
			return {type="weapon", subtype="staff", id=true, tome_drops="store"}
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
		filters = function()
			return rng.table{
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="weapon", subtype="staff", id=true, tome_drops="store"},
				{type="charm", subtype="wand", id=true, tome_drops="store"},
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
		filters = {
			{type="scroll", subtype="rune", id=true},
		},
		fixed = {
			{id=true, defined="LINANIIL_LECTURE"},
			{id=true, defined="TARELION_LECTURE_MAGIC"},
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
		nb_fill = 20,
		purse = 35,
		empty_before_restock = false,
		sell_percent = 240,
		filters = function()
			return {id=true, ignore={type="money"}, add_levels=10, force_tome_drops=true, tome_drops="boss", tome_mod={money=0, basic=0}, special=function(o) return o.type ~= "scroll" end}
		end,
	},
}

newEntity{
	define_as = "LAST_HOPE_LIBRARY",
	name = "library",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 10,
		empty_before_restock = false,
		filters = {
		},
		fixed = {
			{id=true, defined="FOUNDATION_NOTE1"},
			{id=true, defined="FOUNDATION_NOTE2"},
			{id=true, defined="FOUNDATION_NOTE3"},
			{id=true, defined="FOUNDATION_NOTE4"},
			{id=true, defined="FOUNDATION_NOTE5"},
			{id=true, defined="FOUNDATION_NOTE6"},
			{id=true, defined="RACES_NOTE0"},
			{id=true, defined="RACES_NOTE1"},
			{id=true, defined="RACES_NOTE2"},
			{id=true, defined="SOUTHSPAR_NOTE1"},
			{id=true, defined="SOUTHSPAR_NOTE2"},
		},
	},
}

-------------------------------------------------------------
-- Zigur
-------------------------------------------------------------
newEntity{
	define_as = "ZIGUR_LIBRARY",
	name = "library",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 5,
		empty_before_restock = false,
		filters = {
			{id=true, defined="ZIGUR_HISTORY"},
		},
	},
}

newEntity{
	define_as = "ZIGUR_HARMOR",
	name = "armour smith",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
                filters = {
                        {type="armor", subtype="heavy", id=true, tome_drops="store"},
                        {type="armor", subtype="massive", id=true, tome_drops="store"},
                        {type="armor", subtype="shield", id=true, tome_drops="store"},
                        {type="armor", subtype="head", id=true, tome_drops="store"},
                },
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}
newEntity{
	define_as = "ZIGUR_LARMOR",
	name = "tanner",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
                filters = {
                        {type="armor", subtype="light", id=true, tome_drops="store"},
                        {type="armor", subtype="hands", id=true, tome_drops="store"},
                        {type="armor", subtype="feet", id=true, tome_drops="store"},
                        {type="armor", subtype="belt", id=true, tome_drops="store"},
                },
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_SWORD_WEAPON",
	name = "sword smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="greatsword", id=true, tome_drops="store"},
			{type="weapon", subtype="longsword", id=true, tome_drops="store"},
		},
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_AXE_WEAPON",
	name = "axe smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="waraxe", id=true, tome_drops="store"},
			{type="weapon", subtype="battleaxe", id=true, tome_drops="store"},
		},
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_MACE_WEAPON",
	name = "mace smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="greatmaul", id=true, tome_drops="store"},
			{type="weapon", subtype="mace", id=true, tome_drops="store"},
		},
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_KNIFE_WEAPON",
	name = "knife smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = function()
			return {type="weapon", subtype="dagger", id=true, tome_drops="store"}
		end,
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}

newEntity{
	define_as = "ZIGUR_ARCHER_WEAPON",
	name = "archery",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="sling", id=true, tome_drops="store"},
			{type="weapon", subtype="longbow", id=true, tome_drops="store"},
			{type="ammo", id=true, tome_drops="store"},
		},
		post_filter = function(e)
			if e.power_source and e.power_source.arcane then return false end
			return true
		end,
	},
}
