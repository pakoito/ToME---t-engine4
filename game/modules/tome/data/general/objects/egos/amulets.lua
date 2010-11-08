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
		local tts = {
			"cunning/dirty",
			"cunning/lethality",
			"cunning/stealth",
			"cunning/survival",
			"spell/air",
			"spell/arcane",
			"spell/conveyance",
			"spell/divination",
			"spell/earth",
			"spell/fire",
			"spell/meta",
			"spell/nature",
			"spell/phantasm",
			"spell/temporal",
			"spell/water",
			"technique/2hweapon-cripple",
			"technique/2hweapon-offense",
			"technique/archery-bow",
			"technique/archery-sling",
			"technique/archery-training",
			"technique/archery-utility",
			"technique/combat-techniques-active",
			"technique/combat-techniques-passive",
			"technique/combat-training",
			"technique/dualweapon-attack",
			"technique/dualweapon-training",
			"technique/shield-defense",
			"technique/shield-offense",
			"wild-gift/call",
			"wild-gift/cold-drake",
			"wild-gift/fire-drake",
			"wild-gift/sand-drake",
			"wild-gift/slime",
			"wild-gift/summon-augmentation",
			"wild-gift/summon-distance",
			"wild-gift/summon-melee",
			"wild-gift/summon-utility",
		}
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
	name = "shielding ", prefix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		blind_immune = 0.15,
		confusion_immune = 0.15,
	},
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
	name = "grounding ", prefix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		stun_immune = 0.1,
	},
}

newEntity{
	name = "stabilizing ", prefix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = 0.15,
		knockback_immune = 0.15,
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
		combat_physresist = 5,
		max_life = resolvers.mbonus_material(50, 30, function(e, v) return v * 0.1 end),
		life_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return v * 10, v end),
		max_stamina = 20,
	},
}
