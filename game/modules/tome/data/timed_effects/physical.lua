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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "CUT",
	desc = "Bleeding",
	long_desc = function(self, eff) return ("Huge cut that bleeds, doing %0.2f physical damage per turn."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# starts to bleed.", "+Bleeds" end,
	on_lose = function(self, err) return "#Target# stops bleeding.", "-Bleeds" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "DEEP_WOUND",
	desc = "Deep Wound",
	long_desc = function(self, eff) return ("Huge cut that bleeds, doing %0.2f physical damage per turn and decreasing all heals received by %d%%."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target# starts to bleed.", "+Deep Wounds" end,
	on_lose = function(self, err) return "#Target# stops bleeding.", "-Deep Wounds" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "REGENERATION",
	desc = "Regeneration",
	long_desc = function(self, eff) return ("A flow of life spins around the target, regenerating %0.2f life per turn."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts regenerating health quickly.", "+Regen" end,
	on_lose = function(self, err) return "#Target# stops regenerating health quickly.", "-Regen" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "BURNING",
	desc = "Burning",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is on fire!", "+Burn" end,
	on_lose = function(self, err) return "#Target# stops burning.", "-Burn" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
}

newEffect{
	name = "POISONED",
	desc = "Poisoned",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn."):format(eff.power) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is poisoned!", "+Poison" end,
	on_lose = function(self, err) return "#Target# stops being poisoned.", "-Poison" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the poison
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		if new_eff.max_power then old_eff.power = math.min(old_eff.power, new_eff.max_power) end
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
}

newEffect{
	name = "SPYDRIC_POISON",
	desc = "Spydric Poison",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn and unable to move (but can otherwise act freely)."):format(eff.power) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target# is poisoned and cannot move!", "+Spydric Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Spydric Poison" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "INSIDIOUS_POISON",
	desc = "Insidious Poison",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn and decreasing all heals received by %d%%."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Insidious Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Insidious Poison" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "CRIPPLING_POISON",
	desc = "Crippling Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, doing %0.2f nature damage per turn. Each time it tries to use a talent there is %d%% chance of failure."):format(eff.power, eff.fail) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = {power=10, fail=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Crippling Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Crippling Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.fail)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}

newEffect{
	name = "NUMBING_POISON",
	desc = "Numbing Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, doing %0.2f nature damage per turn. All damage it does is reduced by %d%%."):format(eff.power, eff.reduce) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Numbing Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Numbing Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.reduce)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
}

newEffect{
	name = "STONE_POISON",
	desc = "Stoning Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, doing %0.2f nature damage per turn. When the effect ends the target will turn to stone for %d turns."):format(eff.power, eff.stone) end,
	type = "physical",
	subtype = "poison",
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Stoning Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Stoning Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		self:setEffect(self.EFF_STONED, eff.stone, {})
	end,
}

newEffect{
	name = "BURNING_SHOCK",
	desc = "Burning Shock",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn and unable to act."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is paralyzed by the burning flame!", "+Burning Shock" end,
	on_lose = function(self, err) return "#Target# is not paralyzed anymore.", "-Burning Shock" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "STUNNED",
	desc = "Stunned",
	long_desc = function(self, eff) return ("The target is stunned, reducing damage by 70%%, healing received by 50%%, putting random talents on cooldown and reducing movement speed by 50%%. While stunned talents do not cooldown."):format() end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Stunned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "DISARMED",
	desc = "Disarmed",
	long_desc = function(self, eff) return "The target is maimed, unable to correctly wield a weapon." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is disarmed!", "+Disarmed" end,
	on_lose = function(self, err) return "#Target# rearms.", "-Disarmed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("disarmed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("disarmed", eff.tmpid)
	end,
}

newEffect{
	name = "CONSTRICTED",
	desc = "Constricted",
	long_desc = function(self, eff) return ("The target is constricted, preventing movement and making it suffocate (loses %0.2f air per turn)."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is constricted!", "+Constricted" end,
	on_lose = function(self, err) return "#Target# is free to breathe.", "-Constricted" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			return true
		end
		self:suffocate(eff.power, eff.src, (" was constricted to death by %s."):format(eff.src.unique and eff.src.name or eff.src.name:a_an()))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "DAZED",
	desc = "Dazed",
	long_desc = function(self, eff) return "The target is dazed, rendering it unable to act. Any damage will remove the daze." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is dazed!", "+Dazed" end,
	on_lose = function(self, err) return "#Target# is not dazed anymore.", "-Dazed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("dazed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("dazed", eff.tmpid)
	end,
}

newEffect{
	name = "EVASION",
	desc = "Evasion",
	long_desc = function(self, eff) return ("The target has %d%% chance to evade melee attacks."):format(eff.chance) end,
	type = "physical",
	status = "beneficial",
	parameters = { chance=10 },
	on_gain = function(self, err) return "#Target# tries to evade attacks.", "+Evasion" end,
	on_lose = function(self, err) return "#Target# is no longer evading attacks.", "-Evasion" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("evasion", eff.chance)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("evasion", eff.tmpid)
	end,
}

newEffect{
	name = "SPEED",
	desc = "Speed",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Fast" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Fast" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "SLOW",
	desc = "Slow",
	long_desc = function(self, eff) return ("Reduces global action speed by %d%%."):format( eff.power * 100) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# slows down.", "+Slow" end,
	on_lose = function(self, err) return "#Target# speeds up.", "-Slow" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDED",
	desc = "Blinded",
	long_desc = function(self, eff) return "The target is blinded, unable to see anything." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# loses sight!", "+Blind" end,
	on_lose = function(self, err) return "#Target# recovers sight.", "-Blind" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
}

newEffect{
	name = "DWARVEN_RESILIENCE",
	desc = "Dwarven Resilience",
	long_desc = function(self, eff) return ("The target's skin turns to stone, granting %d armour, %d physical save and %d spell save."):format(eff.armor, eff.physical, eff.spell) end,
	type = "physical",
	status = "beneficial",
	parameters = { armor=10, spell=10, physical=10 },
	on_gain = function(self, err) return "#Target#'s skin turns to stone." end,
	on_lose = function(self, err) return "#Target#'s skin returns to normal." end,
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.armor)
		eff.pid = self:addTemporaryValue("combat_physresist", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellresist", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
		self:removeTemporaryValue("combat_physresist", eff.pid)
		self:removeTemporaryValue("combat_spellresist", eff.sid)
	end,
}

newEffect{
	name = "STONE_SKIN",
	desc = "Stoneskin",
	long_desc = function(self, eff) return ("The target's skin reacts to damage, granting %d armour."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
	end,
}

newEffect{
	name = "HALFLING_LUCK",
	desc = "Halflings's Luck",
	long_desc = function(self, eff) return ("The target's luck and cunning combine to grant it %d%% higher combat critical chance and %d%% higher spell critical chance."):format(eff.physical, eff.spell) end,
	type = "physical",
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target#'s awareness returns to normal." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("combat_physcrit", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellcrit", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physcrit", eff.pid)
		self:removeTemporaryValue("combat_spellcrit", eff.sid)
	end,
}

newEffect{
	name = "ETERNAL_WRATH",
	desc = "Wrath of the Eternals",
	long_desc = function(self, eff) return ("The target calls upon its inner resources, improving all damage by %d%% and reducing all damage taken by %d%%."):format(eff.power, eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# radiates power." end,
	on_lose = function(self, err) return "#Target#'s aura of power vanishes." end,
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.pid2 = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
		self:removeTemporaryValue("resists", eff.pid2)
	end,
}

newEffect{
	name = "ORC_FURY",
	desc = "Orcish Fury",
	long_desc = function(self, eff) return ("The target enters a destructive fury, increasing all damage done by %d%%."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# enters a state of bloodlust." end,
	on_lose = function(self, err) return "#Target# calms down." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}

newEffect{
	name = "SHELL_SHIELD",
	desc = "Shell Shield",
	long_desc = function(self, eff) return ("The target takes cover in its shell, reducing all damage taken by %d%%."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target# takes cover under its shell.", "+Shell Shield" end,
	on_lose = function(self, err) return "#Target# leaves the cover of its shell.", "-Shell Shield" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "PAIN_SUPPRESSION",
	desc = "Pain Suppression",
	long_desc = function(self, eff) return ("The target ignores pain, reducing all damage taken by %d%%."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# lessens the pain.", "+Pain Suppression" end,
	on_lose = function(self, err) return "#Target# feels pain again.", "-Pain Suppression" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "SENSE",
	desc = "Sensing",
	long_desc = function(self, eff) return "Improves senses, allowing the detection of unseen things." end,
	type = "physical",
	status = "beneficial",
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		eff.rid = self:addTemporaryValue("detect_range", eff.range)
		eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
		eff.oid = self:addTemporaryValue("detect_object", eff.object)
		eff.tid = self:addTemporaryValue("detect_trap", eff.trap)
		self.detect_function = eff.on_detect
		game.level.map.changed = true
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("detect_range", eff.rid)
		self:removeTemporaryValue("detect_actor", eff.aid)
		self:removeTemporaryValue("detect_object", eff.oid)
		self:removeTemporaryValue("detect_trap", eff.tid)
		self.detect_function = nil
	end,
}

newEffect{
	name = "HEROISM",
	desc = "Heroism",
	long_desc = function(self, eff) return ("Increases your three highest stats by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		local l = { {Stats.STAT_STR, self:getStat("str")}, {Stats.STAT_DEX, self:getStat("dex")}, {Stats.STAT_CON, self:getStat("con")}, {Stats.STAT_MAG, self:getStat("mag")}, {Stats.STAT_WIL, self:getStat("wil")}, {Stats.STAT_CUN, self:getStat("cun")}, }
		table.sort(l, function(a,b) return a[2] > b[2] end)
		local inc = {}
		for i = 1, 3 do inc[l[i][1]] = eff.power end
		eff.stat = self:addTemporaryValue("inc_stats", inc)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
	end,
}

newEffect{
	name = "SUNDER_ARMOUR",
	desc = "Sunder Armour",
	long_desc = function(self, eff) return ("The target's armour is broken, reducing it by %d."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_armor", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.tmpid)
	end,
}

newEffect{
	name = "SUNDER_ARMS",
	desc = "Sunder Arms",
	long_desc = function(self, eff) return ("The target's combat ability is reduced, reducing its attack by %d."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}

newEffect{
	name = "PINNED",
	desc = "Pinned to the ground",
	long_desc = function(self, eff) return "The target is pinned to the ground, unable to move." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is pinned to the ground.", "+Pinned" end,
	on_lose = function(self, err) return "#Target# is no longer pinned.", "-Pinned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "ATTACK",
	desc = "Attack",
	long_desc = function(self, eff) return ("The target's combat attack is improved by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# aims carefully." end,
	on_lose = function(self, err) return "#Target# aims less carefully." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}

newEffect{
	name = "DEADLY_STRIKES",
	desc = "Deadly Strikes",
	long_desc = function(self, eff) return ("The target's armour penetration is increased by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# aims carefully." end,
	on_lose = function(self, err) return "#Target# aims less carefully." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_apr", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_apr", eff.tmpid)
	end,
}

newEffect{
	name = "MIGHTY_BLOWS",
	desc = "Mighty Blows",
	long_desc = function(self, eff) return ("The target's combat damage is improved by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# looks menacing." end,
	on_lose = function(self, err) return "#Target# looks less menacing." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "ROTTING_DISEASE",
	desc = "Rotting Disease",
	long_desc = function(self, eff) return ("The target is infected by a disease, reducing its constitution by %d and doing %0.2f blight damage per turn."):format(eff.con, eff.dam) end,
	type = "physical",
	subtype = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by a rotting disease!" end,
	on_lose = function(self, err) return "#Target# is free from the rotting disease." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_CON] = -eff.con})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "DECREPITUDE_DISEASE",
	desc = "Decrepitude Disease",
	long_desc = function(self, eff) return ("The target is infected by a disease, reducing its dexterity by %d and doing %0.2f blight damage per turn."):format(eff.dex, eff.dam) end,
	type = "physical",
	subtype = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by a decrepitude disease!" end,
	on_lose = function(self, err) return "#Target# is free from the decrepitude disease." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_DEX] = -eff.dex})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "WEAKNESS_DISEASE",
	desc = "Weakness Disease",
	long_desc = function(self, eff) return ("The target is infected by a disease, reducing its strength by %d and doing %0.2f blight damage per turn."):format(eff.str, eff.dam) end,
	type = "physical",
	subtype = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by a weakness disease!" end,
	on_lose = function(self, err) return "#Target# is free from the weakness disease." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = -eff.str})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "EPIDEMIC",
	desc = "Epidemic",
	long_desc = function(self, eff) return ("The target is infected by a disease, doing %0.2f blight damage per turn and reducig healing received by %d%%.\nEach non-disease blight damage done to it will spread the disease."):format(eff.dam, eff.heal_factor) end,
	type = "physical",
	subtype = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by an epidemic!" end,
	on_lose = function(self, err) return "#Target# is free from the epidemic." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("diseases_spread_on_blight", 1)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("diseases_spread_on_blight", eff.tmpid)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "CRIPPLE",
	desc = "Cripple",
	long_desc = function(self, eff) return ("The target is crippled, reducing attack by %d and damage by %d."):format(eff.atk, eff.dam) end,
	type = "physical",
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#Target# is crippled." end,
	on_lose = function(self, err) return "#Target# is not cripple anymore." end,
	activate = function(self, eff)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		self:removeTemporaryValue("combat_dam", eff.damid)
	end,
}

newEffect{
	name = "GOLEM_MOUNT",
	desc = "Golem Mount",
	long_desc = function(self, eff) return "The target is inside his golem." end,
	type = "physical",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:wearObject(eff.mount, true, true)
		game.level:removeEntity(eff.mount.mount.actor)
		eff.mount.mount.effect = self.EFF_GOLEM_MOUNT
	end,
	deactivate = function(self, eff)
		if self:removeObject(self.INVEN_MOUNT, 1, true) then
			-- Only unmount if dead
			if not eff.mount.mount.actor.dead then
				-- Find space
				local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[engine.Map.ACTOR]=true})
				if x then
					eff.mount.mount.actor:move(x, y, true)
					game.level:addEntity(eff.mount.mount.actor)
				end
			end
		end
	end,
}

newEffect{
	name = "BURROW",
	desc = "Burrow",
	long_desc = function(self, eff) return "The target is able to burrow into walls." end,
	type = "physical",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.pass = self:addTemporaryValue("can_pass", {pass_wall=1})
		eff.dig = self:addTemporaryValue("move_project", {[DamageType.DIG]=1})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("can_pass", eff.pass)
		self:removeTemporaryValue("move_project", eff.dig)
	end,
}

newEffect{
	name = "INCREASED_LIFE",
	desc = "Increased Life",
	long_desc = function(self, eff) return ("The target's maximum life is increased by %d."):format(eff.life) end,
	type = "physical",
	status = "beneficial",
	on_gain = function(self, err) return "#Target# gains extra life.", "+Life" end,
	on_lose = function(self, err) return "#Target# loses extra life.", "-Life" end,
	parameters = { life = 50 },
	activate = function(self, eff)
		self.max_life = self.max_life + eff.life
		self.life = self.life + eff.life
		self.changed = true
	end,
	deactivate = function(self, eff)
		self.max_life = self.max_life - eff.life
		self.life = self.life - eff.life
		self.changed = true
		if self.life <= 0 then
			self.life = 1
			self:setEffect(self.EFF_STUNNED, 3, {})
			game.logSeen(self, "%s's increased life wears off and is stunned by the change.", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "RAMPAGE",
	desc = "Rampaging",
	long_desc = function(self, eff) return "The target is rampaging!" end,
	type = "physical",
	status = "beneficial",
	parameters = { hateLoss = 0, critical = 0, damage = 0, speed = 0, attack = 0, evasion = 0 }, -- use percentages not fractions
	on_gain = function(self, err) return "#F53CBE##Target# begins rampaging!", "+Rampage" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer rampaging.", "-Rampage" end,
	activate = function(self, eff)
		if eff.hateLoss or 0 > 0 then eff.hateLossId = self:addTemporaryValue("hate_regen", -eff.hateLoss) end
		if eff.critical or 0 > 0 then eff.criticalId = self:addTemporaryValue("combat_physcrit", eff.critical) end
		if eff.damage or 0 > 0 then eff.damageId = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=eff.damage}) end
		if eff.speed or 0 > 0 then eff.speedId = self:addTemporaryValue("global_speed_add", eff.speed * 0.01) end
		if eff.attack or 0 > 0 then eff.attackId = self:addTemporaryValue("combat_atk", self:combatAttack() * eff.attack * 0.01) end
		if eff.evasion or 0 > 0 then eff.evasionId = self:addTemporaryValue("evasion", eff.evasion) end

		eff.particle = self:addParticles(Particles.new("rampage", 1))
	end,
	deactivate = function(self, eff)
		if eff.hateLossId then self:removeTemporaryValue("hate_regen", eff.hateLossId) end
		if eff.criticalId then self:removeTemporaryValue("combat_physcrit", eff.criticalId) end
		if eff.damageId then self:removeTemporaryValue("inc_damage", eff.damageId) end
		if eff.speedId then self:removeTemporaryValue("global_speed_add", eff.speedId) end
		if eff.attackId then self:removeTemporaryValue("combat_atk", eff.attackId) end
		if eff.evasionId then self:removeTemporaryValue("evasion", eff.evasionId) end

		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "FRENZY",
	desc = "Frenzy",
	long_desc = function(self, eff) return ("Increases global action speed by %d%% and physical crit by %d%%.\nAdditionally the target will continue to fight until it's hit points reach -%d%%."):format(eff.power * 100, eff.crit, eff.dieat * 100) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# goes into a killing frenzy.", "+Frenzy" end,
	on_lose = function(self, err) return "#Target# calms down.", "-Frenzy" end,
	on_merge = function(self, old_eff, new_eff)
		-- use on merge so reapplied frenzy doesn't kill off creatures with negative life
		old_eff.dur = new_eff.dur
		old_eff.power = new_eff.power
		old_eff.crit = new_eff.crit
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
		eff.critid = self:addTemporaryValue("combat_physcrit", eff.crit)
		eff.dieatid = self:addTemporaryValue("die_at", -self.max_life * eff.dieat)
	end,
	deactivate = function(self, eff)
		-- check negative life first incase the creature has healing
		if self.life <= 0 then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "Falls dead!", {255,0,255})
			game.logSeen(self, "%s dies when its frenzy ends!", self.name:capitalize())
			self:die(self)
		end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("combat_physcrit", eff.critid)
		self:removeTemporaryValue("die_at", eff.dieatid)
	end,
}

newEffect{
	name = "BLOODBATH",
	desc = "Bloodbath",
	long_desc = function(self, eff) return ("The thrill of combat improves the target's maximum life by %d, life regeneration by %d%% and stamina regeneration by %d%%."):format(eff.hp, eff.regen, eff.regen) end,
	type = "physical",
	status = "beneficial",
	parameters = { hp=10, regen=10 },
	on_gain = function(self, err) return nil, "+Bloodbath" end,
	on_lose = function(self, err) return nil, "-Bloodbath" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("max_life", old_eff.life_id)
		self:removeTemporaryValue("life_regen", old_eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", old_eff.stamina_regen_id)

		-- Take the new values, dont heal, otherwise you get a free heal each crit .. which is totaly broken
		local v = new_eff.hp * self.max_life / 100
		new_eff.life_id = self:addTemporaryValue("max_life", v)
		new_eff.life_regen_id = self:addTemporaryValue("life_regen", new_eff.regen * self.life_regen / 100)
		new_eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", new_eff.regen * self.stamina_regen / 100)
		return new_eff
	end,
	activate = function(self, eff)
		local v = eff.hp * self.max_life / 100
		eff.life_id = self:addTemporaryValue("max_life", v)
		self:heal(v)
		eff.life_regen_id = self:addTemporaryValue("life_regen", eff.regen * self.life_regen / 100)
		eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", eff.regen * self.stamina_regen / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life_id)
		self:removeTemporaryValue("life_regen", eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", eff.stamina_regen_id)
	end,
}

newEffect{
	name = "BLOODRAGE",
	desc = "Bloodrage",
	long_desc = function(self, eff) return ("The target's strength is increased by %d by the thrill of combat."):format(eff.inc) end,
	type = "physical",
	status = "beneficial",
	parameters = { inc=1, max=10 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_stats", old_eff.tmpid)
		old_eff.cur_inc = math.min(old_eff.cur_inc + new_eff.inc, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = old_eff.cur_inc})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_inc = eff.inc
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = eff.inc})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "UNSTOPPABLE",
	desc = "Unstoppable",
	long_desc = function(self, eff) return ("The target is unstoppable! It refuses to die, and at the end it will heal %d Life."):format(eff.kills * eff.hp_per_kill * self.max_life / 100) end,
	type = "physical",
	status = "beneficial",
	parameters = { hp_per_kill=2 },
	activate = function(self, eff)
		eff.kills = 0
		eff.tmpid = self:addTemporaryValue("unstoppable", 1)
		eff.healid = self:addTemporaryValue("no_life_regen", 1)
	end,
	deactivate = function(self, eff)
		self:heal(eff.kills * eff.hp_per_kill * self.max_life / 100)
		self:removeTemporaryValue("unstoppable", eff.tmpid)
		self:removeTemporaryValue("no_life_regen", eff.healid)
	end,
}

newEffect{
	name = "DIM_VISION",
	desc = "Reduced Vision",
	long_desc = function(self, eff) return ("The target's vision range is decreased by %d."):format(eff.sight) end,
	type = "physical",
	status = "detrimental",
	parameters = { sight=5 },
	on_gain = function(self, err) return "#Target# is surrounded by a thick smoke.", "+Dim Vision" end,
	on_lose = function(self, err) return "The smoke around #target# dissipate.", "-Dim Vision" end,
	activate = function(self, eff)
		if self.sight - eff.sight < 1 then eff.sight = self.sight - 1 end
		eff.tmpid = self:addTemporaryValue("sight", -eff.sight)
		self:setTarget(nil) -- Loose target!
		self:doFOV()
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sight", eff.tmpid)
		self:doFOV()
	end,
}

newEffect{
	name = "NO_SUMMON",
	desc = "Suppress Summon",
	long_desc = function(self, eff) return "Your summons are suppressed by some force." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# attunes to the damage.", "+Resolve" end,
	on_lose = function(self, err) return "#Target# is no longer attuned.", "-Resolve" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("suppress_summon", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("suppress_summon", eff.tmpid)
	end,
}

newEffect{
	name = "RESOLVE",
	desc = "Resolve",
	long_desc = function(self, eff) return ("You gain %d%% resistance against %s."):format(eff.res, DamageType:get(eff.damtype).name) end,
	type = "physical",
	status = "beneficial",
	parameters = { res=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target# attunes to the damage.", "+Resolve" end,
	on_lose = function(self, err) return "#Target# is no longer attuned.", "-Resolve" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[eff.damtype]=eff.res})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "WILD_SPEED",
	desc = "Wild Speed",
	long_desc = function(self, eff) return ("The movement infusion allows you to run at extreme fast pace. Any other action other than movement will cancel it .Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Wild Speed" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Wild Speed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("wild_speed", 1)
		eff.moveid = self:addTemporaryValue("global_speed_add", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_speed", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("global_speed_add", eff.moveid)
	end,
}

newEffect{
	name = "STEP_UP",
	desc = "Step Up",
	long_desc = function(self, eff) return ("Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Step Up" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Step Up" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("step_up", 1)
		eff.moveid = self:addTemporaryValue("global_speed_add", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("step_up", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("global_speed_add", eff.moveid)
	end,
}

newEffect{
	name = "LIGHTNING_SPEED",
	desc = "Lightning Speed",
	long_desc = function(self, eff) return ("Turn into pure lightning, moving %d%% faster. It also increases your lightning resistance by 100%% and your physical resistance by 30%%."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# turns into pure lightning!.", "+Lightning Speed" end,
	on_lose = function(self, err) return "#Target# is back to normal.", "-Lightning Speed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("lightning_speed", 1)
		eff.moveid = self:addTemporaryValue("global_speed_add", eff.power/100)
		eff.resistsid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL]=30,
			[DamageType.LIGHTNING]=100,
		})
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
		eff.particle = self:addParticles(Particles.new("bolt_lightning", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("lightning_speed", eff.tmpid)
		self:removeTemporaryValue("resists", eff.resistsid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("global_speed_add", eff.moveid)
	end,
}

newEffect{
	name = "DRAGONS_FIRE",
	desc = "Dragon's Fire",
	long_desc = function(self, eff) return ("Dragon blood runs through your veins. You can breathe fire (or have it improved if you already could)."):format() end,
	type = "physical",
	status = "beneficial",
	parameters = {power=1},
	on_gain = function(self, err) return "#Target#'s throat seems to be burning.", "+Dragon's fire" end,
	on_lose = function(self, err) return "#Target#'s throat seems to cool down.", "-Dragon's fire" end,
	activate = function(self, eff)
		local t_id = self.T_FIRE_BREATH
		if not self.talents[t_id] then
			-- Auto assign to hotkey
			if self.hotkey then
				for i = 1, 36 do
					if not self.hotkey[i] then
						self.hotkey[i] = {"talent", t_id}
						break
					end
				end
			end
		end

		eff.tmpid = self:addTemporaryValue("talents", {[t_id] = eff.power})
	end,
	deactivate = function(self, eff)
		local t_id = self.T_FIRE_BREATH
		self:removeTemporaryValue("talents", eff.tmpid)
		if self.talents[t_id] == 0 then
			self.talents[t_id] = nil
			if self.hotkey then
				for i, known_t_id in pairs(self.hotkey) do
					if known_t_id[1] == "talent" and known_t_id[2] == t_id then self.hotkey[i] = nil end
				end
			end
		end
	end,
}

newEffect{
	name = "CRUSHED",
	desc = "Crushed",
	long_desc = function(self, eff) return ("Intense gravity that pins and deals %0.2f physical damage per turn."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is being crushed!", "+Crushed" end,
	on_lose = function(self, err) return "#Target# stops being crushed.", "-Crushed" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "GREATER_WEAPON_FOCUS",
	desc = "Greater Weapon Focus",
	long_desc = function(self, eff) return ("%d%% chance to score a secondary blow."):format(eff.chance) end,
	type = "physical",
	status = "beneficial",
	parameters = { chance=50 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

-- Grappling stuff
newEffect{
	name = "GRAPPLING",
	desc = "Grappling",
	long_desc = function(self, eff) return ("The target is engaged in a grapple.  Any movement will break the effect as will some unarmed talents."):format() end,
	type = "physical",
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# is engaged in a grapple!", "+Grappling" end,
	on_lose = function(self, err) return "#Target# has released the hold.", "-Grappling" end,
	on_timeout = function(self, eff)
		local p = eff.trgt:hasEffect(eff.trgt.EFF_GRAPPLED)
		if not p or p.src ~= self or core.fov.distance(self.x, self.y, eff.trgt.x, eff.trgt.y) > 1 or eff.trgt.dead or not game.level:hasEntity(eff.trgt) then
			self:removeEffect(self.EFF_GRAPPLING)
		end
	end,
	activate = function(self, eff)
		local drain = 6 - (self:getTalentLevelRaw(self.T_CLINCH) or 0)
		eff.tmpid = self:addTemporaryValue("stamina_regen", - drain)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stamina_regen", eff.tmpid)
	end,
}

newEffect{
	name = "GRAPPLED",
	desc = "Grappled",
	long_desc = function(self, eff) return ("The target is grappled, unable to move, and has it's defense and attack reduced by %d."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	remove_on_clone = true,
	on_gain = function(self, err) return "#Target# is grappled!", "+Grappled" end,
	on_lose = function(self, err) return "#Target# is free from the grapple.", "-Grappled" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.atk = self:addTemporaryValue("combat_atk", -eff.power)
	end,
	on_timeout = function(self, eff)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_GRAPPLED)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atk)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "CRUSHING_HOLD",
	desc = "Crushing Hold",
	long_desc = function(self, eff) return ("The target is being crushed and suffers %d damage each turn"):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being crushed.", "+Crushing Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the crushing hold.", "-Crushing Hold" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if p and p.src == eff.src then
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		else
			self:removeEffect(self.EFF_CRUSHING_HOLD)
		end
	end,
}

newEffect{
	name = "STRANGLE_HOLD",
	desc = "Strangle Hold",
	long_desc = function(self, eff) return ("The target is being strangled and may not cast spells and suffers %d damage each turn."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being strangled.", "+Strangle Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the strangle hold.", "-Strangle Hold" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if p and p.src == eff.src then
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		else
			self:removeEffect(self.EFF_STRANGLE_HOLD)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("silence", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence", eff.tmpid)
	end,
}

newEffect{
	name = "MAIMED",
	desc = "Maimed",
	long_desc = function(self, eff) return ("The target is maimed, reducing damage by %d and global speed by 30%%."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#Target# is maimed.", "+Maimed" end,
	on_lose = function(self, err) return "#Target# has recovered from the maiming.", "-Maimed" end,
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.dam)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.3)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "COMBO",
	desc = "Combo",
	display_desc = function(self, eff) return eff.cur_power.." Combo" end,
	long_desc = function(self, eff) return ("The target is in the middle of a combo chain and has earned %d combo points."):format(eff.cur_power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=1, max=5 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combo", old_eff.tmpid)
		old_eff.cur_power = math.min(old_eff.cur_power + new_eff.power, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("combo", {power = old_eff.cur_power})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("combo", {eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combo", eff.tmpid)
	end,
}

newEffect{
	name = "DEFENSIVE_MANEUVER",
	desc = "Defensive Maneuver",
	long_desc = function(self, eff) return ("The target's defense is increased by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target# is moving defensively!", "+Defensive Maneuver" end,
	on_lose = function(self, err) return "#Target# isn't moving as defensively anymore.", "-Defensive Maneuver" end,
	activate = function(self, eff)
		eff.defense = self:addTemporaryValue("combat_def", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defense)
	end,
}

newEffect{
	name = "SET_UP",
	desc = "Set Up",
	long_desc = function(self, eff) return ("The target is off balance and is %d%% more likely to be crit by the target that set it up.  In addition all it's saves are reduced by %d."):format(eff.power, eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target# has been set up!", "+Set Up" end,
	on_lose = function(self, err) return "#Target# has survived the set up.", "-Set Up" end,
	activate = function(self, eff)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
	end,
}

newEffect{
	name = "RECOVERY",
	desc = "Recovery",
	long_desc = function(self, eff) return ("The target is recovering from a damaging blow and regaining %d life each turn."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is recovering from the attack!", "+Recovery" end,
	on_lose = function(self, err) return "#Target# has finished recovering from the attack.", "-Recovery" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "REFLEXIVE_DODGING",
	desc = "Reflexive Dodging",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Reflexive Dodging" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Reflexive Dodging" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "WEAKENED_DEFENSES",
	desc = "Weakened Defenses",
	long_desc = function(self, eff) return ("The target's physical resistance has been reduced by %d%%."):format(eff.inc) end,
	type = "physical",
	status = "detrimental",
	parameters = { inc=1, max=5 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("resists", old_eff.tmpid)
		old_eff.cur_inc = math.max(old_eff.cur_inc + new_eff.inc, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL] = old_eff.cur_inc})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_inc = eff.inc
		eff.tmpid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL] = eff.inc,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "STONE_VINE",
	desc = "Stone Vine",
	long_desc = function(self, eff) return ("A living stone vine holds the target on the ground and doing %0.2f physical damage per turn."):format(eff.dam) end,
	type = "physical",
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return "#Target# is grabbed by a stone vine.", "+Stone Vine" end,
	on_lose = function(self, err) return "#Target# is free from the stone vine.", "-Stone Vine" end,
	activate = function(self, eff)
		eff.last_x = eff.src.x
		eff.last_y = eff.src.y
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.particle = self:addParticles(Particles.new("stonevine_static", 1, {}))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		local severed = false
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) >= eff.free or eff.src.dead or not game.level:hasEntity(eff.src) then severed = true end
		if rng.percent(eff.free_chance) then severed = true end

		if severed then
			return true
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.dam)
			if eff.src:knowTalent(eff.src.T_ELDRITCH_VINE) then
				local l = eff.src:getTalentLevel(eff.src.T_ELDRITCH_VINE)
				eff.src:incEquilibrium(-l / 4)
				eff.src:incMana(l / 3)
			end
		end
		eff.last_x = eff.src.x
		eff.last_y = eff.src.y
	end,
}

newEffect{
	name = "WATERS_OF_LIFE",
	desc = "Waters of Life",
	long_desc = function(self, eff) return ("The target purifies all diseases and poisons, turning them into healing effects.") end,
	type = "physical",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.poisid = self:addTemporaryValue("purify_poison", 1)
		eff.diseid = self:addTemporaryValue("purify_disease", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("purify_poison", eff.poisid)
		self:removeTemporaryValue("purify_disease", eff.diseid)
	end,
}

newEffect{
	name = "ELEMENTAL_HARMONY",
	desc = "Elemental Harmony",
	long_desc = function(self, eff)
		if eff.type == DamageType.FIRE then return ("Increases global speed by %d%%."):format(100 * (0.1 + eff.power / 16))
		elseif eff.type == DamageType.COLD then return ("Increases armour by %d."):format(3 + eff.power *2)
		elseif eff.type == DamageType.LIGHTNING then return ("Increases all stats by %d."):format(math.floor(eff.power))
		elseif eff.type == DamageType.ACID then return ("Increases life regen by %0.2f%%."):format(5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then return ("Increases all resists by %d%%."):format(5 + eff.power * 1.4)
		end
	end,
	type = "physical",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		if eff.type == DamageType.FIRE then
			eff.tmpid = self:addTemporaryValue("global_speed_add", 0.1 + eff.power / 16)
		elseif eff.type == DamageType.COLD then
			eff.tmpid = self:addTemporaryValue("combat_armor", 3 + eff.power * 2)
		elseif eff.type == DamageType.LIGHTNING then
			eff.tmpid = self:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_STR] = math.floor(eff.power),
				[Stats.STAT_DEX] = math.floor(eff.power),
				[Stats.STAT_MAG] = math.floor(eff.power),
				[Stats.STAT_WIL] = math.floor(eff.power),
				[Stats.STAT_CUN] = math.floor(eff.power),
				[Stats.STAT_CON] = math.floor(eff.power),
			})
		elseif eff.type == DamageType.ACID then
			eff.tmpid = self:addTemporaryValue("life_regen", 5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then
			eff.tmpid = self:addTemporaryValue("resists", {all=5 + eff.power * 1.4})
		end
	end,
	deactivate = function(self, eff)
		if eff.type == DamageType.FIRE then
			self:removeTemporaryValue("global_speed_add", eff.tmpid)
		elseif eff.type == DamageType.COLD then
			self:removeTemporaryValue("combat_armor", eff.tmpid)
		elseif eff.type == DamageType.LIGHTNING then
			self:removeTemporaryValue("inc_stats", eff.tmpid)
		elseif eff.type == DamageType.ACID then
			self:removeTemporaryValue("life_regen", eff.tmpid)
		elseif eff.type == DamageType.NATURE then
			self:removeTemporaryValue("resists", eff.tmpid)
		end
	end,
}

newEffect{
	name = "HEALING_NEXUS",
	desc = "Healing Nexus",
	long_desc = function(self, eff) return ("All healing done to the target is instead redirected to %s by %d%%."):format(eff.src.name, eff.pct * 100, eff.src.name) end,
	type = "physical",
	status = "beneficial",
	parameters = { pct = 1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WORM_ROT",
	desc = "Worm Rot",
	long_desc = function(self, eff) return ("The target is infected with carrion worm larvae.  Each turn it will lose one beneficial physical effect and %0.2f blight and acid damage will be inflicted.\nAfter five turns the disease will inflict %0.2f blight damage and spawn a carrion worm mass."):format(eff.dam, eff.burst) end,
	type = "physical",
	subtype = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by a terrible worm rot!" end,
	on_lose = function(self, err) return "#Target# is free from the worm rot." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		eff.rot_timer = eff.rot_timer - 1

		-- disease damage
		if self:attr("purify_disease") then
			self:heal(eff.dam)
		else
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
		-- acid damage from the larvae
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.dam)

		local effs = {}
		-- Go through all physical effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "beneficial" and e.type == "physical" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		-- remove a random physical effect
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end

		-- burst and spawn a worm mass
		if eff.rot_timer == 0 then
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.burst, {from_disease=true})
			local t = eff.src:getTalentFromId(eff.src.T_WORM_ROT)
			t.spawn_carrion_worm(eff.src, self, t)
			game.logSeen(self, "#LIGHT_RED#A carrion worm mass bursts out of %s!", self.name:capitalize())
			self:removeEffect(self.EFF_WORM_ROT)
		end
	end,
}

newEffect{
	name = "PSIONIC_BIND",
	desc = "Immobilized",
	long_desc = function(self, eff) return "Immobilized by telekinetic forces." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is bound by telekinetic forces!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# shakes free of the telekinetic binding", "-Paralyzed" end,
	activate = function(self, eff)
		--eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
	end,
	deactivate = function(self, eff)
		--self:removeParticles(eff.particle)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "IMPLODING",
	desc = "Slow",
	long_desc = function(self, eff) return ("Slowed by 50%% and taking %d crushing damage per turn."):format( eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is being crushed.", "+Imploding" end,
	on_lose = function(self, err) return "#Target# shakes off the crushing forces.", "-Imploding" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.5)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}