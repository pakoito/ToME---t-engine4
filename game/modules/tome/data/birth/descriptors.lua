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

newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	descriptor_choices =
	{
		world =
		{
			Arda = "allow",
			["Spydrë"] = function() return profile.mod.allow_build.world_spydre and "allow" or "never" end,
		},
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	copy = {
		-- Mages are unheard of at first, nobody but them regenerates mana
		mana_rating = 6,
		mana_regen = 0,

		max_level = 50,
		money = 10,
		resolvers.equip{ id=true,
			{type="lite", subtype="lite", name="brass lantern"},
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of cure poison", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of cure poison", ego_chance=-1000},
		},
		resolvers.generic(function(e)
			e.hotkey[9] = {"inventory", "potion of lesser healing"}
		end),
	},
}

--------------- Difficulties
newBirthDescriptor{
	type = "difficulty",
	name = "Easy",
	desc =
	{
		"Easy game setting",
		"All damage done to the player reduced by 20%",
		"All healing for the player increased by 10%",
		"No achievements possible.",
	},
	copy = { resolvers.generic(function() game.difficulty = game.DIFFICULTY_EASY end) },
}
newBirthDescriptor{
	type = "difficulty",
	name = "Normal",
	selection_default = true,
	desc =
	{
		"Normal game setting",
		"No changes to the rules.",
	},
	copy = { resolvers.generic(function() game.difficulty = game.DIFFICULTY_NORMAL end) },
}
newBirthDescriptor{
	type = "difficulty",
	name = "Nightmare",
	desc =
	{
		"Hard game setting",
		"All damage done to the player increased by 20%",
		"All healing for the player decreased by 10%",
	},
	copy = { resolvers.generic(function() game.difficulty = game.DIFFICULTY_NIGHTMARE end) },
}
newBirthDescriptor{
	type = "difficulty",
	name = "Insane",
	desc =
	{
		"Absolutely unfair game setting",
		"All damage done to the player increased by 20%",
		"All damage done by the player decreased by 20%",
		"All healing for the player decreased by 20%",
	},
	copy = { resolvers.generic(function() game.difficulty = game.DIFFICULTY_INSANE end) },
}


-- Worlds
load("/data/birth/worlds.lua")

-- Races
load("/data/birth/races/human.lua")
load("/data/birth/races/elf.lua")
load("/data/birth/races/hobbit.lua")
load("/data/birth/races/dwarf.lua")
load("/data/birth/races/orc.lua")
load("/data/birth/races/troll.lua")
--load("/data/birth/races/spider.lua")
load("/data/birth/races/undead.lua")

-- Sexes
load("/data/birth/sexes.lua")

-- Classes
load("/data/birth/classes/warrior.lua")
load("/data/birth/classes/archer.lua")
load("/data/birth/classes/rogue.lua")
load("/data/birth/classes/mage.lua")
load("/data/birth/classes/wilder.lua")
load("/data/birth/classes/divine.lua")
