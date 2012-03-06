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

newEntity{ base = "BASE_STORE", define_as = "HEAVY_ARMOR_STORE",
	name="Armoury",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "iron-throne", "store/shop_door.png", "store/shop_sign_armory.png"),
}
newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Tanner",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "iron-throne", "store/shop_door.png", "store/shop_sign_tanner.png"),
}
newEntity{ base = "BASE_STORE", define_as = "CLOTH_ARMOR_STORE",
	name="Tailor",
	display='2', color=colors.UMBER,
	resolvers.store("CLOTH_ARMOR", "iron-throne", "store/shop_door.png", "store/shop_sign_tailor.png"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Sword smith",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "iron-throne", "store/shop_door.png", "store/shop_sign_swordsmith.png"),
}
newEntity{ base = "BASE_STORE", define_as = "AXE_WEAPON_STORE",
	name="Axe smith",
	display='3', color=colors.UMBER,
	resolvers.store("AXE_WEAPON", "iron-throne", "store/shop_door.png", "store/shop_sign_axesmith.png"),
}
newEntity{ base = "BASE_STORE", define_as = "MACE_WEAPON_STORE",
	name="Mace smith",
	display='3', color=colors.UMBER,
	resolvers.store("MAUL_WEAPON", "iron-throne", "store/shop_door.png", "store/shop_sign_macesmith.png"),
}

newEntity{ base = "BASE_STORE", define_as = "RUNIC_STORE",
	name="Runemaster",
	display='5', color=colors.RED,
	resolvers.store("SCROLL", "iron-throne", "store/shop_door.png", "store/shop_sign_alchemist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "GEM_STORE",
	name="Jewelry",
	display='9', color=colors.LIGHT_RED,
	resolvers.store("GEMSTORE", "iron-throne", "store/shop_door.png", "store/shop_sign_jewelry.png"),
}
