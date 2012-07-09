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
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {nature=true},
	name = " of cunning (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {cunning=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {nature=true},
	name = " of willpower (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {willpower=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {nature=true},
	name = " of mastery (#MASTERY#)", suffix=true,
	keywords = {mastery=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {},
	resolvers.generic(function(e)
		local tts = {}
		local p = game:getPlayer(true)
		for i, def in ipairs(engine.interface.ActorTalents.talents_types_def) do
			if p and def.allow_random and p:knowTalentType(def.type) or p:knowTalentType(def.type) == false then tts[#tts+1] = def.type end
		end
		local tt = tts[rng.range(1, #tts)]

		e.wielder.talents_types_mastery = {}
		local v = (10 + rng.mbonus(math.ceil(30 * e.material_level / 5), resolvers.current_level, 50)) / 100
		e.wielder.talents_types_mastery[tt] = v
		e.cost = e.cost + v * 60
	end),
}
newEntity{
	power_source = {nature=true},
	name = " of the fish", suffix=true,
	keywords = {fish=true},
	level_range = {25, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		can_breath = {water=1},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of teleportation", suffix=true, instant_resolve=true,
	keywords = {teleport=true},
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		teleport_immune = 0.5,
	},
	charm_power = resolvers.mbonus_material(70, 30),
	charm_power_def = {add=15, max=50, floor=true},
	resolvers.charm("teleports your randomly (rad %d)", 15, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower())
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}



newEntity{
	power_source = {nature=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulating=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	keywords = {grounding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchoring=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
		teleport_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	keywords = {stabilizing=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "shielding ", prefix=true, instant_resolve=true,
	keywords = {shielding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		blind_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	keywords = {cleansing=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
		poison_immune = resolvers.mbonus_material(10, 5, function(e, v) return 0, v/100 end),
		disease_immune = resolvers.mbonus_material(10, 5, function(e, v) return 0, v/100 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "restful ", prefix=true, instant_resolve=true,
	keywords = {restful=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 6,
	cost = 10,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "vitalizing ", prefix=true, instant_resolve=true,
	keywords = {vitalizing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
		inc_stats={
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2),
		},
		combat_physresist = resolvers.mbonus_material(5, 5),
		max_life = resolvers.mbonus_material(50, 30),
		life_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return 0, v end),
		max_stamina = resolvers.mbonus_material(20, 10),
	},
}


newEntity{
	power_source = {technique=true},
	name = " of murder", suffix=true, instant_resolve=true,
	keywords = {murder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(3, 3),
		combat_critical_power = resolvers.mbonus_material(10, 10),
		combat_atk = resolvers.mbonus_material(5, 5),
		combat_apr = resolvers.mbonus_material(4, 4),
	},
}


newEntity{
	power_source = {nature=true},
	name = " of vision", suffix=true, instant_resolve=true,
	keywords = {vision=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		see_invisible = resolvers.mbonus_material(10, 5),
		blind_immune = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		infravision = resolvers.mbonus_material(2, 1),
		trap_detect_power = resolvers.mbonus_material(15, 5),
	},
}


newEntity{
	power_source = {nature=true},
	name = " of healing", suffix=true, instant_resolve=true,
	keywords = {healing=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		cut_immune = resolvers.mbonus_material(4, 4, function(e, v) v=v/10 return 0, v end),
	},

	resolvers.charmt(Talents.T_HEAL_NATURE, {1,2,3}, 80),
}

newEntity{
	power_source = {technique=true},
	name = "protective ", prefix=true, instant_resolve=true,
	keywords = {protect=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(3, 2),
		combat_def = resolvers.mbonus_material(4, 4),
		combat_physresist = resolvers.mbonus_material(20, 7),
	},
}

newEntity{
	power_source = {technique=true},
	name = "enraging ", prefix=true, instant_resolve=true,
	keywords = {enraging=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 90,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(5, 5) },
		combat_physspeed = 0.1,
	},
}


newEntity{
	power_source = {arcane=true},
	name = "archmage's ", prefix=true, instant_resolve=true,
	keywords = {archmage=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 40,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(4, 4),
			[DamageType.COLD] = resolvers.mbonus_material(4, 4),
			[DamageType.ACID] = resolvers.mbonus_material(4, 4),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(4, 4),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "warmaker's ", prefix=true, instant_resolve=true,
	keywords = {warmaker=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 80,

	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(20, 10, function(e, v) return 0, -v end),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 4),
		},
		combat_spellresist = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),

	},
}

newEntity{
	power_source = {psionic=true},
	name = "mindweaver's ", prefix=true, instant_resolve=true,
	keywords = {mindweaver=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "savior's ", prefix=true, instant_resolve=true,
	keywords = {savior=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "wanderer's ", prefix=true, instant_resolve=true,
	keywords = {wanderer=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_CUN] = resolvers.mbonus_material(7, 3),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "serendipitous ", prefix=true, instant_resolve=true,
	keywords = {['serend.']=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_LCK] = resolvers.mbonus_material(12, 8),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of soulsearing", suffix=true, instant_resolve=true,
	keywords = {soulsear=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 90,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
		},
		combat_spellpower = resolvers.mbonus_material(10, 5),
		combat_critical_power = resolvers.mbonus_material(30, 10),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of seduction", suffix=true, instant_resolve=true,
	keywords = {seducion=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		max_stamina = resolvers.mbonus_material(30, 10),
		stamina_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of manastreaming", suffix=true, instant_resolve=true,
	keywords = {manastream=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		max_mana = resolvers.mbonus_material(40, 20),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the chosen", suffix=true, instant_resolve=true,
	keywords = {chosen=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
		},
		on_melee_hit = {
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
		},
		melee_project={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}