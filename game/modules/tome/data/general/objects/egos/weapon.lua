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

--load("/data/general/objects/egos/charged-attack.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- Idea: Giant(technique, chance to stun on hit and increased weight), Sharp, Jagged, Deft  (of deftness-quick swap),
-- Wolf, Bear, Snake based nature egos (maybe wolf could summon wolves),
-------------------------------------------------------
-- Techniques------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {technique=true},
	name = "balanced ", prefix=true, instant_resolve=true,
	keywords = {balanced=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 15,
	wielder={
		combat_atk = resolvers.mbonus_material(10, 5),
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of crippling", suffix=true, instant_resolve=true,
	keywords = {crippling=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(10, 5),
	},
	combat = {
		special_on_crit = {desc="cripple the target", fct=function(combat, who, target)
			local power = 5 + (who:combatPhysicalpower()/5)
			target:setEffect(target.EFF_CRIPPLE, 4, {src=who, atk=power, dam=power, apply_power=who:combatAttack(combat)})
		end},
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
		dam = resolvers.mbonus_material(10, 5),
	},
}

-- Greater 
newEntity{
	power_source = {technique=true},
	name = "quick ", prefix=true, instant_resolve=true,
	keywords = {quick=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 30,
	combat = { physspeed = -0.1 },
	wielder = {
		combat_atk = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 1),
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
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(6, 1),
		},
		disarm_immune = resolvers.mbonus_material(25, 10, function(e, v) v=v/100 return 0, v end),
		combat_dam = resolvers.mbonus_material(10, 5),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of evisceration", suffix=true, instant_resolve=true ,
	keywords = {evisc=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(10, 5),
		combat_dam = resolvers.mbonus_material(10, 5),
	},
	combat = { 
		special_on_crit = {desc="wounds the target", fct=function(combat, who, target)
			local dam = 5 + (who:combatPhysicalpower()/5)
			if target:canBe("cut") then
				target:setEffect(target.EFF_DEEP_WOUND, 7, {src=who, heal_factor=dam * 2, power=dam, apply_power=who:combatAttack()})
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
		combat_atk = resolvers.mbonus_material(10, 5),
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 1),
		},
		stamina_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of ruin", suffix=true, instant_resolve=true,
	keywords = {ruin=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(10, 5),
		combat_critical_power = resolvers.mbonus_material(10, 10),
		combat_apr = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of shearing", suffix=true, instant_resolve=true,
	keywords = {shearing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_apr = resolvers.mbonus_material(10, 5),
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

-------------------------------------------------------
-- Arcane Egos-----------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {arcane=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	keywords = {acidic=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	combat = {
		melee_project={
			[DamageType.ACID] = resolvers.mbonus_material(15, 5)
		},
		special_on_crit = {desc="splashes the target with acid", fct=function(combat, who, target)
			local power = 5 + (who:combatSpellpower()/10)
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=who, dam=power, atk=power, armor=power})
		end},
	},
}


newEntity{
	power_source = {arcane=true},
	name = "arcing ", prefix=true, instant_resolve=true,
	keywords = {arcing=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	combat = {
		melee_project={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
		},
		special_on_hit = {desc="25% chance for lightning to arc to a second target", fct=function(combat, who, target)
			if not rng.percent(25) then return end
			local tgts = {}
			local x, y = target.x, target.y
			local grids = core.fov.circle_grids(x, y, 5, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, engine.Map.ACTOR)
				if a and a ~= target and who:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
			end end

			-- Randomly take targets
			local tg = {type="beam", range=5, friendlyfire=false, x=target.x, y=target.y}
			if #tgts <= 0 then return end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			local dam = 30 + (who:combatSpellpower())
			
			who:project(tg, a.x, a.y, engine.DamageType.LIGHTNING, rng.avg(1, dam, 3))
			game.level.map:particleEmitter(x, y, math.max(math.abs(a.x-x), math.abs(a.y-y)), "lightning", {tx=a.x-x, ty=a.y-y})
			game:playSoundNear(who, "talents/lightning")
		end},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "flaming ", prefix=true, instant_resolve=true,
	keywords = {flaming=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 10,
	combat = {
		burst_on_hit={
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5)
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	keywords = {icy=true},
	level_range = {15, 50},
	rarity = 5,
	cost = 10,
	combat = {
		melee_project={
			[DamageType.ICE] = resolvers.mbonus_material(15, 5)
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of daylight", suffix=true, instant_resolve=true,
	keywords = {daylight=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	combat = {
		melee_project={[DamageType.LIGHT] = resolvers.mbonus_material(15, 5)},
		inc_damage_type = {undead=resolvers.mbonus_material(25, 5)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of phasing", suffix=true, instant_resolve=true,
	keywords = {phase=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 30,
	combat={
		apr = resolvers.mbonus_material(10, 5),
		phasing = resolvers.mbonus_material(50, 10)
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of vileness", suffix=true, instant_resolve=true,
	keywords = {vile=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 30,
	combat={
		melee_project = {
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5)
		},
		burst_on_crit = {
			[DamageType.CORRUPTED_BLOOD] = resolvers.mbonus_material(25, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of paradox", suffix=true, instant_resolve=true,
	keywords = {paradox=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 30,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
		},
		on_melee_hit = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
		},
	},
	combat = {
		melee_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5)
		},
	},
}

-- Greater Egos
newEntity{
	power_source = {arcane=true},
	name = "elemental ", prefix=true, instant_resolve=true,
	keywords = {elemental=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	combat = {
		convert_damage ={
			[DamageType.FIRE] = resolvers.mbonus_material(15, 10),
			[DamageType.COLD] = resolvers.mbonus_material(15, 10),
			[DamageType.ACID] = resolvers.mbonus_material(15, 10),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 10),
		},
		special_on_hit = {desc="random elemental effect", fct=function(combat, who, target)
			local dam = 20 + (who:combatSpellpower()/5)
			local tg = {type="hit", range=1}
			local elem = rng.table{
				{engine.DamageType.FIREBURN, "flame"},
				{engine.DamageType.ICE, "freeze"},
				{engine.DamageType.LIGHTNING_DAZE, "lightning_explosion"},
				{engine.DamageType.ACID_BLIND, "acid"},
			}
			who:project(tg, target.x, target.y, elem[1], rng.avg(dam / 2, dam, 3), {type=elem[2]})		
		end},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "plaguebringer's ", prefix=true, instant_resolve=true,
	keywords = {plague=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		disease_immune = resolvers.mbonus_material(25, 10, function(e, v) v=v/100 return 0, v end),
	},
	combat = {
		melee_project = {
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
		},
		talent_on_hit = { [Talents.T_EPIDEMIC] = {level=1, chance=10} },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of corruption", suffix=true, instant_resolve=true,
	keywords = {corruption=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	combat = {
		melee_project={
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
		special_on_hit = {desc="20% chance to curse the target", fct=function(combat, who, target)
			if not rng.percent(20) then return end
			local eff = rng.table{"vuln", "defenseless", "impotence", "death", }
			if not who:checkHit(who:combatSpellpower(), target:combatSpellResist()) then return end
			if eff == "vuln" then target:setEffect(target.EFF_CURSE_VULNERABILITY, 2, {power=20})
			elseif eff == "defenseless" then target:setEffect(target.EFF_CURSE_DEFENSELESSNESS, 2, {power=20})
			elseif eff == "impotence" then target:setEffect(target.EFF_CURSE_IMPOTENCE, 2, {power=20})
			elseif eff == "death" then target:setEffect(target.EFF_CURSE_DEATH, 2, {src=who, dam=20})
			end
		end},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the mystic", suffix=true, instant_resolve=true,
	keywords = {mystic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(6, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 1),
		},
	},
}

-------------------------------------------------------
-- Nature/Antimagic Egos:------------------------------
-------------------------------------------------------
newEntity{
	power_source = {nature=true},
	name = "huntsman's ", prefix=true, instant_resolve=true,
	keywords = {hunt=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	combat = {
		melee_project={[DamageType.NATURE] = resolvers.mbonus_material(15, 5)},
		inc_damage_type = {animal=resolvers.mbonus_material(25, 5)},
	},
}

newEntity{
	power_source = {nature=true},
	name = "insidious ", prefix=true, instant_resolve=true,
	keywords = {insid=true},
	level_range = {10, 50},
	rarity = 5,
	cost = 15,
	combat = {
		melee_project={
			[DamageType.INSIDIOUS_POISON] = resolvers.mbonus_material(50, 10), -- this gets divided by 7 for damage
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of erosion", suffix=true, instant_resolve=true,
	keywords = {erosion=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 15,
	combat = {
		melee_project={
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "blazebringer's ", prefix=true, instant_resolve=true,
	keywords = {blaze=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		global_speed_add = resolvers.mbonus_material(5, 1, function(e, v) v=v/100 return 0, v end),
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		convert_damage = { 
			[DamageType.FIRE] = resolvers.mbonus_material(25, 25),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "caustic ", prefix=true, instant_resolve=true,
	keywords = {caustic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		life_regen = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		resists_pen = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		convert_damage = { 
			[DamageType.ACID_BLIND] = resolvers.mbonus_material(25, 25),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "glacial ", prefix=true, instant_resolve=true,
	keywords = {glacial=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 5),
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		convert_damage = { 
			[DamageType.ICE] = resolvers.mbonus_material(25, 25),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "thunderous ", prefix=true, instant_resolve=true,
	keywords = {thunder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
		resists_pen = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		convert_damage = { 
			[DamageType.LIGHTNING_DAZE] = resolvers.mbonus_material(25, 25),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of gravity", suffix=true, instant_resolve=true,
	keywords = {gravity=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		melee_project={
			[DamageType.GRAVITY] = resolvers.mbonus_material(15, 5),
		},
		special_on_hit = {desc="25% chance to crush the target", fct=function(combat, who, target)
			if not rng.percent(25) then return end
			if target:attr("never_move") then
				local tg = {type="hit", range=1}
				who:project(tg, target.x, target.y, engine.DamageType.IMPLOSION, 10 + who:combatMindpower()/4)
			elseif target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 3, {src=who, apply_power=who:combatAttack(combat)})
			else
				game.logSeen(target, "%s resists the pin!", target.name:capitalize())
			end
		end},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of nature", suffix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		resists = { all = resolvers.mbonus_material(8, 2) },
		resists_pen = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		convert_damage = { 
			[DamageType.NATURE] = resolvers.mbonus_material(25, 25),
		},
	},
}

-- Antimagic
newEntity{
	power_source = {antimagic=true},
	name = "manaburning ", prefix=true, instant_resolve=true,
	keywords = {manaburning=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 40,
	combat = {
		melee_project = {
			[DamageType.MANABURN] = resolvers.mbonus_material(25, 10),
		},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "slime-covered ", prefix=true, instant_resolve=true,
	keywords = {slime=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 15,
	combat = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(15, 5)},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of banishment", suffix=true, instant_resolve=true,
	keywords = {banishment=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 20,
	combat = {
		inc_damage_type = {demon=resolvers.mbonus_material(25, 5)},
	},
	wielder = { 
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(6, 1), },
	}
}

newEntity{
	power_source = {antimagic=true},
	name = " of purging", suffix=true, instant_resolve=true,
	keywords = {purging=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 20,
	combat = {
		melee_project={[DamageType.NATURE] = resolvers.mbonus_material(15, 5)},
		special_on_hit = {desc="25% chance to remove a magical effect", fct=function(combat, who, target)
			if not rng.percent(25) then return end
			
			local effs = {}
			
			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					local talent = target:getTalentFromId(tid)
					if talent.is_spell then effs[#effs+1] = {"talent", tid} end
				end
			end
			
			local eff = rng.tableRemove(effs)
			if eff then
				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
			end
		end},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "inquisitor's ", prefix=true, instant_resolve=true,
	keywords = {inquisitors=true},
	level_range = {30, 50},
	rarity = 45,
	greater_ego = 1,
	cost = 40,
	combat = {
		melee_project = {
			[DamageType.MANABURN] = resolvers.mbonus_material(25, 10),
		},
		special_on_crit = {desc="burns latent spell energy", fct=function(combat, who, target)
			local turns = 1 + math.ceil(who:combatMindpower() / 20)
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then game.logSeen(target, "%s resists!", target.name:capitalize()) return nil end
			
			local tids = {}
			for tid, lev in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t and not target.talents_cd[tid] and t.mode == "activated" and t.is_spell and not t.innate then tids[#tids+1] = t end
			end
			
			local t = rng.tableRemove(tids)
			if not t then return nil end
			local damage = t.mana or t.vim or t.positive or t.negative or t.paradox or 0
			target.talents_cd[t.id] = turns
			
			local tg = {type="hit", range=1}
			who:project(tg, target.x, target.y, engine.DamageType.ARCANE, damage)
			
			game.logSeen(target, "%s's %s has been burned!", target.name:capitalize(), t.name)
		end},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of disruption", suffix=true, instant_resolve=true,
	keywords = {disruption=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 40,
	combat = {
		inc_damage_type = {
			undead=resolvers.mbonus_material(25, 5), 
			construct=resolvers.mbonus_material(25, 5),
		},
		special_on_hit = {desc="disrupts spell-casting", fct=function(combat, who, target)
			target:setEffect(target.EFF_SPELL_DISRUPTION, 10, {src=who, power = 10, max = 50, apply_power=who:combatMindpower()})
		end},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of the leech", suffix=true, instant_resolve=true,
	keywords = {leech=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.SLIME] = resolvers.mbonus_material(15, 5),
		},
	},
	combat = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(15, 5)},
		special_on_hit = {desc="leeches stamina from the target", fct=function(combat, who, target)
			if target and target:getStamina() > 0 then
				local leech = who:combatMindpower() / 50
				local leeched = math.min(leech, target:getStamina())
				who:incStamina(leeched)
				target:incStamina(-leeched)
			end				
		end},
	},
}

-------------------------------------------------------
-- Psionic Egos: --------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {psionic=true},
	name = "hateful ", prefix=true, instant_resolve=true,
	keywords = {hateful=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	combat = {
		melee_project={[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5)},
		inc_damage_type = {humanoid=resolvers.mbonus_material(25, 5)},
	},
}

newEntity{
	power_source = {psionic=true},
	name = "thought-forged ", prefix=true, instant_resolve=true,
	keywords = {thought=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	combat = {
		melee_project={
			[DamageType.MIND] = resolvers.mbonus_material(15, 5),
		},
		convert_damage = { 
			[DamageType.MIND] = resolvers.mbonus_material(25, 25),
		},
	},
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 1),
		},
	}
}

newEntity{
	power_source = {psionic=true},
	name = " of amnesia", suffix=true, instant_resolve=true,
	keywords = {forgotten=true},
	level_range = {10, 50},
	rarity = 25, -- very rare because no one can remember how to make them...  haha
	cost = 15,
	wielder = {
		on_melee_hit = {
			[DamageType.MIND] = resolvers.mbonus_material(15, 5),
		},
	},
	combat = {
		special_on_hit = {desc="25% chance to put talents on cooldown", fct=function(combat, who, target)
			if not rng.percent(25) then return nil end
			local turns = 1 + math.ceil(who:combatMindpower() / 20)
			local number = 2 + math.ceil(who:combatMindpower() / 50)
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then game.logSeen(target, "%s resists!", target.name:capitalize()) return nil end
			
			local tids = {}
			for tid, lev in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
			end
			
			for i = 1, number do
				local t = rng.tableRemove(tids)
				if not t then break end
				target.talents_cd[t.id] = turns
				game.logSeen(target, "%s has temporarily forgotten %s!", target.name:capitalize(), t.name)
			end
		end},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of projection", suffix=true, instant_resolve=true,
	keywords = {projection=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 15,
	resolvers.charm("project an attack as mind damage doing 100%% weapon damage", 6,
		function(self, who)
			local tg = {type="bolt", range=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if target then
				who:attackTarget(target, engine.DamageType.MIND, 1, true)
			else
				return
			end
			return {id=true, used=true}
		end
	),
	combat = {	
		melee_project={
			[DamageType.MIND] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = "psychic's ", prefix=true, instant_resolve=true,
	keywords = {psychic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(6, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 1),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of torment", suffix=true, instant_resolve=true,
	keywords = {torment=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		resists_pen = {
			[DamageType.MIND] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		special_on_hit = {desc="20% chance to torment the target", fct=function(combat, who, target)
			if not rng.percent(20) then return end
			local eff = rng.table{"stun", "blind", "pin", "confusion", "silence",}
			if not target:canBe(eff) then return end
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "blind" then target:setEffect(target.EFF_BLINDED, 3, {})
			elseif eff == "pin" then target:setEffect(target.EFF_PINNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			end
		end},
	},
}
