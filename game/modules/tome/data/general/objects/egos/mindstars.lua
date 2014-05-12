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

-- TODO:  More greater suffix psionic; more lesser suffix and prefix psionic

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

-------------------------------------------------------
--Nature and Antimagic---------------------------------
-------------------------------------------------------
newEntity{
	power_source = {nature=true},
	name = "blooming ", prefix=true, instant_resolve=true,
	keywords = {blooming=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		heal_on_nature_summon = resolvers.mbonus_material(25, 5),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "gifted ", prefix=true, instant_resolve=true,
	keywords = {gifted=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {nature=true},
	name = "nature's ", prefix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of balance", suffix=true, instant_resolve=true,
	keywords = {balance=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_physresist = resolvers.mbonus_material(8, 2),
		combat_spellresist = resolvers.mbonus_material(8, 2),
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	keywords = {life=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		max_life = resolvers.mbonus_material(40, 10),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of slime", suffix=true, instant_resolve=true,
	keywords = {slime=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.ITEM_NATURE_SLOW] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		}
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "manaburning ", prefix=true, instant_resolve=true,
	keywords = {manaburning=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 40,
	combat = {
		melee_project = {
			[DamageType.ITEM_ANTIMAGIC_MANABURN] = resolvers.mbonus_material(15, 10),
		},
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
			[DamageType.ITEM_ANTIMAGIC_MANABURN] = resolvers.mbonus_material(15, 10),
		},
		special_on_crit = {desc="burns latent spell energy", fct=function(combat, who, target)
			local turns = 1 + math.ceil(who:combatMindpower() / 20)
			local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
			if not who:checkHit(check, target:combatMentalResist()) then game.logSeen(target, "%s resists!", target.name:capitalize()) return nil end

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
			damage = util.getval(damage, target, t)
			if type(damage) ~= "number" then damage = 0 end
			who:project(tg, target.x, target.y, engine.DamageType.ARCANE, damage)

			game.logSeen(target, "%s's %s has been #ORCHID#burned#LAST#!", target.name:capitalize(), t.name)
		end},
	},
}


newEntity{
	power_source = {antimagic=true},
	name = " of persecution", suffix=true, instant_resolve=true,
	keywords = {disruption=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 40,
	combat = {
		inc_damage_type = {
			unnatural=resolvers.mbonus_material(25, 5),
		},
		special_on_hit = {desc="disrupts spell-casting", fct=function(combat, who, target)
			local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
			target:setEffect(target.EFF_SPELL_DISRUPTION, 10, {src=who, power = 10, max = 50, apply_power=check})
		end},
	},
}

-------------------------------------------------------
--Psionic----------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {psionic=true},
	name = "horrifying ", prefix=true, instant_resolve=true,
	keywords = {horrifying=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "hungering ", prefix=true, instant_resolve=true,
	keywords = {hungering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		talents_types_mastery = {
			["psionic/voracity"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["cursed/dark-sustenance"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		hate_per_kill = resolvers.mbonus_material(4, 1),
		psi_per_kill = resolvers.mbonus_material(4, 1),
	},

	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("inflict mind damage; gain psi and hate", 20,
									function(self, who)
										local tg = {type="hit", range=10,}
										local x, y, target = who:getTarget(tg)
										if not x or not y then return nil end
										if target then
											if target:checkHit(who:combatMindpower(), target:combatMentalResist(), 0, 95, 5) then
												local damage = self:getCharmPower(who) + (who:combatMindpower() * (1 + self.material_level/5))
												who:project(tg, x, y, engine.DamageType.MIND, {dam=damage, alwaysHit=true}, {type="mind"})
												who:incPsi(damage/10)
												who:incHate(damage/10)
											else
												game.logSeen(target, "%s resists the mind attack!", target.name:capitalize())
											end
										end
										return {id=true, used=true}
									end
	),
}

newEntity{
	power_source = {psionic=true},
	name = " of nightfall", suffix=true, instant_resolve=true,
	keywords = {nightfall=true},
	level_range = {30, 50},
	rarity = 30,
	cost = 40,
	wielder = {
		inc_damage={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		talents_types_mastery = {
			["cursed/darkness"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
}

------------------------------------------------
-- Mindstar Sets -------------------------------
------------------------------------------------
local other_hand = function(object, who, inven_id)
	if inven_id == "MAINHAND" then return "OFFHAND" end
	if inven_id == "OFFHAND" then return "MAINHAND" end
end

local set_complete

local set_broken = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
	end
end

-- Wild Cards: Capable of completing other sets
newEntity{
	power_source = {nature=true},
	name = "harmonious ", prefix=true, instant_resolve=true,
	keywords = {harmonious=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_harmonious = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_nature", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.harmonious(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,},
}

newEntity{
	power_source = {psionic=true},
	name = "resonating ", prefix=true, instant_resolve=true,
	keywords = {resonating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		damage_resonance = resolvers.mbonus_material(20, 5),
		psi_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_resonating = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		resonating = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,},
}

set_complete = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREEN#Your mindstars resonate with Nature's purity.")
	end
	self:specialSetAdd({"wielder","nature_summon_regen"}, self.material_level)
end

-- Caller's Set: For summoners!
newEntity{
	power_source = {nature=true},
	name = "caller's ", prefix=true, instant_resolve=true,
	keywords = {callers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_callers_callers = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		callers = {{"ms_set_callers_summoners", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		callers = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		callers = set_broken,},
}

set_complete = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREEN#Your mindstars resonate with Nature's purity.")
	end
	self:specialSetAdd({"wielder","nature_summon_max"}, 1)
end

newEntity{
	power_source = {nature=true},
	name = "summoner's ", prefix=true, instant_resolve=true,
	keywords = {summoners=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
	},
	ms_set_callers_summoners = true, ms_set_nature = true,
	set_list = {
			multiple = true,
			harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
			callers = {{"ms_set_callers_callers", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		callers = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		callers = set_broken,},
}

-- Drake sets; these may seem odd but they're designed to keep sets from over writing each other when resolved
-- Basically it allows a set on suffix without a set_list, keeps the drop tables balanced without being bloated, and allows one master item to complete multiple subsets
set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	self:specialSetAdd({"wielder","blind_immune"}, self.material_level / 10)
	self:specialSetAdd({"wielder","stun_immune"}, self.material_level / 10)
end

newEntity{
	power_source = {nature=true}, define_as = "MS_EGO_SET_WYRM",
	name = "wyrm's ", prefix=true, instant_resolve=true,
	keywords = {wyrms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_wyrm = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_drake", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	self:specialSetAdd({"wielder","global_speed_add"}, self.material_level / 100)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of flames", suffix=true, instant_resolve=true,
	keywords = {flames=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		global_speed_add = resolvers.mbonus_material(5, 1, function(e, v) v=v/100 return 0, v end),
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	self:specialSetAdd({"wielder","combat_armor"}, self.material_level * 3)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of frost", suffix=true, instant_resolve=true,
	keywords = {frost=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(5, 5),
		on_melee_hit={
			[DamageType.ICE] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	self:specialSetAdd({"wielder","combat_physresist"}, self.material_level * 2)
	self:specialSetAdd({"wielder","combat_spellresist"}, self.material_level * 2)
	self:specialSetAdd({"wielder","combat_mentalresist"}, self.material_level * 2)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of sand", suffix=true, instant_resolve=true,
	keywords = {sand=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	local Stats = require "engine.interface.ActorStats"
	self:specialSetAdd({"wielder","inc_stats"}, {
											 [Stats.STAT_STR] = self.material_level,
											 [Stats.STAT_DEX] = self.material_level,
											 [Stats.STAT_CON] = self.material_level,
											 [Stats.STAT_MAG] = self.material_level,
											 [Stats.STAT_WIL] = self.material_level,
											 [Stats.STAT_CUN] = self.material_level,})
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of storms", suffix=true, instant_resolve=true,
	keywords = {storms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

-- Mentalist Set: For a yet to be written psi class and/or Mindslayers

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#Your mindstars resonate with psionic energy.")
	end
	self:specialSetAdd({"wielder","psi_regen"}, self.material_level / 10)
end

newEntity{
	power_source = {psionic=true},  define_as = "MS_EGO_SET_DREAMERS",
	name = "dreamer's ", prefix=true, instant_resolve=true,
	keywords = {dreamers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
		resists = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), }
	},
	ms_set_dreamers_dreamers = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		dreamers = {{"ms_set_dreamers_epiphanous", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		dreamers = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		dreamers = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#Your mindstars resonate with psionic energy.")
	end
	self:specialSetAdd({"wielder","psi_on_crit"}, self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_EPIPHANOUS",
	name = "epiphanous ", prefix=true, instant_resolve=true,
	keywords = {epiphanous=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), },
	},
	ms_set_dreamers_epiphanous = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		dreamers = {{"ms_set_dreamers_dreamers", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		dreamers = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		dreamers = set_broken,},
}

-- Mitotic Set: Single Mindstar that splits in two
newEntity{
	power_source = {nature=true},
	name = "mitotic ", prefix=true, instant_resolve=true,
	keywords = {mitotic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45, -- Rarity is high because melee based mindstar use is rare and you get two items out of one drop
	cost = 10,  -- cost is very low to discourage players from splitting them to make extra gold..  because that would be tedious and unfun
	combat = {
		physcrit = resolvers.mbonus_material(10, 2),
		melee_project = { [DamageType.ITEM_ACID_CORRODE]= resolvers.mbonus_material(15, 5), [DamageType.ITEM_NATURE_SLOW]= resolvers.mbonus_material(15, 5),},
	},
	resolvers.charm("divide the mindstar in two", 1,
									function(self, who)
										-- Check for free slot first
										if who:getFreeHands() == 0 then
											game.logPlayer(who, "You must have a free hand to divide %s", self.name)
											return
										end

										if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
											game.logPlayer(who, "You cannot split %s while using it as a psionic focus.", self.name)
											return
										end

										local o = self

										-- Remove some properties before cloning
										o.cost = self.cost / 2 -- more don't split for extra gold discouragement
										o.max_power = nil
										o.power_regen = nil
										o.use_power = nil
										local o2 = o:clone()

										-- Build the item set
										o.define_as = "MS_EGO_SET_MITOTIC_ACID"
										o2.define_as = "MS_EGO_SET_MITOTIC_SLIME"
										o.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_SLIME"} }
										o2.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_ACID"} }

										o.on_set_complete = function(self, who)
											self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.ACID_BLIND] = 10 * self.material_level } )
											game.logPlayer(who, "#GREEN#The mindstars pulse with life.")
										end
										o.on_set_broken = function(self, who)
											game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
										end

										o2.on_set_complete = function(self, who)
											self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.SLIME] = 10 * self.material_level } )
										end

										-- Wearing the second mindstar will complete the set and thus update the first mindstar
										who:wearObject(o2, true, true)

										-- Because we're removing the use_power we're not returning that it was used; instead we'll have the actor use energy manually
										who:useEnergy()
									end
	),
}

-- Wrathful Set: Geared towards Afflicted

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREY#You feel a swell of hatred from your mindstars.")
	end
	self:specialSetAdd({"wielder","combat_mindpower"}, 2 * self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_HATEFUL",
	name = "hateful ", prefix=true, instant_resolve=true,
	keywords = {hateful=true},
	level_range = {30, 50},
	greater_ego =1,
	rarity = 35,
	cost = 35,
	wielder = {
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(20, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 5),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_damage_type = {humanoid=resolvers.mbonus_material(20, 5)},
	},
	ms_set_wrathful_hateful = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		wrathful = {{"ms_set_wrathful_wrathful", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		wrathful = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		wrathful = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREY#You feel a swell of hatred from your mindstars.")
	end
	self:specialSetAdd({"wielder","max_hate"}, 2 * self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_WRATHFUL",
	name = "wrathful ", prefix=true, instant_resolve=true,
	keywords = {wrath=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		psi_on_crit = resolvers.mbonus_material(5, 1),
		hate_on_crit = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(10, 2),
	},
	ms_set_wrathful_wrathful = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		wrathful = {{"ms_set_wrathful_hateful", true, inven_id = other_hand,},},},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		wrathful = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		wrathful = set_broken,},
}
