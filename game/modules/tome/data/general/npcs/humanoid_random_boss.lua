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

-- Those are never generated randomly, but used when we want humanoid random bosses

newEntity{
	define_as = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.UMBER,

	level_range = {1, nil},
	infravision = 10,
	lite = 1,

	life_rating = 10,
	rank = 3,
	size_category = 3,

	open_door = true,
}

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	name = "human", subtype = "human", color=colors.LIGHT_UMBER,
	resolvers.generic(function(e)
		if rng.percent(50) then
			e.female = true
			image = "player/cornac_female.png"
		else
			image = "player/cornac_male.png"
		end
		e.moddable_tile = "human_#sex#"
		e.moddable_tile_base = "base_cornac_01.png"
	end),
	random_name_def = "cornac_#sex#",
	humanoid_random_boss = 1,
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	name = "thalore", subtype = "thalore", color=colors.LIGHT_GREEN,
	resolvers.generic(function(e)
		if rng.percent(50) then
			e.female = true
			image = "player/thalore_female.png"
		else
			image = "player/thalore_male.png"
		end
		e.moddable_tile = "elf_#sex#"
		e.moddable_tile_base = "base_thalore_01.png"
		e.moddable_tile_ornament = {female="braid_01"}
	end),
	random_name_def = "thalore_#sex#",
	humanoid_random_boss = 1,
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	name = "shalore", subtype = "shalore", color=colors.LIGHT_BLUE,
	resolvers.generic(function(e)
		if rng.percent(50) then
			e.female = true
			image = "player/shalore_female.png"
		else
			image = "player/shalore_male.png"
		end
		e.moddable_tile = "elf_#sex#"
		e.moddable_tile_base = "base_shalore_01.png"
		e.moddable_tile_ornament = {female="braid_02"}
	end),
	random_name_def = "shalore_#sex#", random_name_max_syllables = 4,
	humanoid_random_boss = 1,
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	name = "halfling", subtype = "halfling", color=colors.BLUE,
	resolvers.generic(function(e)
		if rng.percent(50) then
			e.female = true
			image = "player/halfling_female.png"
		else
			image = "player/halfling_male.png"
		end
		e.moddable_tile = "halfling_#sex#"
	end),
	random_name_def = "halfling_#sex#",
	humanoid_random_boss = 1,
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS",
	name = "dwarf", subtype = "dwarf", color=colors.UMBER,
	resolvers.generic(function(e)
		if rng.percent(50) then
			e.female = true
			image = "player/dwarf_female.png"
		else
			image = "player/dwarf_male.png"
		end
		e.moddable_tile = "dwarf_#sex#"
	end),
	random_name_def = "dwarf_#sex#",
	humanoid_random_boss = 2,
	resolvers.racial(),
}
