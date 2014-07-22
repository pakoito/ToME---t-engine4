-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- Stat boosting amulets
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
	name = " of dexterity (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {dexterity=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {nature=true},
	name = " of strength (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {strength=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {nature=true},
	name = " of constitution (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {constitution=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of magic (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {magic=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {technique=true},
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
-- Immunity/Resist amulets
newEntity{
	power_source = {nature=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulating=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(20, 10),
			[DamageType.COLD] = resolvers.mbonus_material(20, 10),
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
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 10),
		},
		stun_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
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
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(20, 10),
		},
		knockback_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}
newEntity{
	power_source = {nature=true},
	name = "warrior's ", prefix=true, instant_resolve=true,
	keywords = {warrior=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		stamina_regen = resolvers.mbonus_material(10, 2, function(e, v) v=v/10 return 0, v end),
	},
}
newEntity{
	power_source = {nature=true},
	name = "clarifying ", prefix=true, instant_resolve=true,
	keywords = {clarifying=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.MIND] = resolvers.mbonus_material(20, 10),
		},
		confusion_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}
newEntity{
	power_source = {nature=true},
	name = "starlit ", prefix=true, instant_resolve=true,
	keywords = {starlit=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(20, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 10),
		},
		blind_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}
newEntity{
	power_source = {antimagic=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	keywords = {cleansing=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(20, 10),
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 10),
		},
		disease_immune = resolvers.mbonus_material(30, 20, function(e, v) return 0, v/100 end),
		poison_immune = resolvers.mbonus_material(30, 20, function(e, v) return 0, v/100 end),
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
	resolvers.charm("teleport you randomly (rad %d)", 15, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower(who))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

--[[ Disabled pending revamp of concept which will probably never come
newEntity{
	power_source = {psionic=true},
	name = " of seduction", suffix=true, instant_resolve=true,
	keywords = {seduction=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 50,
	wielder = {
		inc_damage = {
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists_pen = {
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(5, 2) },
		stamina_regen_when_hit = resolvers.mbonus_material(20, 2, function(e, v) v=v/10 return 0, v end),
		mana_regen_when_hit = resolvers.mbonus_material(40, 4, function(e, v) v=v/10 return 0, v end),
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 2, function(e, v) v=v/10 return 0, v end),
		hate_regen_when_hit = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		psi_regen_when_hit = resolvers.mbonus_material(20, 2, function(e, v) v=v/10 return 0, v end),
	},
	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("forces nearby enemies to attack you (rad %d)", 15, function(self, who)
		local rad = self:getCharmPower(who)
		local tg = {type="ball", range=0, radius=rad, friendlyfire=false}
		who:project(tg, who.x, who.y, function(tx, ty)
			local a = game.level.map(tx, ty, engine.Map.ACTOR)
			if a then
				a:setTarget(who)
			end
		end)
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}
--]]

newEntity{
	power_source = {technique=true},
	name = "restful ", prefix=true, instant_resolve=true,
	keywords = {restful=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
		life_regen = resolvers.mbonus_material(36, 9, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "vitalizing ", prefix=true, instant_resolve=true,
	keywords = {vitalizing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats={
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2),
		},
		combat_physresist = resolvers.mbonus_material(15, 5),
		max_life = resolvers.mbonus_material(50, 30),
		life_regen = resolvers.mbonus_material(24, 6, function(e, v) v=v/10 return 0, v end),
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
		sight = 2,
		see_invisible = resolvers.mbonus_material(10, 5),
		blind_immune = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		infravision = resolvers.mbonus_material(8, 2),
		trap_detect_power = resolvers.mbonus_material(15, 5),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of healing", suffix=true, instant_resolve=true,
	keywords = {healing=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		cut_immune = resolvers.mbonus_material(4, 4, function(e, v) v=v/10 return 0, v end),
	},
	resolvers.charmt(Talents.T_HEAL_NATURE, {1,2,3}, 35),
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
		combat_armor = resolvers.mbonus_material(5, 3),
		combat_def = resolvers.mbonus_material(8, 4),
		combat_physresist = resolvers.mbonus_material(20, 7),
		resists_cap = { all = resolvers.mbonus_material(5, 2) },
	},
}

newEntity{
	power_source = {technique=true},
	name = "enraging ", prefix=true, instant_resolve=true,
	keywords = {enraging=true},
	level_range = {30, 50},
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
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
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
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 4),
		},
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
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_mindpower = resolvers.mbonus_material(10, 5),
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
		combat_mentalresist = resolvers.mbonus_material(15, 10),
		combat_physresist = resolvers.mbonus_material(15, 10),
		combat_spellresist = resolvers.mbonus_material(15, 10),
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
			[Stats.STAT_DEX] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_CON] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_CUN] = resolvers.mbonus_material(7, 3),
		},
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
		movement_speed = 0.1,
		life_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return 0, v end),
		stamina_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return 0, v end),
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
			[Stats.STAT_LCK] = resolvers.mbonus_material(15, 5),
		},
		resist_unseen = resolvers.mbonus_material(10, 10), -- Makes more sense on Precognition helm, but I didn't want to overlap with the original stat use
		combat_def = resolvers.mbonus_material(15, 5),
		combat_atk = resolvers.mbonus_material(15, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of soulsearing", suffix=true, instant_resolve=true,
	keywords = {soulsear=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 90,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 5),
		combat_critical_power = resolvers.mbonus_material(10, 10),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of manastreaming", suffix=true, instant_resolve=true,
	keywords = {manastream=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 70,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		spellsurge_on_crit = resolvers.mbonus_material(4, 2),
		max_mana = resolvers.mbonus_material(40, 20),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the eclipse", suffix=true, instant_resolve=true,
	keywords = {eclipse=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		on_melee_hit = {
			[DamageType.ITEM_LIGHT_BLIND] = resolvers.mbonus_material(10, 5),
			[DamageType.ITEM_DARKNESS_NUMBING] = resolvers.mbonus_material(10, 5),
		},
		melee_project={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},
}

-- Upgraded Mastery
newEntity{
	power_source = {technique=true},
	name = " of perfection (#MASTERY#)", suffix=true,
	keywords = {perfection=true},
	level_range = {30, 50},
	rarity = 25,
	greater_ego = 1,
	cost = 2,
	wielder = {},
	resolvers.generic(function(e)
		local tts = {}
		local p = game:getPlayer(true)
		for i, def in ipairs(engine.interface.ActorTalents.talents_types_def) do
			if p and def.allow_random and p:knowTalentType(def.type) or p:knowTalentType(def.type) == false then tts[#tts+1] = def.type end
		end
		--local tt = tts[rng.range(1, #tts)]
		local tt = rng.tableRemove(tts)
		local tt2 = rng.tableRemove(tts)

		e.wielder.talents_types_mastery = {}
		local v = (10 + rng.mbonus(math.ceil(30 * e.material_level / 5), resolvers.current_level, 50)) / 100
		if tt then e.wielder.talents_types_mastery[tt] = v end
		if tt2 then e.wielder.talents_types_mastery[tt2] = v end
		e.cost = e.cost + v * 60
	end),
}