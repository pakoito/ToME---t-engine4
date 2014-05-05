-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

newEntity{ base = "BASE_LORE_RANDOM",
	name = "The story of my salvation", lore="zigur-potion", unique=true,
	desc = [[An old tale about the fear of magic.]],
	level_range = {1, 20},
	rarity = 40,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "On Adventuring", lore="kestin-highfin-adventuring-notes", unique=true,
	desc = [[Fragments of a fabled traveler.]],
	level_range = {10, 25},
	rarity = 35,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "memories of Artelia Firstborn", lore="creation-elf", unique=true,
	desc = [[The memories of the first elf ever to awaken.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only elves can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Elf" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "human myth of creation", lore="creation-human", unique=true,
	desc = [[Myth of creation of the humans.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only humans can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Human" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "a logical analysis of creation, by philosopher Smythen", lore="creation-halfling", unique=true,
	desc = [[Myth of creation of the halflings.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only hhalflings can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Halfling" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "Tale of the Moonsisters", lore="moons-human", unique=true,
	desc = [[The creation of Eyal's moons.]],
	level_range = {1, 35},
	rarity = 40,
	-- Only humans can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Human" then return true end return false end,
}
