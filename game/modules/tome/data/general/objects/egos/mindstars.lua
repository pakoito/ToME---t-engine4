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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

-------------------------------------------------------
--Nature and Antimagic---------------------------------
-------------------------------------------------------
 newEntity{
	power_source = {arcane=true},
	power_source = {nature=true},
	name = "summoner's	", prefix=true, instant_resolve=true,
	keywords = {summoners=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "druid's ", prefix=true, instant_resolve=true,
	keywords = {druid=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "nature's ", prefix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "wyrmic's ", prefix=true, instant_resolve=true,
	keywords = {wyrmic=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of harmony", suffix=true, instant_resolve=true,
	keywords = {harmony=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "fire-drake's ", prefix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "cold-drake's ", prefix=true, instant_resolve=true,
	keywords = {cold=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "storm-drake's ", prefix=true, instant_resolve=true,
	keywords = {storm=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "sand-drake's ", prefix=true, instant_resolve=true,
	keywords = {storm=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of calling", suffix=true, instant_resolve=true,
	keywords = {calling=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the arch-druid", suffix=true, instant_resolve=true,
	keywords = {archdruid=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the great-wyrm", suffix=true, instant_resolve=true,
	keywords = {wyrm=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

-------------------------------------------------------
--Psionic----------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {psionic=true},
	name = "gifted ", prefix=true, instant_resolve=true,
	keywords = {gifted=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "psychic's ", prefix=true, instant_resolve=true,
	keywords = {psychic=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of nightmares", suffix=true, instant_resolve=true,
	keywords = {night=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
 	name = " of power", suffix=true, instant_resolve=true,
 	keywords = {power=true},
 	level_range = {1, 50},
	wielder = {
 		combat_mindpower = resolvers.mbonus_material(16, 3),
 	},
 }

newEntity{
	power_source = {psionic=true},
	name = " of shrouds", suffix=true, instant_resolve=true,
	keywords = {shrouds=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "spire dragon's ", prefix=true, instant_resolve=true,
	keywords = {spire=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of convergence", suffix=true, instant_resolve=true,
	keywords = {conv=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}