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
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"


--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of cunning (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of willpower (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of mastery (#MASTERY#)", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 2,
	wielder = {},
	resolvers.generic(function(e)
		local tts = {}
		for i, def in ipairs(engine.interface.ActorTalents.talents_types_def) do
			if def.allow_random then tts[#tts+1] = def.type end
		end
		local tt = tts[rng.range(1, #tts)]

		e.wielder.talents_types_mastery = {}
		local v = (10 + rng.mbonus(math.ceil(30 * e.material_level / 5), resolvers.current_level, 50)) / 100
		e.wielder.talents_types_mastery[tt] = v
		e.cost = e.cost + v * 60
	end),
}
newEntity{
	name = " of greater telepathy", suffix=true,
	level_range = {40, 50},
	greater_ego = true,
	rarity = 120,
	cost = 25,
	wielder = {
		life_regen = -3,
		esp = {all=1},
	},
}
newEntity{
	name = " of telepathic range", suffix=true,
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		esp = {range=10},
	},
}
newEntity{
	name = " of the fish", suffix=true,
	level_range = {25, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		can_breath = {water=1},
	},
}

newEntity{
	name = " of teleportation", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		teleport_immune = 0.5,
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
	name = "insulating ", prefix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
	},
}

newEntity{
	name = "grounding ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "stabilizing ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "shielding ", prefix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		blind_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		confusion_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "cleansing ", prefix=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		poison_immune = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15, v/100 end),
		disease_immune = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15, v/100 end),
	},
}

newEntity{
	name = "vitalizing ", prefix=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 15,
	cost = 30,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		inc_stats={
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end),
		},
		combat_physresist = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		max_life = resolvers.mbonus_material(50, 30, function(e, v) return v * 0.1 end),
		life_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return v * 10, v end),
		max_stamina = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.1 end),
	},
}


newEntity{
	name = " of murder", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 1.4 end),
		combat_critical_power = resolvers.mbonus_material(10, 10, function(e, v) v=v/100 return v * 200, v end),
		combat_atk = resolvers.mbonus_material(5, 5, function(e, v) return v * 1 end),
		combat_apr = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.3 end),
	},
}


newEntity{
	name = " of vision", suffix=true, instant_resolve=true,
	level_range = {25, 50},
	greater_ego = true,
	rarity = 15,
	cost = 30,
	wielder = {
		see_invisible = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.2 end),
		blind_immune = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
		infravision = resolvers.mbonus_material(2, 1, function(e, v) return v * 1.4 end),
		trap_detect_power = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.2 end),
	},
}


newEntity{
	name = " of healing", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		cut_immune = resolvers.mbonus_material(4, 4, function(e, v) v=v/10 return v * 8, v end),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_HEAL, level = 3, power = 80 },
}

newEntity{
	name = "protective ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(3, 2, function(e, v) return v * 1 end),
		combat_def = resolvers.mbonus_material(4, 4, function(e, v) return v * 1 end),
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "enraging ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = true,
	rarity = 20,
	cost = 90,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5, function(e, v) return v * 3 end),
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.8 end) },
		combat_physspeed = -0.1,
	},
}


newEntity{
	name = "archmage's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.8 end),
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.25 end),
			[DamageType.COLD] = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.25 end),
			[DamageType.ACID] = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.25 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.25 end),
		},
	},
}
