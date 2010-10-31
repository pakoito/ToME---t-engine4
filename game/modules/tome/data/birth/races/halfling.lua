-- ToME - Tales of Maj'Eyal
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
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Halfling",
	desc = {
		"Halflings, are a race of very short stature, rarely exceeding four feet in height.",
		"Most of them are happy to live a quiet life of farming and gardening, yet they are not to be taken lightly.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the human kingdoms during the Age of Allure.",
		"Halflings are agile, lucky, and resilient but lacking in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Halfling = "allow",
		},
		class =
		{
			Corrupter = "disallow",
		},
	},
	copy = {
		faction = "shire",
		type = "humanoid", subtype="halfling",
		default_wilderness = {28, 13},
		starting_zone = "trollshaws",
		starting_quest = "start-allied",
		starting_intro = "halfling",
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"ruins-kor-pul", 1, 4}, {"daikara", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"iron-throne", 1, 1}, {"eruan", 1, 3}, },
}

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Halfling",
	desc = {
		"Halflings, are a race of very short stature, rarely exceeding four feet in height.",
		"Most of them are happy to live a quiet life of farming and gardening, yet they are not to be taken lightly.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the human kingdoms during the Age of Allure.",
		"They possess the #GOLD#Luck of the Little Folk#WHITE# which allows them to increase their critical strike chance for a few turns.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * -3 Strength, +3 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
		"#LIGHT_BLUE# * +5 Luck",
		"#GOLD#Life per levels:#LIGHT_BLUE# 12",
		"#GOLD#Experience penality:#LIGHT_BLUE# 20%",
	},
	stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.20,
	talents = {
		[ActorTalents.T_HALFLING_LUCK]=1,
	},
	copy = {
		life_rating = 12,
	},
}
