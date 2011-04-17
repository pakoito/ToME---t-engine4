-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "HEAVY_ARMOR_STORE",
	name="Armoury",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "thalore"),
}

newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Tanner",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "thalore"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Swordsmith",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "thalore"),
}

newEntity{ base = "BASE_STORE", define_as = "MAUL_WEAPON_STORE",
	name="Nature's Punch",
	display='3', color=colors.UMBER,
	resolvers.store("MAUL_WEAPON", "thalore"),
}

newEntity{ base = "BASE_STORE", define_as = "ARCHER_WEAPON_STORE",
	name="Silent Hunter",
	display='3', color=colors.UMBER,
	resolvers.store("ARCHER_WEAPON", "thalore"),
}

newEntity{ base = "BASE_STORE", define_as = "HERBALIST",
	name="Herbalist",
	display='4', color=colors.LIGHT_BLUE,
	resolvers.store("POTION", "thalore"),
}
