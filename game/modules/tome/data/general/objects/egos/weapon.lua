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
	keywords = {flaming=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.FIRE] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	keywords = {icy=true},
	level_range = {15, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material("melee_project", 0.5, true)},
	},
}
newEntity{
	power_source = {nature=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	keywords = {acidic=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.ACID] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "shocking ", prefix=true, instant_resolve=true,
	keywords = {shocking=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}

newEntity{
	power_source = {nature=true},
	name = "slime-covered ", prefix=true, instant_resolve=true,
	keywords = {slime=true},
	level_range = {10, 50},
	rarity = 5,
	combat = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material("melee_project", 0.5, true)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of accuracy", suffix=true, instant_resolve=true,
	keywords = {accuracy=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {max_acc = resolvers.mbonus_material("max_acc")},
}

newEntity{
	power_source = {arcane=true},
	name = "phase ", prefix=true, instant_resolve=true,
	keywords = {phase=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat = {apr = resolvers.mbonus_material("combat_apr", 4)},
}

newEntity{
	power_source = {arcane=true},
	name = "elemental ", prefix=true, instant_resolve=true,
	keywords = {elemental=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	combat = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material("melee_project", 0.5, true),
			[DamageType.ICE] = resolvers.mbonus_material("melee_project", 0.5, true),
			[DamageType.ACID] = resolvers.mbonus_material("melee_project", 0.5, true),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project", 0.5, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of massacre", suffix=true, instant_resolve=true,
	keywords = {massacre=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		dam = resolvers.mbonus_material("dam", 1, true),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of torment", suffix=true, instant_resolve=true,
	keywords = {torment=true},
	level_range = {1, 50},
	rarity = 18,
	cost = 22,
	combat = {
		special_on_hit = {desc="30% chance to torment the target", fct=function(combat, who, target)
			if not rng.percent(30) then return end
			local eff = rng.table{"stun", "blind", "pin", "confusion", "silence"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "blind" then target:setEffect(target.EFF_BLINDED, 3, {})
			elseif eff == "pin" then target:setEffect(target.EFF_PINNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			end
		end},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of rage", suffix=true, instant_resolve=true,
	keywords = {rage=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	wielder = {
		stamina_regen_on_hit = resolvers.mbonus_material("stamina_regen_on_hit"),
	},
	combat = {
		apr = resolvers.mbonus_material("combat_apr", 3),
		dam = resolvers.mbonus_material("dam", 1, true),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of corruption", suffix=true, instant_resolve=true,
	keywords = {corruption=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	combat = {
		melee_project={
			[DamageType.BLIGHT] = resolvers.mbonus_material("melee_project", 1, true),
			[DamageType.DARKNESS] = resolvers.mbonus_material("melee_project", 1, true),
		},
	},

}

newEntity{
	power_source = {technique=true},
	name = " of crippling", suffix=true, instant_resolve=true,
	keywords = {crippling=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		critical_power = resolvers.mbonus_material("critical_power"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of daylight", suffix=true, instant_resolve=true,
	keywords = {daylight=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		melee_project={[DamageType.LIGHT] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}
--[=[
newEntity{
	power_source = {technique=true},
	name = " of defense", suffix=true, instant_resolve=true,
	keywords = {defense=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_def = resolvers.mbonus_material(7, 3),
	},
}
]=]
newEntity{
	power_source = {technique=true},
	name = " of ruin", suffix=true, instant_resolve=true,
	keywords = {ruin=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	combat = {
		max_acc = resolvers.mbonus_material("max_acc"),
		critical_power = resolvers.mbonus_material("critical_power"),
		melee_project={[DamageType.TEMPORAL] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}

newEntity{
	power_source = {technique=true},
	name = "quick ", prefix=true, instant_resolve=true,
	keywords = {quick=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 30,
	combat = {
		physspeed = resolvers.mbonus_material("physspeed"),
		max_acc = resolvers.mbonus_material("max_acc"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "mystic ", prefix=true, instant_resolve=true,
	keywords = {mystic=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 30,
	combat = {
		affects_spells = true,
		melee_project={[DamageType.ARCANE] = resolvers.mbonus_material("melee_project", 1, true)},
	},
}

newEntity{
	power_source = {technique=true},
	name = "blazebringer's ", prefix=true, instant_resolve=true,
	keywords = {blaze=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
	combat = {
		melee_project = {
			[DamageType.FIRE] = resolvers.mbonus_material("melee_project", 2, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "glacial ", prefix=true, instant_resolve=true,
	keywords = {glacial=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
	combat = {
		melee_project = {
			[DamageType.COLD] = resolvers.mbonus_material("melee_project", 2, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "thunderous ", prefix=true, instant_resolve=true,
	keywords = {thunder=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		resists_pen = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
	combat = {
		melee_project = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project", 2, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "caustic ", prefix=true, instant_resolve=true,
	keywords = {caustic=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		resists_pen = {
			[DamageType.ACID] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
	combat = {
		melee_project = {
			[DamageType.ACID] = resolvers.mbonus_material("melee_project", 2, true),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "vile ", prefix=true, instant_resolve=true,
	keywords = {vile=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		resists_pen = {
			[DamageType.NATURE] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
	combat = {
		melee_project = {
			[DamageType.SLIME] = resolvers.mbonus_material("melee_project", 1, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "warbringer's ", prefix=true, instant_resolve=true,
	keywords = {warbringer=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		talents_types_mastery = {
			["technique/combat-training"] = resolvers.mbonus_material("talents_types_mastery"),
		},
		learn_talent = {
			[Talents.T_GREATER_WEAPON_FOCUS] = resolvers.mbonus_material("learn_talent"),
		},
	},

}

newEntity{
	power_source = {technique=true},
	name = " of shearing", suffix=true, instant_resolve=true,
	keywords = {shearing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	combat = {
		apr = resolvers.mbonus_material("combat_apr", 5),
	},
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists_pen", 1, true),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of plague", suffix=true, instant_resolve=true,
	keywords = {plague=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_EPIDEMIC, level = 5, power = 10 },
	combat = {
		melee_project = {
			[DamageType.BLIGHT] = resolvers.mbonus_material("melee_project", 2, true),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of projection", suffix=true, instant_resolve=true,
	keywords = {projection=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_WAVE_OF_POWER, level = 4, power = 10 },
}

newEntity{
	power_source = {technique=true},
	name = " of sacrifice", suffix=true, instant_resolve=true,
	keywords = {sacrifice=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_LIFE_TAP, level = 5, power = 30 },
	combat = {
		dam = resolvers.mbonus_material("dam", 2, true),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of paradox", suffix=true, instant_resolve=true,
	keywords = {paradox=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	combat = {
		melee_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material("melee_project", 2, true),
			[DamageType.RANDOM_CONFUSION] = resolvers.mbonus_material("melee_project", 0.5, true),
		},
	},
}

--[[ Todo: make it balanced
newEntity{
	power_source = {technique=true},
	name = " of concussion", suffix=true, instant_resolve=true,
	keywords = {concussion=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	resolvers.generic(function(e)
		e.combat.concussion = (e.combat.critical_power - 1) * 100
	end),
}

newEntity{
	power_source = {technique=true},
	name = " of savagery", suffix=true, instant_resolve=true,
	keywords = {savagery=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		learn_talent = {
			[Talents.T_SAVAGERY] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}
]]
