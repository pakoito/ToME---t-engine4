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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "ARMOR_STORE",
	name="Armoury",
	display='2', color=colors.UMBER,
	resolvers.store("ARMOR", "iron-throne"),
}

newEntity{ base = "BASE_STORE", define_as = "WEAPON_STORE",
	name="Weapon Store",
	display='3', color=colors.UMBER,
	resolvers.store("WEAPON", "iron-throne"),
}

newEntity{ base = "BASE_STORE", define_as = "RUNIC_STORE",
	name="Runemaster",
	display='5', color=colors.RED,
	resolvers.store("SCROLL", "iron-throne"),
}

newEntity{ base = "BASE_STORE", define_as = "GEM_STORE",
	name="Jewelry",
	display='9', color=colors.LIGHT_RED,
	resolvers.store("GEMSTORE", "iron-throne"),
}
