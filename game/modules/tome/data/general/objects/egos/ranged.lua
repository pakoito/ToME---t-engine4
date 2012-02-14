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
local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")



newEntity{
	power_source = {technique=true},
	name = " of power", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material("combat_apr", 4)},
}

newEntity{
	power_source = {technique=true},
	name = "mighty ", prefix=true, instant_resolve=true,
	keywords = {mighty=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		dam = resolvers.mbonus_material("dam"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "steady ", prefix=true, instant_resolve=true,
	keywords = {steady=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		learn_talent = {
			[Talents.T_STEADY_SHOT] = resolvers.mbonus_material("learn_talent"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of crippling", suffix=true, instant_resolve=true,
	keywords = {crippling=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 7,
	combat = {
		critical_power = resolvers.mbonus_material("critical_power"),
	}
}

newEntity{
	power_source = {technique=true},
	name = " of speed", suffix=true, instant_resolve=true,
	keywords = {speed=true},
	level_range = {20, 50},
	rarity = 7,
	cost = 7,
	combat = {
		physspeed = resolvers.mbonus_material("physspeed", -1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "tracker's ", prefix=true, instant_resolve=true,
	keywords = {tracker=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		learn_talent = {
			[Talents.T_TRACK] = resolvers.mbonus_material("learn_talent"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of range", suffix=true, instant_resolve=true,
	keywords = {range=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	resolvers.generic(function(e)
		e.combat.range = e.combat.range + 1
	end),
}

newEntity{
	power_source = {technique=true},
	name = "swiftstrike ", prefix=true, instant_resolve=true,
	keywords = {swiftstrike=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	combat = {travel_speed = 200,},
}

newEntity{
	power_source = {technique=true},
	name = " of true flight", suffix=true, instant_resolve=true,
	keywords = {flight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	combat = {
		critical_power = resolvers.mbonus_material("critical_power"),
		travel_speed = 200
	},
	resolvers.generic(function(e)
		e.combat.range = e.combat.range + 1
	end),
}

newEntity{
	power_source = {technique=true},
	name = "penetrating ", prefix=true, instant_resolve=true,
	keywords = {penetrating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	combat = {
		apr = resolvers.mbonus_material("combat_apr", 4),
	},
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists_pen", 2),
		},
		learn_talent = {
			[Talents.T_PIERCING_ARROW] = resolvers.mbonus_material("learn_talent"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "phase-shifting ", prefix=true, instant_resolve=true,
	keywords = {phase=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	combat = {
		tg_type = "beam",
	},
	resolvers.generic(function(e)
		e.combat.dam = 0
		e.combat.dammod = {dex=0}
	end),
}

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
	power_source = {arcane=true},
	name = " of spellstriking", suffix=true, instant_resolve=true,
	keywords = {spellstrike=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 30,
	combat = {
		affects_spells = true,
		talent_on_hit = {
			[Talents.T_DISPERSE_MAGIC] = {
				level=3,
				chance = resolvers.mbonus_material("talent_on_hit_chance"),
				} ,
			},
	},
	resolvers.generic(function(e)
		e.combat.dammod.mag = e.combat.dammod.dex
	end),
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
	name = " of savagery", suffix=true, instant_resolve=true,
	keywords = {savage=true},
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
