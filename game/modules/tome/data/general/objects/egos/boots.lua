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
	name = " of phasing", suffix=true, instant_resolve=true,
	keywords = {phasing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2),
		},
	},
	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("blink to a nearby random location", 25, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower())
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	power_source = {technique=true},
	name = " of uncanny dodging", suffix=true, instant_resolve=true,
	keywords = {['u.dodge']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of speed", suffix=true, instant_resolve=true,
	keywords = {speed=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		movement_speed = 0.2,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of rushing", suffix=true, instant_resolve=true,
	keywords = {rushing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	resolvers.charmt(Talents.T_RUSH, {1,2,3}, 25),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_CON] = resolvers.mbonus_material(2, 2),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of disengagement", suffix=true, instant_resolve=true,
	keywords = {disengage=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,

	resolvers.charmt(Talents.T_DISENGAGE, {1,2,3}, 25),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	keywords = {stability=true},
	level_range = {20, 50},
	rarity = 12,
	cost = 12,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of tirelessness", suffix=true, instant_resolve=true,
	keywords = {tireless=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 7,
	wielder = {
		max_stamina = resolvers.mbonus_material(30, 10),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "traveler's ", prefix=true, instant_resolve=true,
	keywords = {traveler=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(30, 20),
	},
}


newEntity{
	power_source = {arcane=true},
	name = "scholar's ", prefix=true, instant_resolve=true,
	keywords = {scholar=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = "miner's ", prefix=true, instant_resolve=true,
	keywords = {miner=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 4),
	},
}

newEntity{
	power_source = {technique=true},
	name = "stalker's ", prefix=true, instant_resolve=true,
	keywords = {stalker=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {nature=true},
	name = "restorative ", prefix=true, instant_resolve=true,
	keywords = {restorative=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		cut_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		life_regen = resolvers.mbonus_material(10, 5, function(e, v) v=v/10 return 0, v end),
		poison_immune = resolvers.mbonus_material(10, 10, function(e, v) return 0, v/100 end),

	},
}

newEntity{
	power_source = {nature=true},
	name = "invigorating ", prefix=true, instant_resolve=true,
	keywords = {['invigor.']=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 70,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
		max_life=resolvers.mbonus_material(30, 30),
		movement_speed = 0.1,
	},
}

newEntity{
	power_source = {technique=true},
	name = "blood-soaked ", prefix=true, instant_resolve=true,
	keywords = {blood=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	wielder = {
		combat_dam = resolvers.mbonus_material(3, 3),
		combat_apr = resolvers.mbonus_material(3, 3),
		pin_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blightbringer's ", prefix=true, instant_resolve=true,
	keywords = {blight=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 80,
	max_power = 80, power_regen = 1,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(20, 10, function(e, v) return 0, -v end),
			[DamageType.LIGHT] = resolvers.mbonus_material(20, 10, function(e, v) return 0, -v end),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(7, 3),
		},
		pin_immune = resolvers.mbonus_material(50, 40, function(e, v) v=v/100 return 0, v end),
		combat_spellpower = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = "wanderer's ", prefix=true, instant_resolve=true,
	keywords = {wanderer=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		blind_immune = resolvers.mbonus_material(15, 5, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 5, function(e, v) v=v/100 return 0, v end),
		disease_immune = resolvers.mbonus_material(15, 5, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "reinforced ", prefix=true, instant_resolve=true,
	keywords = {reinforced=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "eldritch ", prefix=true, instant_resolve=true,
	keywords = {eldritch=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		max_mana = resolvers.mbonus_material(40, 20),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
		combat_spellcrit = resolvers.mbonus_material(4, 1),
	},
}

newEntity{
	power_source = {nature=true},
	name = "grounded ", prefix=true, instant_resolve=true,
	keywords = {grounded=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
		},
		stun_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of heaving", suffix=true, instant_resolve=true,
	keywords = {heaving=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.charmt(Talents.T_HEAVE, {2,3,4}, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
		},
		knockback_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		poison_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of invasion", suffix=true, instant_resolve=true,
	keywords = {invasion=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		disarm_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_physcrit = resolvers.mbonus_material(4, 1),
		combat_dam = resolvers.mbonus_material(3, 3),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of spellbinding", suffix=true, instant_resolve=true,
	keywords = {spellbinding=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		combat_spellresist = resolvers.mbonus_material(7, 1),
		spell_cooldown_reduction = 0.1,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of evasion", suffix=true, instant_resolve=true,
	keywords = {evasion=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.charmt(Talents.T_EVASION, {2,3,4}, 30),
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(7, 1),
		combat_physresist = resolvers.mbonus_material(7, 1),
		combat_spellresist = resolvers.mbonus_material(7, 1),
	},
}
