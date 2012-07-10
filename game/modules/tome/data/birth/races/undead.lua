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
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	locked = function() return profile.mod.allow_build.undead end,
	locked_desc = "Grave strength, dread will, this flesh cannot stay still. Kings die, masters fall, we will outlast them all.",
	desc = {
		"Undead are humanoids (Humans, Elves, Dwarves, ...) that have been brought back to life by the corruption of dark magics.",
		"Undead can take many forms, from ghouls to vampires and liches.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Ghoul = "allow",
			Skeleton = "allow",
			Vampire = "allow",
			Wight = "allow",
		},
		class =
		{
			Wilder = "disallow",
		},
		subclass =
		{
			Necromancer = "nolore",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	talents = {
		[ActorTalents.T_UNDEAD_ID]=1,
	},
	copy = {
		-- Force undead faction to undead
		resolvers.genericlast(function(e) e.faction = "undead" end),
		starting_zone = "blighted-ruins",
		starting_level = 4, starting_level_force_down = true,
		starting_quest = "start-undead",
		undead = 1,
		forbid_nature = 1,
		inscription_restrictions = { ["inscriptions/runes"] = true, ["inscriptions/taints"] = true, },
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	locked = function() return profile.mod.allow_build.undead_ghoul end,
	locked_desc = "Slow to shuffle, quick to bite, learn from master, rule the night!",
	desc = {
		"Ghouls are dumb, but resilient, rotting undead creatures, making good fighters.",
		"They have access to #GOLD#special ghoul talents#WHITE# and a wide range of undead abilities:",
		"- great poison resistance",
		"- bleeding immunity",
		"- stun resistance",
		"- fear immunity",
		"- special ghoul talents: ghoulish leap, gnaw and retch",
		"The rotting bodies of ghouls also force them to act a bit more slowly than most creatures.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +1 Dexterity, +5 Constitution",
		"#LIGHT_BLUE# * +0 Magic, -2 Willpower, -2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 14",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 25%",
		"#GOLD#Speed penalty:#LIGHT_BLUE# -20%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=-2 },
	talents_types = {
		["undead/ghoul"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_GHOUL]=1,
	},
	copy = {
		type = "undead", subtype="ghoul",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "ghoul",
		life_rating=14,
		poison_immune = 0.8,
		cut_immune = 1,
		stun_immune = 0.5,
		fear_immune = 1,
		global_speed_base = 0.8,
		moddable_tile = "ghoul",
		moddable_tile_nude = true,
	},
	experience = 1.25,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Skeleton",
	locked = function() return profile.mod.allow_build.undead_skeleton end,
	locked_desc = "The marching bones, each step we rattle; but servants no more, we march to battle!",
	desc = {
		"Skeletons are animated bones, undead creatures both strong and dexterous.",
		"They have access to #GOLD#special skeleton talents#WHITE# and a wide range of undead abilities:",
		"- poison immunity",
		"- bleeding immunity",
		"- fear immunity",
		"- no need to breathe",
		"- special skeleton talents: bone armour, resilient bones, re-assemble",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +4 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 40%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=0, wil=0, mag=0, dex=4, cun=0 },
	talents_types = {
		["undead/skeleton"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_SKELETON]=1,
	},
	copy = {
		type = "undead", subtype="skeleton",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "skeleton",
		life_rating=12,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		no_breath = 1,
		blood_color = colors.GREY,
		moddable_tile = "skeleton",
		moddable_tile_nude = true,
	},
	experience = 1.4,
}
