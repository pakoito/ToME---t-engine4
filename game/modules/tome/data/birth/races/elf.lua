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
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Elf",
	desc = {
		"Quendi are Elves, the first children of Eru.",
		"The first Elves awoke by Cuiviénen, the Water of Awakening in the far east of Middle-earth, long Ages before the Rising of the Sun or Moon.",
		"Unlike Men, the Elves are not subject to death by old age.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Nandor = "allow",
			Noldor = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			['Sun Paladin'] = "allow",
		},
	},
	talents = {
--		[ActorTalents.T_IMPROVED_MANA_I]=1,
	},
	copy = {
		faction = "eryn-lasgalen",
		type = "humanoid", subtype="elf",
		default_wilderness = {43, 18},
		starting_zone = "trollshaws",
		starting_quest = "start-dunadan",
		starting_intro = "elf",
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"tower-amon-sul", 1, 4}, {"carn-dum", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"moria", 1, 1}, {"eruan", 1, 3}, },
}

---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Nandor",
	desc = {
		"Elves who turned aside from the Great Journey in the early days and settled in th east of the Misty Mountains.",
		"Both the Wood-Elves of Mirkwood and the Elves of Lórien are Nandor.",
		"They posses the #GOLD#Grace of the Eldar#WHITE# talent which allows them a boost of speed every once in a while.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * -2 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +3 Willpower, +1 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 9",
		"#GOLD#Experience penality:#LIGHT_BLUE# 35%",
	},
	stats = { str=-2, mag=2, wil=3, cun=1, dex=1, con=0 },
	experience = 1.3,
	talents = { [ActorTalents.T_NANDOR_SPEED]=1 },
	copy = {
		life_rating = 9,
	},
	experience = 1.35,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Noldor",
	desc = {
		"The Noldor were the High Elves most enamoured of knowledge and the making of things. After the theft of the Silmarils, many Noldor forsook the blessed land and returned to Middle Earth, but for their sins en-route they were placed under the Doom of the Valar. After the Doom was lifted, most of the Noldor sailed west, but a few still remain in Middle Earth.",
		"They are implacable foes of the servants of Morgoth, wherever they may be found.",
		"They possess the #GOLD#Wrath of the Eldar#WHITE# talent, which allows them a boost to the damage both inflicted and resisted once in a while.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +3 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * -2 Magic, +1 Willpower, +0 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 11",
		"#GOLD#Experience penality:#LIGHT_BLUE# 35%",
	},
	stats = { str=2, mag=-2, wil=1, cun=0, dex=3, con=1 },
	experience = 1.3,
	talents = { [ActorTalents.T_NOLDOR_WRATH]=1 },
	copy = {
		life_rating = 11,
	},
	experience = 1.35,
}
--[[
newBirthDescriptor
{
	type = "subrace",
	name = "Avari",
	desc = {
		"The Avari are those elves who refused the summons of Orome to come to Valinor, and stayed behind in Middle-earth instead.",
	},
	stats = { str=-1, mag=1, wil=1, cun=3, dex=2, con=0 },
	experience = 1.1,
}
]]