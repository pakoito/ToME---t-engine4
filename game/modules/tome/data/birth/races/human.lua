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
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Human",
	desc = {
		"The Edain, humans, are one of the youngest of the races of Arda.",
	},
	descriptor_choices =
	{
		subrace =
		{
			["Bree-man"] = "allow",
			["Dúnadan"] = "allow",
			Rohirrim = "allow",
			Beorning = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			['Sun Paladin'] = "allow",
		},
	},
	talents = {},
	copy = {
		faction = "reunited-kingdom",
		type = "humanoid", subtype="human",
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"tower-amon-sul", 1, 4}, {"carn-dum", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"moria", 1, 1}, {"eruan", 1, 3}, },
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dúnadan",
	desc = {
		"The greatest of the Edain, humans in all respects but stronger, smarter, and wiser.",
		"They possess the #GOLD#Gift of Kings#WHITE# which allows them to regenerate their wounds once in a while.",
		"#GOLD#Stats modifiers:#LIGHT_BLUE# +1 Strength, +1 Cunning, +1 Dexterity, +1 Willpower",
		"#GOLD#Life per levels:#LIGHT_BLUE# 11",
		"#GOLD#Experience penality:#LIGHT_BLUE# 15%",
	},
	stats = { str=1, cun=1, dex=1, wil=1 },
	experience = 1.15,
	talents = {
		[ActorTalents.T_DUNADAN_HEAL]=1,
	},
	copy = {
		lite_rating = 11,
		default_wilderness = {43, 18},
		starting_zone = "trollshaws",
		starting_quest = "start-dunadan",
		starting_intro = "dunadan",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Bree-man",
	desc = {
		"Humans hailing from the northen town of Bree. A common kind of man, unremarkable in all respects.",
		"Humans are an inherently very adaptable race and as such they gain a #GOLD#talent category point#WHITE# at birth(others only gain one at level 10, 20 and 30).",
		"#GOLD#Stats modifiers:#LIGHT_BLUE# none",
		"#GOLD#Life per levels:#LIGHT_BLUE# 10",
		"#GOLD#Experience penality:#LIGHT_BLUE# 0%",
	},
	experience = 1.0,
	copy = {
		unused_talents_types = 1,
		default_wilderness = {43, 18},
		starting_zone = "trollshaws",
		starting_quest = "start-dunadan",
		starting_intro = "bree-man",
	},
}


--[[
newBirthDescriptor
{
	type = "subrace"
	name = "Rohirrim"
	desc = {
		"Humans from the land of Rohan, who ride the great Mearas.",
	}
	stats = { [A_STR]=1, [A_INT]=1, [A_WIS]=0, [A_DEX]=3, [A_CON]=1, [A_CHR]=2, }
	experience = 70
	levels =
	{
		[ 1] = { SPEED=3 }
	}
	skills =
	{
		["Weaponmastery"]   = { mods.add(0)   , mods.add(200)  }
		["Riding"]          = { mods.add(5000), mods.add(600)  }
	}
}
newBirthDescriptor
{
	type = "subrace",
	name = "Beorning",
	desc = {
		"A race of shapeshifter men.",
		"They have the unique power of being able to polymorph into bear form.",
	},
	stats = { str=2, con=2, dex=-1, cun=-3, },
	experience = 1.8,
	talents = {},
}
]]
