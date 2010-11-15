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
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Elf",
	desc = {
		"The Second race to have awaken, thousands of years after the Sher'Tul.",
		"Elves are split into three subrace, of which only two remain in the current age.",
		"They are tolerated by most races but not usualy well liked, due to their role in the Spellblaze.",
		"Unlike other races elves are not subject to death by old age.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Shalore = "allow",
			Thalore = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			['Anorithil'] = "allow",
		},
	},
	copy = {
		type = "humanoid", subtype="elf",
		default_wilderness = {28, 13},
		starting_zone = "trollshaws",
		starting_quest = "start-allied",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={poison=true}, dur=4, power=20}),
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"ruins-kor-pul", 1, 4}, {"daikara", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"iron-throne", 1, 1}, },
}

---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Shalore",
	desc = {
		"Shaloren elves have close ties with the magic of the world, they produced in the past many great mages.",
		"Yet they remain quiet and try to prevent the teaching of magic to their people, for fear of an otehr Spellblaze.",
		"They posses the #GOLD#Grace of the Eternals#WHITE# talent which allows them a boost of speed every once in a while.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * -2 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +3 Willpower, +1 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 9",
		"#GOLD#Experience penality:#LIGHT_BLUE# 35%",
	},
	stats = { str=-2, mag=2, wil=3, cun=1, dex=1, con=0 },
	experience = 1.3,
	talents = { [ActorTalents.T_SHALOREN_SPEED]=1 },
	copy = {
		faction = "shalore",
		starting_intro = "shalore",
		life_rating = 9,
	},
	experience = 1.35,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Thalore",
	desc = {
		"Thaloren elves have spend most of the ages hidden within their forests, seldom leaving them.",
		"The ages of the world passed by and yet they remained unchanged.",
		"Their natural affinity for nature and their reclusion have made them great protectors of the natural order, often opposing their Shaloren brothers.",
		"They possess the #GOLD#Wrath of the Eternals#WHITE# talent, which allows them a boost to the damage both inflicted and resisted once in a while.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +3 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * -2 Magic, +1 Willpower, +0 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 11",
		"#GOLD#Experience penality:#LIGHT_BLUE# 35%",
	},
	stats = { str=2, mag=-2, wil=1, cun=0, dex=3, con=1 },
	experience = 1.3,
	talents = { [ActorTalents.T_THALOREN_WRATH]=1 },
	copy = {
		faction = "thalore",
		starting_intro = "thalore",
		life_rating = 11,
	},
	experience = 1.35,
}
