-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

--load("/data/general/objects/egos/charged-attack.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{
	power_source = {arcane=true},
	name = "flaming ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4)},
	},
}
newEntity{
	power_source = {nature=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "shocking ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4)},
	},
}

newEntity{
	power_source = {nature=true},
	name = "poisonous ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.POISON] = resolvers.mbonus_material(45, 6)},
	},
}

newEntity{
	power_source = {nature=true},
	name = "slime-covered ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(45, 6)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of accuracy", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat={atk = resolvers.mbonus_material(20, 5)},
}

newEntity{
	power_source = {arcane=true},
	name = "phase ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material(20, 5)},
}

newEntity{
	power_source = {arcane=true},
	name = "elemental ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	combat = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(25, 4),
			[DamageType.ICE] = resolvers.mbonus_material(15, 4),
			[DamageType.ACID] = resolvers.mbonus_material(25, 4),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of massacre", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		dam = resolvers.mbonus_material(15, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of torment", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 18,
	cost = 22,
	combat = {
		special_on_hit = {desc="10% chance to torment the target", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			local eff = rng.table{"stun", "blind", "pin", "teleport", "stone", "confusion", "silence", "knockback"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "blind" then target:setEffect(target.EFF_BLINDED, 3, {})
			elseif eff == "pin" then target:setEffect(target.EFF_PINNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			elseif eff == "knockback" then target:knockback(who.x, who.y, 3)
			elseif eff == "teleport" then target:teleportRandom(target.x, target.y, 10)
			end
		end},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of rage", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	wielder = {
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 4),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(4, 3),
			[Stats.STAT_STR] = resolvers.mbonus_material(4, 3),
		},
		stamina_regen_on_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
	},
	combat = {
		apr = resolvers.mbonus_material(8, 1),
		atk = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of corruption", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	combat = {
		melee_project={
			[DamageType.BLIGHT] = resolvers.mbonus_material(25, 4),
			[DamageType.DARKNESS] = resolvers.mbonus_material(25, 4),
		},
	},
	wielder = {
		see_invisible = resolvers.mbonus_material(20, 5),
		combat_physcrit = resolvers.mbonus_material(10, 4),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of crippling", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of daylight", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		melee_project={[DamageType.LIGHT] = resolvers.mbonus_material(45, 6)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of defense", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_def = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of ruin", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(4, 3),
		},
		combat_physcrit = resolvers.mbonus_material(7, 3),
		combat_critical_power = resolvers.mbonus_material(10, 10),
		combat_apr = resolvers.mbonus_material(7, 3),
	},

}

newEntity{
	power_source = {technique=true},
	name = "quick ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 30,
	combat = { physspeed = -0.1 },
	wielder = {
		combat_atk = resolvers.mbonus_material(20, 2),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(4, 3),
			[Stats.STAT_CUN] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "mystic ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 30,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(7, 3),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 3),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "blazebringer's ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.FIRE] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "glacial ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.ICE] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material(20, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.COLD] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "thunderous ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "caustic ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.ACID] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.ACID] = resolvers.mbonus_material(20, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.ACID] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "vile ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.SLIME] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.NATURE] = resolvers.mbonus_material(20, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.SLIME] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "warbringer's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(9, 1),
		},
		disarm_immune = resolvers.mbonus_material(25, 10, function(e, v) v=v/100 return 0, v end),
		combat_dam = resolvers.mbonus_material(15, 5),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of shearing", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_apr = resolvers.mbonus_material(15, 5),
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of plague", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_EPIDEMIC, level = 4, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		disease_immune = resolvers.mbonus_material(55, 10, function(e, v) v=v/100 return 0, v end),
	},
	combat = {
		melee_project = {
			[DamageType.BLIGHT] = resolvers.mbonus_material(46, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of projection", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_WAVE_OF_POWER, level = 4, power = 12 },
}

newEntity{
	power_source = {technique=true},
	name = " of sacrifice", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_LIFE_TAP, level = 3, power = 80 },
	wielder = {
		combat_physcrit = resolvers.mbonus_material(4, 3),
		combat_dam = resolvers.mbonus_material(12, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of paradox", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
		},
		on_melee_hit = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(46, 5),
		},
	},
}

