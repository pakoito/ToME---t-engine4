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
	define_as = "BASE_POTION",
	type = "potion", subtype="potion",
	unided_name = "potion", id_by_type = true,
	display = "!", color=colors.WHITE, image="object/potion-0x0.png",
	use_sound = "actions/quaff",
	encumber = 0.2,
	stacking = true,
	acid_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[Magical potions can have wildly different effects, from healing to killing you -- beware! Most of them function better with a high Magic score]],
	egos = "/data/general/objects/egos/potions.lua", egos_chance = resolvers.mbonus(10, 5),
}
