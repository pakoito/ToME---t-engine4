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

newEntity{
	define_as = "BASE_WAND",
	type = "wand", subtype="wand",
	unided_name = "wand", id_by_type = true,
	display = "_", color=colors.WHITE,
	encumber = 0.7,
	use_sound = "talents/spell_generic",
	elec_destroy = 20,
	desc = [[Magical wands are made by powerful alchemists to store spells. Anybody can use them to release the spells.]],
--	egos = "/data/general/objects/egos/wands.lua", egos_chance = resolvers.mbonus(10, 5),
}
