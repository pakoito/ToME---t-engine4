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

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {technique=true},
	name = "cruel ", prefix=true, instant_resolve=true,
	keywords = {cruel=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_critical_power = resolvers.mbonus_material(10, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "earthen ", prefix=true, instant_resolve=true,
	keywords = {earthen=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 2),
		combat_physresist = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "potent ", prefix=true, instant_resolve=true,
	keywords = {potent=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	combat = {
		dam = resolvers.mbonus_material(10, 2),
	},
	resolvers.genericlast(function(e)
		e.wielder.inc_damage[e.combat.damtype] = e.combat.dam
		if e.combat.of_breaching then
			for d, v in pairs(e.wielder.inc_damage) do
				e.wielder.resists_pen[d] = math.ceil(e.combat.dam/2)
			end
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	keywords = {shimmering=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		max_mana = resolvers.mbonus_material(70, 30),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "surging ", prefix=true, instant_resolve=true,
	keywords = {surging=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	wielder = {
		spellsurge_on_crit = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	keywords = {blight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		vim_on_crit = resolvers.mbonus_material(5, 1),
		max_vim =  resolvers.mbonus_material(20, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "ethereal ", prefix=true, instant_resolve=true,
	keywords = {ethereal=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_def = resolvers.mbonus_material(10, 2),
		damage_shield_penetrate = resolvers.mbonus_material(40, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "greater ", prefix=true, instant_resolve=true,
	keywords = {greater=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 45,
	combat = {is_greater = true,},
	resolvers.generic(function(e)
		local dam_tables = {
			magestaff = { engine.DamageType.FIRE, engine.DamageType.COLD, engine.DamageType.LIGHTNING, engine.DamageType.ARCANE },
			starstaff = { engine.DamageType.LIGHT, engine.DamageType.DARKNESS, engine.DamageType.TEMPORAL, engine.DamageType.PHYSICAL },
			vilestaff = { engine.DamageType.DARKNESS, engine.DamageType.BLIGHT, engine.DamageType.ACID, engine.DamageType.FIRE },
		}
		local d_table = dam_tables[e.flavor_name]
		for i = 1, #d_table do
			e.wielder.inc_damage[d_table[i]] = e.combat.dam
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "void walker's ", prefix=true, instant_resolve=true,
	keywords = {['v. walkers']=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 30,
	wielder = {
		resist_all_on_teleport = resolvers.mbonus_material(10, 5),
		defense_on_teleport = resolvers.mbonus_material(20, 5),
		effect_reduction_on_teleport = resolvers.mbonus_material(25, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of fate", suffix=true, instant_resolve=true,
	keywords = {fate=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	wielder = {
		combat_physresist = resolvers.mbonus_material(8, 2),
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		combat_spellresist = resolvers.mbonus_material(8, 2),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of illumination", suffix=true, instant_resolve=true,
	keywords = {illumination=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		lite = resolvers.mbonus_material(4, 1),
	},
	resolvers.charmt(Talents.T_ILLUMINATE, {1,2}, 6),
}

newEntity{
	power_source = {arcane=true},
	name = " of might", suffix=true, instant_resolve=true,
	keywords = {might=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(15, 4),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of projection", suffix=true, instant_resolve=true,
	keywords = {projection=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 15,
	resolvers.charm("projects a bolt from the staff", 5,
		function(self, who)
			local tg = {type="bolt", range= 5 + self.material_level, speed=20, display = {particle=particle, trail=trail},}
			local weapon = who:hasStaffWeapon()
			local combat = weapon.combat

			local DamageType = require "engine.DamageType"
			local damtype = combat.damtype
			if     damtype == DamageType.FIRE then      explosion = "flame"               particle = "bolt_fire"      trail = "firetrail"
			elseif damtype == DamageType.COLD then      explosion = "freeze"              particle = "ice_shards"     trail = "icetrail"
			elseif damtype == DamageType.ACID then      explosion = "acid"                particle = "bolt_acid"      trail = "acidtrail"
			elseif damtype == DamageType.LIGHTNING then explosion = "lightning_explosion" particle = "bolt_lightning" trail = "lightningtrail"
			elseif damtype == DamageType.LIGHT then     explosion = "light"               particle = "bolt_light"     trail = "lighttrail"
			elseif damtype == DamageType.DARKNESS then  explosion = "dark"                particle = "bolt_dark"      trail = "darktrail"
			elseif damtype == DamageType.NATURE then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
			elseif damtype == DamageType.BLIGHT then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
			elseif damtype == DamageType.PHYSICAL then  explosion = "dark"                particle = "stone_shards"   trail = "earthtrail"
			elseif damtype == DamageType.TEMPORAL then  explosion = "light"				  particle = "temporal_bolt"  trail = "lighttrail"
			else                                        explosion = "manathrust"          particle = "bolt_arcane"    trail = "arcanetrail" damtype = DamageType.ARCANE
			end

			local x, y = who:getTarget(tg)
			if not x or not y then return nil end

			-- Compute damage
			local dam = who:combatDamage(combat)
			local damrange = who:combatDamageRange(combat)
			dam = rng.range(dam, dam * damrange)
			dam = who:spellCrit(dam)

			who:projectile(tg, x, y, damtype, dam, {type=explosion})

			game.logSeen(who, "%s fires a bolt from %s!", who.name:capitalize(), self.name)
			game:playSoundNear(who, "talents/arcane")
			return {id=true, used=true}
		end
	),
}

newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	keywords = {warding=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		learn_talent = {
			[Talents.T_WARD] = resolvers.mbonus_material(4, 1),
		},
		wards = {},
	},
	combat = {of_warding = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.wards[d] = 2
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of breaching", suffix=true, instant_resolve=true,
	keywords = {breaching=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		resists_pen = {},
	},
	combat = {of_breaching = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.resists_pen[d] = v/2
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	keywords = {blasting=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	resolvers.charm("projects damage in a circle from the staff", 10,
		function(self, who)
			local tg = {type="ball", range=0, radius=self.material_level + 1, selffire=false}
			local weapon = who:hasStaffWeapon()
			local combat = weapon.combat

			local DamageType = require "engine.DamageType"
			local damtype = combat.damtype
			if     damtype == DamageType.FIRE then      explosion = "flame"
			elseif damtype == DamageType.COLD then      explosion = "freeze"
			elseif damtype == DamageType.ACID then      explosion = "acid"
			elseif damtype == DamageType.LIGHTNING then explosion = "lightning_explosion"
			elseif damtype == DamageType.LIGHT then     explosion = "light"
			elseif damtype == DamageType.DARKNESS then  explosion = "dark"
			elseif damtype == DamageType.NATURE then    explosion = "slime"
			elseif damtype == DamageType.BLIGHT then    explosion = "slime"
			elseif damtype == DamageType.PHYSICAL then  explosion = "dark"
			elseif damtype == DamageType.TEMPORAL then  explosion = "light"
			else                                        explosion = "manathrust"         damtype = DamageType.ARCANE
			end

			-- Compute damage
			local dam = who:combatDamage(combat)
			local damrange = who:combatDamageRange(combat)
			dam = rng.range(dam, dam * damrange)
			dam = who:spellCrit(dam)

			who:project(tg, who.x, who.y, damtype, dam, {type=explosion})

			game.logSeen(who, "%s unleashes an elemental blastwave from %s!", who.name:capitalize(), self.name)
			game:playSoundNear(who, "talents/arcane")
			return {id=true, used=true}
		end
	),
}

newEntity{
	power_source = {arcane=true},
	name = " of channeling", suffix=true, instant_resolve=true,
	keywords = {channeling=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 2),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
	resolvers.charm("channel mana (increasing mana regen by 500%% for ten turns)", 30,
		function(self, who)
			if who.mana_regen > 0 and not who:hasEffect(who.EFF_MANASURGE) then
				who:setEffect(who.EFF_MANASURGE, 10, {power=who.mana_regen * 5})
			else
				if who.mana_regen < 0 then
					game.logPlayer(who, "Your negative mana regeneration rate is unaffected by the staff.")
				elseif who:hasEffect(who.EFF_MANASURGE) then
					game.logPlayer(who, "Another mana surge is currently active.")
				else
					game.logPlayer(who, "Your nonexistant mana regeneration rate is unaffected by the staff.")
				end
			end
			game.logSeen(who, "%s is channeling mana!", who.name:capitalize())
			return {id=true, used=true}
		end
	),
}

newEntity{
	power_source = {arcane=true},
	name = " of greater warding", suffix=true, instant_resolve=true,
	keywords = {['g. warding']=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		learn_talent = {
			[Talents.T_WARD] = resolvers.mbonus_material(4, 1),
		},
		wards = {},
	},
	combat = {of_greater_warding = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.wards[d] = 3
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of invocation", suffix=true, instant_resolve=true,
	keywords = {invocation=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	resolvers.charm("projects damage in a cone from the staff", 8,
		function(self, who)
			local tg = {type="cone", range=0, radius=self.material_level * 2, selffire=false}
			local weapon = who:hasStaffWeapon()
			local combat = weapon.combat

			local DamageType = require "engine.DamageType"
			local damtype = combat.damtype
			if     damtype == DamageType.FIRE then      explosion = "flame"
			elseif damtype == DamageType.COLD then      explosion = "freeze"
			elseif damtype == DamageType.ACID then      explosion = "acid"
			elseif damtype == DamageType.LIGHTNING then explosion = "lightning_explosion"
			elseif damtype == DamageType.LIGHT then     explosion = "light"
			elseif damtype == DamageType.DARKNESS then  explosion = "dark"
			elseif damtype == DamageType.NATURE then    explosion = "slime"
			elseif damtype == DamageType.BLIGHT then    explosion = "slime"
			elseif damtype == DamageType.PHYSICAL then  explosion = "dark"
			elseif damtype == DamageType.TEMPORAL then  explosion = "light"
			else                                        explosion = "manathrust"          damtype = DamageType.ARCANE
			end

			local x, y = who:getTarget(tg)
			if not x or not y then return nil end

			-- Compute damage
			local dam = who:combatDamage(combat)
			local damrange = who:combatDamageRange(combat)
			dam = rng.range(dam, dam * damrange)
			dam = who:spellCrit(dam)

			who:project(tg, x, y, damtype, dam, {type=explosion})

			game.logSeen(who, "%s conjures a cone of elemental energy from %s!", who.name:capitalize(), self.name)
			game:playSoundNear(who, "talents/arcane")
			return {id=true, used=true}
		end
	),
}

newEntity{
	power_source = {arcane=true},
	name = " of protection", suffix=true, instant_resolve=true,
	keywords = {protection=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		resists = {},
	},
	combat = {of_protection = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.resists[d] = v/2
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of wizardry", suffix=true, instant_resolve=true,
	keywords = {wizardry=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 2),
		max_mana = resolvers.mbonus_material(100, 10),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(5, 1), [Stats.STAT_WIL] = resolvers.mbonus_material(5, 1) },
	},
}

--[[
newEntity{
	power_source = {arcane=true},
	name = "magma ", prefix=true, instant_resolve=true,
	keywords = {magma=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	keywords = {temporal=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	keywords = {icy=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	keywords = {acidic=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crackling ", prefix=true, instant_resolve=true,
	keywords = {crackling=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "naturalist's ", prefix=true, instant_resolve=true,
	keywords = {naturalist=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "sunbathed ", prefix=true, instant_resolve=true,
	keywords = {sunbathed=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHT] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	keywords = {shadow=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.DARKNESS] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conveyance", suffix=true, instant_resolve=true,
	keywords = {conveyance=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		talents_types_mastery = {
			["spell/conveyance"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "teleport you anywhere on the level, randomly", power = 70, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end}
}

newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	keywords = {blasting=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
	},
	max_power = 15, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 2, power = 10 },
}

newEntity{
	power_source = {nature=true},
	name = "lifebinding ", prefix=true, instant_resolve=true,
	keywords = {lifebinding=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
			},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "infernal ", prefix=true, instant_resolve=true,
	keywords = {infernal=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		see_invisible = resolvers.mbonus_material(15, 5),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "chronomancer's ", prefix=true, instant_resolve=true,
	keywords = {chronomancer=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		movement_speed = 0.1,
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(20, 5),
		},
	},

}

newEntity{
	power_source = {nature=true},
	name = "abyssal ", prefix=true, instant_resolve=true,
	keywords = {abyssal=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(25, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(25, 5),
		},
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "magelord's ", prefix=true, instant_resolve=true,
	keywords = {magelord=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 60,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 20),
		combat_spellpower = resolvers.mbonus_material(20, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "polar ", prefix=true, instant_resolve=true,
	keywords = {polar=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
		},
		on_melee_hit = {
			[DamageType.ICE] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "bloodlich's ", prefix=true, instant_resolve=true,
	keywords = {bloodlich=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 90,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(9, 1),
		},
		inc_damage = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conflagration", suffix=true, instant_resolve=true,
	keywords = {conflagration=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, -v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of lightning", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_CHAIN_LIGHTNING, level = 3, power = 20 },
	wielder = {

	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the stars", suffix=true, instant_resolve=true,
	keywords = {stars=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_STARFALL, level = 2, power = 20 },
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of ruination", suffix=true, instant_resolve=true,
	keywords = {ruination=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_CORRUPTED_NEGATION, level = 2, power = 30 },
	wielder = {
	},
}


newEntity{
	power_source = {arcane=true},
	name = " of divination", suffix=true, instant_resolve=true,
	keywords = {divination=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		talents_types_mastery = {
			["spell/divination"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
}

]]