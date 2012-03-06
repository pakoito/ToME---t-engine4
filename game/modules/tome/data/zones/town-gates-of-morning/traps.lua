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
	name="Impenetrable Plates",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "sunwall", "store/shop_door.png", "store/shop_sign_impenetrable_plates.png"),
}

newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Quality Leather",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "sunwall", "store/shop_door.png", "store/shop_sign_quality_leather.png"),
}

newEntity{ base = "BASE_STORE", define_as = "CLOTH_ARMOR_STORE",
	name="Arcane Cloth",
	display='2', color=colors.UMBER,
	resolvers.store("CLOTH_ARMOR", "sunwall", "store/shop_door.png", "store/shop_sign_arcane_cloth.png"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Swordmaster",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_swordsmith.png"),
}

newEntity{ base = "BASE_STORE", define_as = "KNIFE_WEAPON_STORE",
	name="Night Affairs",
	display='3', color=colors.UMBER,
	resolvers.store("KNIFE_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_night_affairs.png"),
}

newEntity{ base = "BASE_STORE", define_as = "AXE_WEAPON_STORE",
	name="Orc Cutters",
	display='3', color=colors.UMBER,
	resolvers.store("AXE_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_orc_cutters.png"),
}

newEntity{ base = "BASE_STORE", define_as = "MAUL_WEAPON_STORE",
	name="Mauling for Brutes",
	display='3', color=colors.UMBER,
	resolvers.store("MAUL_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_mauling_brutes.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ARCHER_WEAPON_STORE",
	name="Bows and Slings",
	display='3', color=colors.UMBER,
	resolvers.store("ARCHER_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_bows_slings.png"),
}

newEntity{ base = "BASE_STORE", define_as = "STAFF_WEAPON_STORE",
	name="Sook's Arcane Goodness",
	display='3', color=colors.UMBER,
	resolvers.store("STAFF_WEAPON", "sunwall", "store/shop_door.png", "store/shop_sign_sooks_goodness.png"),
}

newEntity{ base = "BASE_STORE", define_as = "HERBALIST",
	name="Sarah's Herbal Infusions",
	display='4', color=colors.LIGHT_GREEN,
	resolvers.store("POTION", "sunwall", "store/shop_door.png", "store/shop_sign_saras_herbal_infusions.png"),
}

newEntity{ base = "BASE_STORE", define_as = "RUNES",
	name="Sook's Runes and other Harmless Contraptions",
	display='5', color=colors.LIGHT_RED,
	resolvers.store("SCROLL", "sunwall", "store/shop_door.png", "store/shop_sign_sooks_runes.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ZEMEKKYS",
	name="Zemekkys Home",
	display='+', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("zemekkys", "sunwall"),
}
