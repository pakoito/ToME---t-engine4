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
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Human",
	desc = {
		"The Humans are one of the main races on Maj'Eyal, along with the Halflings. For many thousands of years they fought each other until events, and great people, unified all the Human and Halfling nations under one rule.",
		"Humans of these Allied Kingdoms have known peace for over a century now.",
		"Humans are split into two categories: the Highers, and the rest. Highers have latent magic in their blood which gives them higher attributes and senses along with a longer life.",
		"The rest of Humanity is gifted with quick learning and mastery. They can do and become anything they desire.",
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
			-- Only human and elves make sense to play celestials
			['Sun Paladin'] = "allow",
			['Anorithil'] = "allow",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	talents = {},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="human",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
			{name="Red braids [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_ornament = {female="braid_redhead_01"} end end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
		},
	},
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Higher",
	desc = {
		"Highers are a special branch of Humans that have been imbued with latent magic since the Age of Allure.",
		"They usually do not breed with other Humans, trying to keep their blood 'pure'.",
		"They possess the #GOLD#Gift of the Pureborn#WHITE# which allows them to regenerate their wounds once in a while.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +1 Magic, +1 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 11",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 15%",
	},
	inc_stats = { str=1, mag=1, dex=1, wil=1 },
	experience = 1.15,
	talents_types = { ["race/higher"]={true, 0} },
	talents = {
		[ActorTalents.T_HIGHER_HEAL]=1,
	},
	copy = {
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_higher_01.png",
		random_name_def = "higher_#sex#",
		life_rating = 11,
		default_wilderness = {"playerpop", "allied"},
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
		"Cornacians are average Humans from the northern parts of the Allied Kingdoms.",
		"Humans are an inherently very adaptable race and as such they gain a #GOLD#talent category point#WHITE# at birth (others only gain one at levels 10, 20 and 30).",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 10",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 0%",
	},
	experience = 1.0,
	copy = {
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_cornac_01.png",
		random_name_def = "cornac_#sex#",
		unused_talents_types = 1,
		life_rating = 10,
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "cornac",
	},
}
