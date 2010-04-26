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

-- Mummy wrappings, not included in global

newEntity{
	define_as = "BASE_MUMMY_WRAPPING",
	slot = "BODY",
	type = "armor", subtype="mummy",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.ANTIQUE_WHITE,
	encumber = 6,
	rarity = 5,
	desc = [[Decaying mummy wrappings.]],
	egos = "/data/general/objects/egos/armor.lua", egos_chance = resolvers.mbonus(40, 5),
	wielder = {
		resists={[DamageType.FIRE] = -50},
	}
}

newEntity{ base = "BASE_MUMMY_WRAPPING",
	name = "mummy wrappings",
	level_range = {10, 40},
	require = { stat = { dex=15 }, },
	cost = 1,
	wielder = {
		combat_def = 5,
		combat_armor = 2,
		fatigue = 2,
	},
}
