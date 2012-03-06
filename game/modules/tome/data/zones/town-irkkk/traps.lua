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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "CLOTH_ARMOR_STORE",
	name="Tailor",
	display='2', color=colors.RED,
	resolvers.store("CLOTH_ARMOR", "shalore", "store/shop_door.png", "store/shop_sign_tailor.png"),
}
newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Tanner",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "shalore", "store/shop_door.png", "store/shop_sign_tanner.png"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Swordsmith",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "shalore", "store/shop_door.png", "store/shop_sign_swordsmith.png"),
}
newEntity{ base = "BASE_STORE", define_as = "STAFF_WEAPON_STORE",
	name="Staff carver",
	display='3', color=colors.RED,
	resolvers.store("STAFF_WEAPON", "shalore", "store/shop_door.png", "store/shop_sign_staves.png"),
}

newEntity{ base = "BASE_STORE", define_as = "RUNEMASTER",
	name="Runemaster",
	display='5', color=colors.RED,
	resolvers.store("SCROLL", "shalore", "store/shop_door.png", "store/shop_sign_alchemist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ALCHEMIST",
	name="Home of Marus the Alchemist",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("alchemist-elvala", "allied-kingdoms"),
}
