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

local default_eyal_descriptors = function(add)
	local base = {

	race =
	{
		__ALL__ = "disallow",
		Human = "allow",
		Elf = "allow",
		Dwarf = "allow",
		Halfling = "allow",
		Yeek = "allow",
		Undead = "allow",
		Construct = "allow",
	},

	class =
	{
		__ALL__ = "disallow",
		Psionic = "allow",
		Warrior = "allow",
		Archer = "allow",
		Rogue = "allow",
		Mage = "allow",
		Celestial = "allow",
		Wilder = "allow",
		Defiler = "allow",
		Afflicted = "allow",
		Chronomancer = "allow",
		Psionic = "allow",
		Adventurer = "allow",
	},
	subclass =
	{
		-- Nobody should be a sun paladin & anorithil but humans & elves
		['Sun Paladin'] = "nolore",
		Anorithil = "nolore",
		-- Nobody should be an archmage but human, elves, halflings and undeads
		Archmage = "nolore",
	},
}
	if add then table.merge(base, add) end
	return base
end

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
	descriptor_choices = default_eyal_descriptors{},
	game_state = {
		campaign_name = "maj-eyal",
		__allow_rod_recall = true,
		__allow_transmo_chest = true,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Infinite",
	display_name = "Infinite Dungeon: The Neverending Descent",
	locked = function() return profile.mod.allow_build.campaign_infinite_dungeon end,
	locked_desc = "Ever deeper, never ending, no reprieve, keep descending. In ruins old, through barred gate, once riddle solved, find thy fate.",
	desc =
	{
		"Play as your favorite race and class and venture into the infinite dungeon.",
		"The only limit to how far you can go is your own skill!",
		"Inside the infinite dungeon you will yourself be limitless. You can level up beyond level 50 and continue to gain stat and talent points (at a reduced rate).",
		"Every level after level 50 the maximum of stats will increase by one.",
		"Every 10 levels after level 50 the maximum points of each talent will increase by one.",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never"} },
	copy = {
		-- Can levelup forever
		resolvers.generic(function(e) e.max_level = nil end),
		no_points_on_levelup = function(self)
			if self.level <= 50 then
				self.unused_stats = self.unused_stats + (self.stats_per_level or 3) + self:getRankStatAdjust()
				self.unused_talents = self.unused_talents + 1
				self.unused_generics = self.unused_generics + 1
				if self.level % 5 == 0 then self.unused_talents = self.unused_talents + 1 end
				if self.level % 5 == 0 then self.unused_generics = self.unused_generics - 1 end
				if self.level == 10 or  self.level == 20 or self.level == 30 or self.level == 40 then
					self.unused_talents_types = self.unused_talents_types + 1
				end
				if self.level == 40 or self.level == 50 then
					self.unused_prodigies = self.unused_prodigies + 1
				end
			else
				self.unused_stats = self.unused_stats + 1
				if self.level % 2 == 0 then
					self.unused_talents = self.unused_talents + 1
				elseif self.level % 3 == 0 then
					self.unused_generics = self.unused_generics + 1
				end
			end
		end,

		resolvers.equip{ id=true, {name="iron pickaxe", ego_chance=-1000}},
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "infinite-dungeon"
			self.starting_quest = "infinite-dungeon"
			self.starting_intro = "infinite-dungeon"
		end,
	},
	game_state = {
		campaign_name = "infinite-dungeon",
		__allow_transmo_chest = true,
		is_infinite_dungeon = true,
		ignore_prodigies_special_reqs = true,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Arena",
	display_name = "The Arena: Challenge of the Master",
	locked = function() return profile.mod.allow_build.campaign_arena end,
	locked_desc = "Blood spilled on sand, only the strong survive. Prove yourself worthy to enter.",
	desc =
	{
		"Play as a lone warrior facing the Arena's challenge!",
		"You can use any class and race for it.",
		"See how far you can go! Can you become the new Master of the Arena?",
		"If so, you will battle your own champion next time!",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never" }, permadeath = { Exploration = "never", Adventure = "never" } },
	copy = {
		death_dialog = "ArenaFinish",
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "arena"
			self.starting_quest = "arena"
			self.starting_intro = "arena"
		end,
	},
	game_state = {
		campaign_name = "arena",
		is_arena = true,
		ignore_prodigies_special_reqs = true,
	},
}

