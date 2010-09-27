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
		"Hobbits, or halflings, are a race of very short stature, rarely exceeding four feet in height.",
		"Most of them are happy to live a quiet life of farming and gardening, but a few have an adventurous heart.",
		"Hobbits are agile, lucky, and resilient but lacking in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Hobbit = "allow",
		},
		class =
		{
			Corrupter = "disallow",
		},
	},
	copy = {
		faction = "shire",
		type = "humanoid", subtype="hobbit",
		default_wilderness = {43, 18},
		starting_zone = "trollshaws",
		starting_quest = "start-dunadan",
		starting_intro = "hobbit",
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"tower-amon-sul", 1, 4}, {"carn-dum", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"moria", 1, 1}, {"eruan", 1, 3}, },
}

---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are a race of very short stature, rarely exceeding four feet in height.",
		"Most of them are happy to live a quiet life of farming and gardening, but a few have an adventurous heart.",
		"Hobbits are agile, lucky, and resilient but lacking in strength.",
		"They possess the #GOLD#Luck of the Little Folk#WHITE# which allows them to increase their critical strike chance for a few turns.",
		"#GOLD#Stats modifiers:#LIGHT_BLUE# -3 Strength, +3 Dexterity, +3 Cunning, +1 Constitution, +5 Luck",
		"#GOLD#Life per levels:#LIGHT_BLUE# 12",
		"#GOLD#Experience penality:#LIGHT_BLUE# 15%",
	},
	stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.15,
	talents = {
		[ActorTalents.T_HOBBIT_LUCK]=1,
	},
	copy = {
		life_rating = 12,
	},
}
