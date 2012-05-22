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

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Halfling",
	desc = {
		"Halflings are a race of very short stature, rarely exceeding four feet in height.",
		"They are like humans in that they can do just about anything they set their minds to, yet they excel at ordering and studying things.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the Human kingdoms during the Age of Allure.",
		"Halflings are agile, lucky, and resilient but lacking in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Halfling = "allow",
		},
		subclass = {
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="halfling",
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "halfling",
		size_category = 2,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Halfling",
	desc = {
		"Halflings are a race of very short stature, rarely exceeding four feet in height.",
		"They are like humans in that they can do just about anything they set their minds to, yet they excel at ordering and studying things.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the Human kingdoms during the Age of Allure.",
		"They possess the #GOLD#Luck of the Little Folk#WHITE# which allows them to increase their critical strike chance for a few turns.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * -3 Strength, +3 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
		"#LIGHT_BLUE# * +5 Luck",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 20%",
	},
	inc_stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.20,
	talents_types = { ["race/halfling"]={true, 0} },
	talents = {
		[ActorTalents.T_HALFLING_LUCK]=1,
	},
	copy = {
		moddable_tile = "halfling_#sex#",
		random_name_def = "halfling_#sex#",
		life_rating = 12,
	},
}
