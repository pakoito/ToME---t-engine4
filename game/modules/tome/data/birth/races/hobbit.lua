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

---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are a race of very short stature, rarely exceeded four feet in height.",
		"Most of them are happy to live a quiet life farming and gardening, but a few get an adventurous heart.",
		"Hobbits are agile, lucky and resilient but lack in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Hobbit = "allow",
		},
	},
	stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.1,
	talents = {
		[ActorTalents.T_HOBBIT_LUCK]=1,
	},
	copy = {
		type = "humanoid", subtype="hobbit",
		life_rating = 12,
		default_wilderness = {"wilderness/arda_west", 39, 17},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
		starting_intro = "hobbit",
	},
}

---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are a race of very short stature, rarely exceeded four feet in height.",
		"Most of them are happy to live a quiet life farming and gardening, but a few get an adventurous heart.",
		"Hobbits are agile, lucky and resilient but lack in strength.",
	},
}
