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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3, function(e, v) return v * 0.8 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		max_mana = resolvers.mbonus_material(70, 40, function(e, v) return v * 0.2 end),
	},
}


newEntity{
	power_source = {arcane=true},
	name = " of might", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.4 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of wizardry", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3, function(e, v) return v * 0.6 end),
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.2 end),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end), [Stats.STAT_WIL] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end) },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "magma ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crackling ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "naturalist ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "sunbathed ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHT] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.DARKNESS] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of divination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		talents_types_mastery = {
			["spell/divination"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conveyance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		talents_types_mastery = {
			["spell/conveyance"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		},
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "teleport you anywhere on the level, randomly", power = 60, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	power_source = {nature=true},
	name = " of illumination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		lite = 1,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_ILLUMINATE, level = 2, power = 80 },
}

newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3, function(e, v) return v * 0.6 end),
		combat_spellcrit = resolvers.mbonus_material(4, 2, function(e, v) return v * 0.4 end),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 2, power = 80 },
}


newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 20,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3, function(e, v) return v * 0.6 end),
		stun_immune = resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return v * 8, v end),
		combat_def = resolvers.mbonus_material(16, 4, function(e, v) return v * 1 end),
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		},
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISPLACEMENT_SHIELD, level = 4, power = 80 },
}

newEntity{
	power_source = {arcane=true},
	name = " of channeling", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3, function(e, v) return v * 0.6 end),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_METAFLOW, level = 3, power = 80 },
}

newEntity{
	power_source = {nature=true},
	name = "lifebinding ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.6 end),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return v * 10, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "infernal ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.6 end),
		see_invisible = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.2 end),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5, function(e, v) return v * 0.25 end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 5, function(e, v) return v * 0.25 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "chronomancer's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.6 end),
		movement_speed = -0.1,
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(20, 5, function(e, v) return v * 0.25 end),
		},
	},

}

