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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_GEM",
	define_as = "ATAMATHON_RUBY_EYE",
	subtype = "red",
	name = "Atamathon's Ruby Eye", color=colors.VIOLET, quest=true, unique=true, identified=true, image="object/artifact/atamathons_lost_ruby_eye.png",
	desc = [[One of the ruby eyes of the legendary giant golem: Atamathon.
It is said it was made by the halflings during the Age of Pyre as a weapon against the orcs. Even though it was destroyed it managed to deal a crippling blow by killing their leader, Garkul the Devourer.]],
	material_level = 5,
	cost = 100,
	wielder = {
		inc_damage = {[DamageType.FIRE]=20},
		lite = 2,
		max_life = 60,
		pin_immune = 0.5,
	},
	imbue_powers = {
		inc_damage = {[DamageType.FIRE]=20},
		lite = 2,
		max_life = 60,
		pin_immune = 0.5,
	},
}
