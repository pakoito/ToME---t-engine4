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
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Dwarf",
	desc = {
		"The children of Aule, a strong but small race.",
		"Miners and fighters of legend.",
		"Female dwarves remain a mystery and as such may not be played."
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Dwarf = "allow",
		},
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	copy = {
		faction = "lonely-mountain",
		type = "humanoid", subtype="dwarf",
		default_wilderness = {43, 18},
		starting_zone = "trollshaws",
		starting_quest = "start-dunadan",
		starting_intro = "dwarf",
	},
	random_escort_possibilities = { {"trollshaws", 2, 5}, {"tower-amon-sul", 1, 4}, {"carn-dum", 1, 7}, {"old-forest", 1, 7}, {"tol-falas", 1, 8}, {"moria", 1, 1}, {"eruan", 1, 3}, },
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dwarf",
	desc = {
		"The children of Aule, a strong but small race.",
		"Miners and fighters of legend.",
		"They possess the #GOLD#Resilience of the Dwarves#WHITE# which allows them to increase their armour, physical and spell saves for a few turns.",
		"#GOLD#Stats modifiers:#LIGHT_BLUE# +4 Strength, +3 Constitution, +3 Willpower, -2 Magic, -2 Dexterity",
		"#GOLD#Life per levels:#LIGHT_BLUE# 12",
		"#GOLD#Experience penality:#LIGHT_BLUE# 10%",
	},
	stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents = {
		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		life_rating=12,
	},
	experience = 1.1,
}
