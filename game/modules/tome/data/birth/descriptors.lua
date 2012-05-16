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

setAuto("subclass", false)
setAuto("subrace", false)

setStepNames{
	world = "Campaign",
	race = "Race Category",
	subrace = "Race",
	class = "Class Category",
	subclass = "Class",
}

newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	descriptor_choices =
	{
		difficulty =
		{
			Tutorial = "disallow",
		},
		world =
		{
			["Maj'Eyal"] = "allow",
			Infinite = "allow",
			Arena = "allow",
			Ents = "disallow",
			Spydre = "disallow",
			Orcs = "disallow",
			Trolls = "disallow",
			Nagas = "disallow",
			Undeads = "disallow",
			Faeros = "disallow",
		},
		class =
		{
			-- Specific to some races
			None = "disallow",
		},
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, QS_QUIVER = 1 },

	copy = {
		-- Some basic stuff
		move_others = true,
		no_auto_resists = true, no_auto_saves = true,
		no_auto_high_stats = true,
		resists_cap = {all=70},
		keep_inven_on_death = true,
		can_change_level = true,
		can_change_zone = true,
		save_hotkeys = true,

		-- Mages are unheard of at first, nobody but them regenerates mana
		mana_rating = 6,
		mana_regen = 0,

		max_level = 50,
		money = 10,
		resolvers.equip{ id=true,
			{type="lite", subtype="lite", name="brass lantern", ingore_material_restriction=true, ego_chance=-1000},
		},
		make_tile = function(e)
			if not e.image then e.image = "player/"..e.descriptor.subrace:lower():gsub("[^a-z0-9_]", "_").."_"..e.descriptor.sex:lower():gsub("[^a-z0-9_]", "_")..".png" end
		end,
	},
}


--------------- Difficulties
newBirthDescriptor{
	type = "difficulty",
	name = "Tutorial",
	never_show = true,
	desc =
	{
		"#GOLD##{bold}#Tutorial mode",
		"#WHITE#Start with a simplified character and discover the game in a simple quest.#{normal}#",
		"All damage done to the player reduced by 20%",
		"All healing for the player increased by 10%",
		"No main game achievements possible.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		subrace =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		class =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
		subclass =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
	},
	copy = {
		auto_id = 2,
		no_birth_levelup = true,
		easy_mode_lifes = 99999,
		__game_difficulty = 1,
		__allow_rod_recall = false,
		__allow_transmo_chest = false,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Easy",
	display_name = "Easier",
	desc =
	{
		"#GOLD##{bold}#Easier mode#WHITE##{normal}#",
		"Provides an easier game experience.",
		"Use it if you feel uneasy tackling the harder modes.",
		"All damage done to the player decreased by 30%",
		"All healing for the player increased by 30%",
		"Achievements are not granted.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		__game_difficulty = 1,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Normal",
	selection_default = true,
	desc =
	{
		"#GOLD##{bold}#Adventure mode#WHITE##{normal}#",
		"Provides the normal level of chalenges.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		__game_difficulty = 2,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Insane",
	desc =
	{
		"#GOLD##{bold}#Insane mode#WHITE##{normal}#",
		"Absolutely unfair game setting",
		"All zone levels increased by 100% + 10",
		"All creatures talent levels increased by 100%",
		"Player rank is normal instead of elite",
		"Player can earn Insane version of achievements if also playing in Roguelike permadeath mode.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = { __game_difficulty = 4, rank=2 },
}

--------------- Permadeath
newBirthDescriptor{
	type = "permadeath",
	name = "Exploration",
	locked = function(birther) return birther:isDonator() end,
	locked_desc = "Exploration mode: Infinite lives (donator feature)",
	locked_select = function(birther) birther:selectExplorationNoDonations() end,
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Exploration",
	desc =
	{
		"#GOLD##{bold}#Exploration mode#WHITE#",
		"Provides you with infinite lives.#{normal}#",
		"This is not the way the game is meant to be played, but it allows you to have a more forgiving experience.",
		"Remember though that dying is an integral part of the game and helps you become a better player.",
		"Exploration version of achievements will be granted in this mode.",
	},
	copy = {
		infinite_lifes = 1,
	},
}
newBirthDescriptor{
	type = "permadeath",
	name = "Adventure",
	selection_default = (not config.settings.tome.default_birth) or (config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Adventure"),
	desc =
	{
		"#GOLD##{bold}#Adventure mode#WHITE#",
		"Provides you with limited extra lives.",
		"Use it if you want normal playing conditions but do not feel ready for just one life.#{normal}#",
		"At level 1,2,5,7,14,24,35 get one more 'life' that allows to resurrect at the start of the level.",
	},
	copy = {
		easy_mode_lifes = 1,
	},
}
newBirthDescriptor{
	type = "permadeath",
	name = "Roguelike",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Roguelike",
	desc =
	{
		"#GOLD##{bold}#Roguelike mode#WHITE#",
		"Provides the closer experience to 'classic' roguelike games.",
		"You will only have one life; you *ARE* your character.#{normal}#",
		"Only one life, unless ways to self-resurrect are found in-game.",
	},
}


-- Worlds
load("/data/birth/worlds.lua")

-- Races
load("/data/birth/races/tutorial.lua")
load("/data/birth/races/human.lua")
load("/data/birth/races/elf.lua")
load("/data/birth/races/halfling.lua")
load("/data/birth/races/dwarf.lua")
load("/data/birth/races/yeek.lua")
load("/data/birth/races/undead.lua")
load("/data/birth/races/construct.lua")

-- Sexes
load("/data/birth/sexes.lua")

-- Classes
load("/data/birth/classes/tutorial.lua")
load("/data/birth/classes/warrior.lua")
load("/data/birth/classes/rogue.lua")
load("/data/birth/classes/mage.lua")
load("/data/birth/classes/wilder.lua")
load("/data/birth/classes/celestial.lua")
load("/data/birth/classes/corrupted.lua")
load("/data/birth/classes/afflicted.lua")
load("/data/birth/classes/chronomancer.lua")
load("/data/birth/classes/psionic.lua")
--load("/data/birth/classes/adventurer.lua")
load("/data/birth/classes/none.lua")
