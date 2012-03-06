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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_RUNE", define_as = "RUNE_RIFT",
	power_source = {arcane=true},
	name = "Rune of the Rift", unique = true, identified = true, image = "object/artifact/rune_of_the_rift.png",
	rarity = false,
	cost = 100,
	material_level = 3,

	inscription_data = {
		cooldown = 14,
	},
	inscription_talent = "RUNE_OF_THE_RIFT",
}
