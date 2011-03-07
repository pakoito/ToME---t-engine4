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

newBirthDescriptor{
	type = "world",
	name = "Tutorial",
	desc =
	{
		"The tutorial will explain the basics of the game to get you started.",
	},
--	on_select = function(what)
--		setAuto("subclass", false)
--		setAuto("subrace", false)
--	end,
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
}

local default_eyal_descriptors = {
	race =
	{
		__ALL__ = "disallow",
		Human = "allow",
		Elf = "allow",
		Dwarf = "allow",
		Halfling = "allow",
		Yeek = function() return profile.mod.allow_build.yeek and "allow" or "disallow" end,
		Undead = function() return profile.mod.allow_build.undead and "allow" or "disallow" end,
		Construct = function() return profile.mod.allow_build.construct and "allow" or "disallow" end,
	},

	class =
	{
		__ALL__ = "disallow",
		-- currently psionics consist only of mindslayers
		Psionic = "allow",
		Warrior = "allow",
		Archer = "allow",
		Rogue = "allow",
		Mage = "allow",
		Divine = function() return profile.mod.allow_build.divine and "allow" or "disallow" end,
		Wilder = function() return (
			profile.mod.allow_build.wilder_summoner or
			profile.mod.allow_build.wilder_wyrmic
			) and "allow" or "disallow"
		end,
		Corrupter = function() return profile.mod.allow_build.corrupter and "allow" or "disallow" end,
		Afflicted = function() return profile.mod.allow_build.afflicted and "allow" or "disallow" end,
		Chronomancer = function() return profile.mod.allow_build.chronomancer and "allow" or "disallow" end,
		Psionic = function() return profile.mod.allow_build.psionic and "allow" or "disallow" end,
	},
}

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Maj'Eyal",
	display_name = "Maj'Eyal: The Age of Ascendancy",
	desc =
	{
		"The people of Maj'Eyal: Humans, Halflings, Elves and Dwarves.",
		"The known world has been at relative peace for over one hundred years, and people are prospering again.",
		"You are an adventurer, setting out to find lost treasure and glory.",
		"But what lurks in the shadows of the world?",
	},
	descriptor_choices = default_eyal_descriptors,
	copy = {
		__allow_rod_recall = true,
	}
}

newBirthDescriptor{
	type = "world",
	name = "Infinite",
	display_name = "Infinite Dungeon: The Neverending Descent",
	desc =
	{
		"Play as your favorite race and class and venture into the infinite dungeon.",
		"The only limit to how far you can go is your own skill!",
	},
	descriptor_choices = default_eyal_descriptors,
	copy = {
		-- Give the orb of knowledge
		resolvers.inventory{ id=true, {defined="ORB_KNOWLEDGE"}},
		resolvers.equip{ id=true, {name="iron pickaxe", ego_chance=-1000}},
		resolvers.generic(function(e) e.hotkey[12] = {"inventory", "Orb of Knowledge"} end),
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "infinite-dungeon"
			self.starting_quest = "infinite-dungeon"
			self.starting_intro = "infinite-dungeon"
		end,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Arena",
	display_name = "The Arena: Challenge of the Master",
	desc =
	{
		"Play as a lone warrior facing the Arena's challenge!",
		"You can use any class and race for it.",
		"See how far you can go! Can you become the new Master of the Arena?",
		"If so, you will battle your own champion next time!",
	},
	descriptor_choices = default_eyal_descriptors,
	copy = {
		death_dialog = "ArenaFinish",

		-- Give the orb of knowledge
		resolvers.inventory{ id=true, {defined="ORB_KNOWLEDGE"}},
		resolvers.generic(function(e) e.hotkey[12] = {"inventory", "Orb of Knowledge"} end),

		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "arena"
			self.starting_quest = "arena"
			self.starting_intro = "arena"
		end,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Orcs",
	display_name = "Orcs: The Rise to Power",
	desc =
	{
		"Baston!",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Orc = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Spydre",
	display_name = "Spydrë: Legacy of Ungoliant",
	desc =
	{
		"Spydrë is home to the essence of spiders. The mighty Ungoliant of Arda actually originated from this world.",
		"It is home to uncounted numbers of spider races, all fighting for supremacy of all the lands.",
		"Some humanoids also live there, but they are usually the prey, not the hunter.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Ents",
	display_name = "Ents: The March of the Entwifes",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Trolls",
	display_name = "Trolls: Terror of the Woods",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Nagas",
	display_name = "Nagas: Guardians of the Tide",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Faeros",
	display_name = "Urthalath: Treason or the High Guards",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Undeads",
	display_name = "Broken Oath: The Curse of Undeath",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}
