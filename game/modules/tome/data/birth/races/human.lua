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
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Human",
	desc = {
		"The humans are one of the main races on Maj'Eyal, along the halflings. For many thousands of years they fought each other until events, and great people, unified all the human and halfling nations under one rule.",
		"Humans of these Allied Kingdoms have known peace for over a century now.",
		"Humans are split into two categories: the Highers, and the rest. Highers have latent magic in their blood which gives them higher attributes and senses along with a longer life.",
		"The rest of humanity is gifted with quick learning and mastery. They can do and become anything they desire.",
	},
	descriptor_choices =
	{
		subrace =
		{
			["Cornac"] = "allow",
			["Higher"] = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			['Sun Paladin'] = "allow",
			['Anorithil'] = "allow",
		},
	},
	talents = {},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="human",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={poison=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 5}, {"ruins-kor-pul", 1, 4}, {"daikara", 1, 7}, {"old-forest", 1, 7}, {"dreadfell", 1, 8}, {"iron-throne", 1, 1}, },
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Higher",
	desc = {
		"Highers are a special branch of humans that have been imbued with latent magic since the Age of Allure.",
		"They usually do not breed with other humans, trying to keep their blood 'pure'.",
		"They possess the #GOLD#Gift of the Pureborn#WHITE# which allows them to regenerate their wounds once in a while.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +1 Magic, +1 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 11",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 15%",
	},
	inc_stats = { str=1, mag=1, dex=1, wil=1 },
	experience = 1.15,
	talents = {
		[ActorTalents.T_HIGHER_HEAL]=1,
	},
	copy = {
		life_rating = 11,
		default_wilderness = {28, 13},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "higher",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Cornac",
	desc = {
		"Cornacians are average humans from the northern parts of the Allied Kingdoms.",
		"Humans are an inherently very adaptable race and as such they gain a #GOLD#talent category point#WHITE# at birth (others only gain one at levels 10, 20 and 30).",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 10",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 0%",
	},
	experience = 1.0,
	copy = {
		unused_talents_types = 1,
		life_rating = 10,
		default_wilderness = {28, 13},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "cornac",
	},
}
