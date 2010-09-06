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
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	desc = {
		"Undeads are humanoids (humans, elves, dwarves, ...) that have been brought back to life by the corruption of dark magics.",
		"Undead can take many forms, from ghouls to vampires and liches.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Ghoul = function() return profile.mod.allow_build.undead_ghoul and "allow" or "disallow" end,
			Skeleton = function() return profile.mod.allow_build.undead_skeleton and "allow" or "disallow" end,
			Vampire = function() return profile.mod.allow_build.undead_vampire and "allow" or "disallow" end,
			Wight = function() return profile.mod.allow_build.undead_wight and "allow" or "disallow" end,
		},
		class =
		{
			Divine = "disallow",
		},
	},
	copy = {
		faction = "undead",
		default_wilderness = {34, 49},
		starting_zone = "paths-of-the-dead",
		starting_level = 8, starting_level_force_down = true,
		starting_quest = "start-undead",
		undead = 1,
	}
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	desc = {
		"Ghouls are dumb, but resilient, rotting undead creatures, making good fighters.",
		"They have access to special ghoul talents and a wide range of undead abilities:",
		"- great poison resistance",
		"- bleeding immunity",
		"- stun resistance",
		"- fear immunity",
		"- special ghoul talents: ghoulish leap, gnaw and retch",
		"The rotting body of ghouls also forces them to act a bit slower than most creatures.",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=2 },
	talents_types = {
		["undead/ghoul"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_GHOUL]=1,
	},
	copy = {
		type = "undead", subtype="ghoul",
		starting_intro = "ghoul",
		life_rating=14,
		poison_immune = 0.8,
		cut_immune = 1,
		stun_immune = 0.5,
		fear_immune = 1,
		energy = {mod=0.8},
	},
	experience = 2,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Skeleton",
	desc = {
		"Skeletons are animated bones, undead creatures both strong and dextrous.",
		"They have access to special skeleton talents and a wide range of undead abilities:",
		"- poison immunity",
		"- bleeding immunity",
		"- fear immunity",
		"- no need to breathe",
		"- special skeleton talents: sharp bones, bone amour, re-assemble",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	stats = { str=3, con=0, wil=0, mag=0, dex=4, cun=0 },
	talents_types = {
		["undead/skeleton"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_SKELETON]=1,
	},
	copy = {
		type = "undead", subtype="skeleton",
		default_wilderness = {43, 18},
		starting_intro = "skeleton",
		life_rating=12,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		no_breath = 1,
	},
	experience = 2,
}
