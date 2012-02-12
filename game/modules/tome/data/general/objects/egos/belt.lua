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
local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {arcane=true},
	name = " of carrying", suffix=true, instant_resolve=true,
	keywords = {carrying=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material("max_encumber"),
		fatigue = resolvers.mbonus_material("fatigue"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of shielding", suffix=true, instant_resolve=true,
	keywords = {shielding=true},
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		combat_def = resolvers.mbonus_material("combat_def"),
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "create a temporary shield that absorbs damage", power = 100, use = function(self, who)
		local power = 100 + who:getMag(120, true)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=power})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end}
}

newEntity{
	power_source = {arcane=true},
	name = " of the mystic", suffix=true, instant_resolve=true,
	keywords = {mystic=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the titan", suffix=true, instant_resolve=true,
	keywords = {titan=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	keywords = {life=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 6,
	wielder = {
		life_regen = resolvers.mbonus_material("life_regen"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	keywords = {resilience=true},
	level_range = {10, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		max_life = resolvers.mbonus_material("max_life"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "blurring ", prefix=true, instant_resolve=true,
	keywords = {blurring=true},
	level_range = {10, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material("combat_def_ranged"),
		inc_stealth = resolvers.mbonus_material("inc_stealth"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulate=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	keywords = {grounding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchoring=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material("resists"),
		},
		teleport_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	keywords = {stabilizing=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
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
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		confusion_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of magery", suffix=true, instant_resolve=true,
	keywords = {magery=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of burglary", suffix=true, instant_resolve=true,
	keywords = {burglary=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		disarm_bonus = resolvers.mbonus_material("disarm_bonus"),
		trap_detect_power = resolvers.mbonus_material("trap_detect_power"),
		infravision = resolvers.mbonus_material("infravision"),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of dampening", suffix=true, instant_resolve=true,
	keywords = {dampening=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of inertia", suffix=true, instant_resolve=true,
	keywords = {inertia=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		pin_immune = resolvers.mbonus_material("immunity"),
	},
}


newEntity{
	power_source = {technique=true},
	name = "monstrous ", prefix=true, instant_resolve=true,
	keywords = {monstrous=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		size_category = 1,
		combat_dam = resolvers.mbonus_material("combat_dam", 2),
	--	combat_critical_power = resolvers.mbonus_material("combat_critical_power"),

	},
}

newEntity{
	power_source = {technique=true},
	name = "balancing ", prefix=true, instant_resolve=true,
	keywords = {balancing=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
	},
}


newEntity{
	power_source = {technique=true},
	name = "protective ", prefix=true, instant_resolve=true,
	keywords = {protective=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_def = resolvers.mbonus_material("combat_def"),
		combat_physresist = resolvers.mbonus_material("save", 2),
	},
}

newEntity{
	power_source = {technique=true},
	name = "ravager's ", prefix=true, instant_resolve=true,
	keywords = {ravager=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists_pen", 2),
		},
	},
}
--[=[
newEntity{
	power_source = {nature=true},
	name = "draining ", prefix=true, instant_resolve=true,
	level_range = {45, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	wielder = {
		resource_leech_chance = resolvers.mbonus_material("resource_leech_chance"),
		resource_leech_value = resolvers.mbonus_material("resource_leech_value"),
		on_melee_hit = {
			[DamageType.BLIGHT] = resolvers.mbonus_material("on_melee_hit"),
		},
	},
}
]=]
newEntity{
	power_source = {arcane=true},
	name = "nightruned ", prefix=true, instant_resolve=true,
	keywords = {nightruned=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material("resists"),
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		blind_immune = resolvers.mbonus_material("immunity"),
		see_invisible = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "skylord's ", prefix=true, instant_resolve=true,
	keywords = {skylord=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spiritwalker's ", prefix=true, instant_resolve=true,
	keywords = {spiritwalk=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
		},
		max_mana = resolvers.mbonus_material("max_mana"),
		mana_regen = resolvers.mbonus_material("mana_regen"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of containment", suffix=true, instant_resolve=true,
	keywords = {containment=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
		pin_immune = resolvers.mbonus_material("immunity", -1),
		blind_immune = resolvers.mbonus_material("immunity", -1),
		confusion_immune = resolvers.mbonus_material("immunity"),
		max_stamina = resolvers.mbonus_material("max_stamina"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of recklessness", suffix=true, instant_resolve=true,
	keywords = {reckless=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	wielder = {
		disarm_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		--combat_critical_power = resolvers.mbonus_material("combat_critical_power"),
		combat_dam = resolvers.mbonus_material("combat_dam"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of valiance", suffix=true, instant_resolve=true,
	keywords = {valiance=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		max_life = resolvers.mbonus_material("max_life"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of unlife", suffix=true, instant_resolve=true,
	keywords = {unlife=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 90,
	cost = 30,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
		},
		can_breath = {water=1},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the vagrant", suffix=true, instant_resolve=true,
	keywords = {vagrant=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats", 2),
		},
		combat_physresist = resolvers.mbonus_material("save", 2),
	},
}
