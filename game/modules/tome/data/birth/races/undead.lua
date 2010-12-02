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
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	desc = {
		"Undead are humanoids (humans, elves, dwarves, ...) that have been brought back to life by the corruption of dark magics.",
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
		-- Force undead faction to undead
		resolvers.genericlast(function(e) e.faction = "undead" end),
		default_wilderness = {39, 38},
		starting_zone = "blighted-ruins",
		starting_level = 8, starting_level_force_down = true,
		starting_quest = "start-undead",
		undead = 1,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),
	},
	random_escort_possibilities = { {"trollmire", 2, 5}, {"ruins-kor-pul", 1, 4}, {"daikara", 1, 7}, {"old-forest", 1, 7}, {"dreadfell", 1, 8}, {"iron-throne", 1, 1}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	desc = {
		"Ghouls are dumb, but resilient, rotting undead creatures, making good fighters.",
		"They have access to #GOLD#special ghoul talents#WHITE# and a wide range of undead abilities:",
		"- great poison resistance",
		"- bleeding immunity",
		"- stun resistance",
		"- fear immunity",
		"- special ghoul talents: ghoulish leap, gnaw and retch",
		"The rotting bodies of ghouls also force them to act a bit slower than most creatures.",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +1 Dexterity, +5 Constitution",
		"#LIGHT_BLUE# * +0 Magic, -2 Willpower, -2 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 14",
		"#GOLD#Experience penality:#LIGHT_BLUE# 100%",
		"#GOLD#Speed penality:#LIGHT_BLUE# -20%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=-2 },
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
		"They have access to #GOLD#special skeleton talents#WHITE# and a wide range of undead abilities:",
		"- poison immunity",
		"- bleeding immunity",
		"- fear immunity",
		"- no need to breathe",
		"- special skeleton talents: sharp bones, bone amour, re-assemble",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +4 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per levels:#LIGHT_BLUE# 12",
		"#GOLD#Experience penality:#LIGHT_BLUE# 100%",
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
		starting_intro = "skeleton",
		life_rating=12,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		no_breath = 1,
	},
	experience = 2,
}
