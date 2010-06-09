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

load("/data/general/objects/objects.lua")

-- Artifact, droped (and used!) by the Shade of Angmar
newEntity{ base = "BASE_STAFF",
	define_as = "STAFF_ANGMAR", rarity=false,
	name = "Angmar's Fall", unique=true,
	desc = [[Made from the bones of of many creatures this staff glows with power. You can feel its evilness as you touch it.]],
	require = { stat = { mag=25 }, },
	cost = 5,
	combat = {
		dam = 10,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.1},
	},
	wielder = {
		see_invisible = 2,
		combat_spellpower = 7,
		combat_spellcrit = 8,
		inc_damage={
			[DamageType.FIRE] = 4,
			[DamageType.COLD] = 4,
			[DamageType.ACID] = 4,
			[DamageType.LIGHTNING] = 4,
			[DamageType.BLIGHT] = 4,
		},
	},
}
