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
	name = "INFUSION_COOLDOWN",
	desc = "Infusion Saturation",
	long_desc = function(self, eff) return ("The more you use infusions, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "infusion",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "RUNE_COOLDOWN",
	desc = "Runic Saturation",
	long_desc = function(self, eff) return ("The more you use runes, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "rune",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TAINT_COOLDOWN",
	desc = "Tainted",
	long_desc = function(self, eff) return ("The more you use taints, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "taint",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

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
	name = "MANASURGE",
	desc = "Surging mana",
	long_desc = function(self, eff) return ("The mana surge engulfs the target, regenerating %0.2f mana per turn."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts to surge mana.", "+Manasurge" end,
	on_lose = function(self, err) return "#Target# stops surging mana.", "-Manasurge" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the mana
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur

		self:removeTemporaryValue("mana_regen", old_eff.tmpid)
		old_eff.tmpid = self:addTemporaryValue("mana_regen", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("mana_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("mana_regen", eff.tmpid)
	end,
}

newEffect{
	name = "REGENERATION",
	desc = "Regeneration",
	long_desc = function(self, eff) return ("A flow of life spins around the target, regenerating %0.2f life per turn."):format(eff.power) end,
	type = "magical",
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
	type = "magical",
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
	type = "poison",
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
	type = "poison",
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target# is poisoned and cannot move!", "+Spydric Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Spydric Poison" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "pin")
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
	type = "poison",
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
	type = "poison",
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
	type = "poison",
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
	type = "poison",
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
	name = "FROZEN",
	desc = "Frozen",
	long_desc = function(self, eff) return ("The target is encased in ice. All damage done to you will be split, 40%% absorbed by the ice and 60%% by yourself. Your defense is nullified while in the ice and you may only attack the ice but you are also immune to any new detrimental status effects. The target can not teleport or heal while frozen. %d HP on the iceblock remaining."):format(eff.hp) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is encased in ice!", "+Frozen" end,
	on_lose = function(self, err) return "#Target# is free from the ice.", "-Frozen" end,
	activate = function(self, eff)
		-- Change color
		eff.old_r = self.color_r
		eff.old_g = self.color_g
		eff.old_b = self.color_b
		self.color_r = 0
		self.color_g = 255
		self.color_b = 155
		if not self.add_displays then
			self.add_displays = { Entity.new{image='npc/iceblock.png', display=' ', display_on_seen=true } }
			eff.added_display = true
		end
		if self._mo then self._mo:invalidate() self._mo = nil end
		game.level.map:updateMap(self.x, self.y)

		eff.hp = eff.hp or 100
		eff.tmpid = self:addTemporaryValue("encased_in_ice", 1)
		eff.healid = self:addTemporaryValue("no_healing", 1)
		eff.moveid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.defid = self:addTemporaryValue("combat_def", -1000)
		eff.rdefid = self:addTemporaryValue("combat_def_ranged", -1000)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "freeze")

		self:setTarget(self)
	end,
	on_timeout = function(self, eff)
		self:setTarget(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("encased_in_ice", eff.tmpid)
		self:removeTemporaryValue("no_healing", eff.healid)
		self:removeTemporaryValue("never_move", eff.moveid)
		self:removeTemporaryValue("frozen", eff.frozid)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_def_ranged", eff.rdefid)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self.color_r = eff.old_r
		self.color_g = eff.old_g
		self.color_b = eff.old_b
		if eff.added_display then self.add_displays = nil end
		if self._mo then self._mo:invalidate() self._mo = nil end
		game.level.map:updateMap(self.x, self.y)
		self:setTarget(nil)
	end,
}

newEffect{
	name = "FROZEN_FEET",
	desc = "Frozen Feet",
	long_desc = function(self, eff) return "The target is frozen on the ground, able to act freely but not move." end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is frozen to the ground!", "+Frozen" end,
	on_lose = function(self, err) return "#Target# warms up.", "-Frozen" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "pin")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
		self:removeTemporaryValue("frozen", eff.frozid)
	end,
}

newEffect{
	name = "STONED",
	desc = "Stoned",
	long_desc = function(self, eff) return "The target has been turned to stone, making it subject to shattering but improving physical(+20%), fire(+80%) and lightning(+50%) resistances." end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# turns to stone!", "+Stoned" end,
	on_lose = function(self, err) return "#Target# is not stoned anymore.", "-Stoned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stoned", 1)
		eff.resistsid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL]=20,
			[DamageType.FIRE]=80,
			[DamageType.LIGHTNING]=50,
		})
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stoned", eff.tmpid)
		self:removeTemporaryValue("resists", eff.resistsid)
	end,
}

newEffect{
	name = "BURNING_SHOCK",
	desc = "Burning Shock",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn and unable to act."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is paralyzed by the burning flame!", "+Burning Shock" end,
	on_lose = function(self, err) return "#Target# is not paralyzed anymore.", "-Burning Shock" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
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

		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "SILENCED",
	desc = "Silenced",
	long_desc = function(self, eff) return "The target is silenced, preventing it from casting spells and using some vocal talents." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is silenced!", "+Silenced" end,
	on_lose = function(self, err) return "#Target# is not silenced anymore.", "-Silenced" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("silence", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "silence")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence", eff.tmpid)
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
		eff.dur = self:updateEffectDuration(eff.dur, "disarmed")
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
	name = "MEDITATION",
	desc = "Meditation",
	long_desc = function(self, eff) return "The target is meditating. Any damage will stop it." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_timeout = function(self, eff)
		self:incEquilibrium(-eff.per_turn)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("dazed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("dazed", eff.tmpid)
		if eff.dur <= 0 then
			self:incEquilibrium(-eff.final)
		end
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
	name = "EARTHEN_BARRIER",
	desc = "Earthen Barrier",
	long_desc = function(self, eff) return ("Reduces physical damage received by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# hardens its skin.", "+Earthen barrier" end,
	on_lose = function(self, err) return "#Target#'s skin returns to normal.", "-Earthen barrier" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("stone_skin", 1, {density=4}))
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "MOLTEN_SKIN",
	desc = "Molten Skin",
	long_desc = function(self, eff) return ("Reduces fire damage received by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s skin turns into molten lava.", "+Molten Skin" end,
	on_lose = function(self, err) return "#Target#'s skin returns to normal.", "-Molten Skin" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("wildfire", 1))
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.FIRE]=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}
newEffect{
	name = "REFLECTIVE_SKIN",
	desc = "Reflective Skin",
	long_desc = function(self, eff) return ("Magically returns %d%% of any damage done to the attacker."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s skin starts to shimmer.", "+Reflective Skin" end,
	on_lose = function(self, err) return "#Target#'s skin returns to normal.", "-Reflective Skin" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("reflect_damage", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reflect_damage", eff.tmpid)
	end,
}

newEffect{
	name = "SUMMON_CONTROL",
	desc = "Summon Control",
	long_desc = function(self, eff) return ("Reduces damage received by %d%% and increases summon time by %d."):format(eff.res, eff.incdur) end,
	type = "physical",
	status = "beneficial",
	parameters = { res=10, incdur=10 },
	activate = function(self, eff)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
		eff.durid = self:addTemporaryValue("summon_time", eff.incdur)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resid)
		self:removeTemporaryValue("summon_time", eff.durid)
	end,
	on_timeout = function(self, eff)
		eff.dur = self.summon_time
	end,
}

newEffect{
	name = "VIMSENSE",
	desc = "Vimsense",
	long_desc = function(self, eff) return ("Reduces blight resistance by %d%%."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.BLIGHT]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "SPEED",
	desc = "Speed",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "magical",
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
	type = "magical",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# slows down.", "+Slow" end,
	on_lose = function(self, err) return "#Target# speeds up.", "-Slow" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "INVISIBILITY",
	desc = "Invisibility",
	long_desc = function(self, eff) return ("Improves/gives invisibility (power %d)."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# vanishes from sight.", "+Invis" end,
	on_lose = function(self, err) return "#Target# is no longer invisible.", "-Invis" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invisible", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invisible", eff.tmpid)
		self:resetCanSeeCacheOf()
	end,
}

newEffect{
	name = "SEE_INVISIBLE",
	desc = "See Invisible",
	long_desc = function(self, eff) return ("Improves/gives the ability to see invisible creatures (power %d)."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s eyes tingle." end,
	on_lose = function(self, err) return "#Target#'s eyes tingle no more." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("see_invisible", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("see_invisible", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDED",
	desc = "Blinded",
	long_desc = function(self, eff) return "The target is blinded, unable to see anything." end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# loses sight!", "+Blind" end,
	on_lose = function(self, err) return "#Target# recovers sight.", "-Blind" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "blind")
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
	name = "CONFUSED",
	desc = "Confused",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%) and unable to perform complex actions."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	activate = function(self, eff)
		eff.dur = self:updateEffectDuration(eff.dur, "confusion")
		eff.power = eff.power - (self:attr("confusion_immune") or 0) / 2
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "BANE_BLINDED",
	desc = "Bane of Blindness",
	long_desc = function(self, eff) return ("The target is blinded, unable to see anything and takes %0.2f darkness damage per turns."):format(eff.dam) end,
	type = "bane",
	status = "detrimental",
	parameters = { dam=10},
	on_gain = function(self, err) return "#Target# loses sight!", "+Blind" end,
	on_lose = function(self, err) return "#Target# recovers sight.", "-Blind" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "blind")
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
	name = "BANE_CONFUSED",
	desc = "Bane of Confusion",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%), unable to perform complex actions and takes %0.2f darkness damage per turns."):format(eff.power, eff.dam) end,
	type = "bane",
	status = "detrimental",
	parameters = { power=50, dam=10 },
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.dur = self:updateEffectDuration(eff.dur, "confusion")
		eff.power = eff.power - (self:attr("confusion_immune") or 0) / 2
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
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
	name = "DOMINANT_WILL",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target's mind has been shattered. Its body remains as a thrall to your mind.") end,
	type = "mental",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#'s mind is shattered." end,
	on_lose = function(self, err) return "#Target# collapses." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=-15})
		self.faction = eff.src.faction
		self.ai_state = self.ai_state or {}
		self.ai_state.tactic_leash = 100
		self.remove_from_party_on_death = true
		self.no_inventory_access = true
		self.move_others = true
		self.summoner = eff.src
		self.summoner_gain_exp = true
		game.party:addMember(self, {
			control="full",
			type="thrall",
			title="Thrall",
			orders = {leash=true, follow=true},
			on_control = function(self)
				self:hotkeyAutoTalents()
			end,
		})
	end,
	deactivate = function(self, eff)
		self:die(eff.src)
	end,
}

newEffect{
	name = "SUPERCHARGE_GOLEM",
	desc = "Supercharge Golem",
	long_desc = function(self, eff) return ("The target is supercharged, increasing life regen by %0.2f and damage done by 20%%."):format(eff.regen) end,
	type = "magical",
	status = "beneficial",
	parameters = { regen=10 },
	on_gain = function(self, err) return "#Target# is overloaded with power.", "+Supercharge" end,
	on_lose = function(self, err) return "#Target# seems less dangerous.", "-Supercharge" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=25})
		eff.lid = self:addTemporaryValue("life_regen", eff.regen)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
		self:removeTemporaryValue("life_regen", eff.lid)
	end,
}

newEffect{
	name = "POWER_OVERLOAD",
	desc = "Power Overload",
	long_desc = function(self, eff) return ("The target radiates incredible power, increasing all damage done by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is overloaded with power.", "+Overload" end,
	on_lose = function(self, err) return "#Target# seems less dangerous.", "-Overload" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}

newEffect{
	name = "LIFE_TAP",
	desc = "Life Tap",
	long_desc = function(self, eff) return ("The target taps its blood's hidden power, increasing all damage done by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is overloaded with power.", "+Life Tap" end,
	on_lose = function(self, err) return "#Target# seems less dangerous.", "-Life Tap" end,
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
	name = "TIME_PRISON",
	desc = "Time Prison",
	long_desc = function(self, eff) return "The target is removed from the normal time stream, unable to act but unable to take any damage." end,
	type = "other", -- Type "other" so that nothing can dispel it
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is removed from time!", "+Out of Time" end,
	on_lose = function(self, err) return "#Target# is returned to normal time.", "-Out of Time" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.particle = self:addParticles(Particles.new("time_prison", 1))
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SENSE",
	desc = "Sensing",
	long_desc = function(self, eff) return "Improves senses, allowing the detection of unseen things." end,
	type = "magical",
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
	name = "ARCANE_EYE",
	desc = "Arcane Eye",
	long_desc = function(self, eff) return ("You have an arcane eye observing for you in a radius of %d."):format(eff.radius) end,
	type = "magical",
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		game.level.map.changed = true
		eff.particle = Particles.new("image", 1, {image="shockbolt/npc/arcane_eye", size=64})
		eff.particle.x = eff.x
		eff.particle.y = eff.y
		eff.particle.always_seen = true
		game.level.map:addParticleEmitter(eff.particle)
	end,
	on_timeout = function(self, eff)
		-- Track an actor if it's not dead
		if eff.track and not eff.track.dead then
			eff.x = eff.track.x
			eff.y = eff.track.y
			eff.particle.x = eff.x
			eff.particle.y = eff.y
			game.level.map.changed = true
		end
	end,
	deactivate = function(self, eff)
		game.level.map:removeParticleEmitter(eff.particle)
		game.level.map.changed = true
	end,
}

newEffect{
	name = "ALL_STAT",
	desc = "All stats increase",
	long_desc = function(self, eff) return ("All primary stats of the target are increased by %d."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_STR] = eff.power,
			[Stats.STAT_DEX] = eff.power,
			[Stats.STAT_MAG] = eff.power,
			[Stats.STAT_WIL] = eff.power,
			[Stats.STAT_CUN] = eff.power,
			[Stats.STAT_CON] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
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
	name = "DISPLACEMENT_SHIELD",
	desc = "Displacement Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a space distortion that randomly sends (%d%% chance) incoming damage to another target (%s). Absorbs %d/%d damage before it crumbles."):format(eff.chance, eff.target.name or "unknown", self.displacement_shield, eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10, target=nil, chance=25 },
	on_gain = function(self, err) return "The very fabric of space alters around #target#.", "+Displacement Shield" end,
	on_lose = function(self, err) return "The fabric of space around #target# stabilizes to normal.", "-Displacement Shield" end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		self.displacement_shield = eff.power
		self.displacement_shield_max = eff.power
		self.displacement_shield_chance = eff.chance
		--- Warning there can be only one time shield active at once for an actor
		self.displacement_shield_target = eff.target
		eff.particle = self:addParticles(Particles.new("displacement_shield", 1))
	end,
	on_aegis = function(self, eff, aegis)
		self.displacement_shield = self.displacement_shield + eff.power * aegis / 100
	end,
	on_timeout = function(self, eff)
		if eff.target.dead then
			eff.target = nil
			return true
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self.displacement_shield = nil
		self.displacement_shield_max = nil
		self.displacement_shield_chance = nil
		self.displacement_shield_target = nil
	end,
}

newEffect{
	name = "DAMAGE_SHIELD",
	desc = "Damage Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a magical shield, absorbing %d/%d damage before it crumbles."):format(self.damage_shield_absorb, eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The shield around #target# crumbles.", "-Shield" end,
	on_aegis = function(self, eff, aegis)
		self.damage_shield_absorb = self.damage_shield_absorb + eff.power * aegis / 100
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		self.damage_shield_absorb_max = eff.power
		eff.particle = self:addParticles(Particles.new("damage_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_shield", eff.tmpid)
		self.damage_shield_absorb = nil
		self.damage_shield_absorb_max = nil
	end,
}

newEffect{
	name = "TIME_SHIELD",
	desc = "Time Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a time distortion, absorbing %d/%d damage and sending it forward in time."):format(self.time_shield_absorb, eff.power) end,
	type = "time", -- Type "time" so that very little should be able to dispel it
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The very fabric of time alters around #target#.", "+Time Shield" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes to normal.", "-Time Shield" end,
	on_aegis = function(self, eff, aegis)
		self.time_shield_absorb = self.time_shield_absorb + eff.power * aegis / 100
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
		self.time_shield_absorb_max = eff.power
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		-- Time shield ends, setup a dot if needed
		if eff.power - self.time_shield_absorb > 0 then
			print("Time shield dot", eff.power - self.time_shield_absorb, (eff.power - self.time_shield_absorb) / 5)
			self:setEffect(self.EFF_TIME_DOT, 5, {power=(eff.power - self.time_shield_absorb) / 5})
		end

		self:removeTemporaryValue("time_shield", eff.tmpid)
		self.time_shield_absorb = nil
		self.time_shield_absorb_max = 0
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Time Shield Backfire",
	long_desc = function(self, eff) return ("The time distortion protecting the target has ended. All damage forwarded in time is now applied, doing %d arcane damage per turn."):format(eff.power) end,
	type = "time",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "The powerful time-altering energies come crashing down on #target#.", "+Time Shield Backfire" end,
	on_lose = function(self, err) return "The fabric of time around #target# returns to normal.", "-Time Shield Backfire" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ARCANE).projector(self, self.x, self.y, DamageType.ARCANE, eff.power)
	end,
}

newEffect{
	name = "BATTLE_SHOUT",
	desc = "Battle Shout",
	long_desc = function(self, eff) return ("Increases maximum life and stamina by %d%%."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.life = self:addTemporaryValue("max_life", self.max_life * eff.power / 100)
		eff.stamina = self:addTemporaryValue("max_stamina", self.max_stamina * eff.power / 100)
		self:heal(self.max_life * eff.power / 100)
		self:incStamina(self.max_stamina * eff.power / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life)
		self:removeTemporaryValue("max_stamina", eff.stamina)
	end,
}

newEffect{
	name = "BATTLE_CRY",
	desc = "Battle Cry",
	long_desc = function(self, eff) return ("The target's will to defend itself is shattered by the powerful battle cry, reducing defense by %d."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s will is shattered.", "+Battle Cry" end,
	on_lose = function(self, err) return "#Target# regains some of its will.", "-Battle Cry" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_def", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.tmpid)
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
		eff.dur = self:updateEffectDuration(eff.dur, "pin")
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
	type = "disease",
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
	type = "disease",
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
	type = "disease",
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
	type = "disease",
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
	name = "WILLFUL_COMBAT",
	desc = "Willful Combat",
	long_desc = function(self, eff) return ("The target puts all its willpower into its blows, improving damage by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# lashes out with pure willpower." end,
	on_lose = function(self, err) return "#Target#'s willpower rush ends." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "MARTYRDOM",
	desc = "Martyrdom",
	long_desc = function(self, eff) return ("All damage done by the target will also hurt it for %d%%."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is a martyr.", "+Martyr" end,
	on_lose = function(self, err) return "#Target# is no longer influenced by martyrdom.", "-Martyr" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("martyrdom", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("martyrdom", eff.tmpid)
	end,
}

newEffect{
	name = "GOLEM_OFS",
	desc = "Golem out of sight",
	long_desc = function(self, eff) return "The golem is out of sight of the alchemist; direct control will be lost!" end,
	type = "other",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target# is out of sight of its master; direct control will break!.", "+Out of sight" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#You lost sight of your golem for too long; direct control is broken!")
				game.player:runStop("golem out of sight")
				game.player:restStop("golem out of sight")
				game.party:setPlayer(self.summoner)
			end)
		end
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
	name = "CURSE_VULNERABILITY",
	desc = "Curse of Vulnerability",
	long_desc = function(self, eff) return ("The target is cursed, reducing all resistances by %d%%."):format(eff.power) end,
	type = "curse",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is cursed.", "+Curse" end,
	on_lose = function(self, err) return "#Target# is no longer cursed.", "-Curse" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_IMPOTENCE",
	desc = "Curse of Impotence",
	long_desc = function(self, eff) return ("The target is cursed, reducing all damage done by %d%%."):format(eff.power) end,
	type = "curse",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is cursed.", "+Curse" end,
	on_lose = function(self, err) return "#Target# is no longer cursed.", "-Curse" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_DEFENSELESSNESS",
	desc = "Curse of Defenselessness",
	long_desc = function(self, eff) return ("The target is cursed, reducing defence and all saves by %d."):format(eff.power) end,
	type = "curse",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is cursed.", "+Curse" end,
	on_lose = function(self, err) return "#Target# is no longer cursed.", "-Curse" end,
	activate = function(self, eff)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
	end,
}

newEffect{
	name = "CURSE_DEATH",
	desc = "Curse of Death",
	long_desc = function(self, eff) return ("The target is cursed, taking %0.2f darkness damage per turn and preventing natural life regeneration."):format(eff.dam) end,
	type = "curse",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is cursed.", "+Curse" end,
	on_lose = function(self, err) return "#Target# is no longer cursed.", "-Curse" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("no_life_regen", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_HATE",
	desc = "Curse of Hate",
	long_desc = function(self, eff) return ("The target is cursed, force all foes in a radius of 5 to attack it.") end,
	type = "curse",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# is cursed.", "+Curse" end,
	on_lose = function(self, err) return "#Target# is no longer cursed.", "-Curse" end,
	on_timeout = function(self, eff)
		if self.dead or not self.x then return end
		local tg = {type="ball", range=0, radius=5, friendlyfire=false}
		self:project(tg, self.x, self.y, function(tx, ty)
			local a = game.level.map(tx, ty, Map.ACTOR)
			if a and not a.dead and a:reactionToward(self) < 0 then a:setTarget(self) end
		end)
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "CONTINUUM_DESTABILIZATION",
	desc = "Continuum Destabilization",
	long_desc = function(self, eff) return ("The target has been affected by space or time manipulations and is becoming more resistant to them (+%d)."):format(eff.power) end,
	type = "other", -- Type "other" so that nothing can dispel it
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# looks a little pale around the edges.", "+Destabilized" end,
	on_lose = function(self, err) return "#Target# is firmly planted in reality.", "-Destabilized" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the continuum_destabilization
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		-- Need to remove and re-add the continuum_destabilization
		self:removeTemporaryValue("continuum_destabilization", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("continuum_destabilization", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("continuum_destabilization", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("continuum_destabilization", eff.effid)
	end,
}

newEffect{
	name = "SUMMON_DESTABILIZATION",
	desc = "Summoning Destabilization",
	long_desc = function(self, eff) return ("The more the target summons creatures the longer it will take to summon more (+%d turns)."):format(eff.power) end,
	type = "other", -- Type "other" so that nothing can dispel it
	status = "detrimental",
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		-- Merge the destabilizations
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		-- Need to remove and re-add the talents CD
		self:removeTemporaryValue("talent_cd_reduction", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -old_eff.power })
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_cd_reduction", eff.effid)
	end,
}

newEffect{
	name = "FREE_ACTION",
	desc = "Free Action",
	long_desc = function(self, eff) return ("The target gains %d%% stun, daze and pinning immunity."):format(eff.power * 100) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is moving freely.", "+Free Action" end,
	on_lose = function(self, err) return "#Target# is moving less freely.", "-Free Action" end,
	activate = function(self, eff)
		eff.stun = self:addTemporaryValue("stun_immune", eff.power)
		eff.daze = self:addTemporaryValue("daze_immune", eff.power)
		eff.pin = self:addTemporaryValue("pin_immune", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stun_immune", eff.stun)
		self:removeTemporaryValue("daze_immune", eff.daze)
		self:removeTemporaryValue("pin_immune", eff.pin)
	end,
}

newEffect{
	name = "BLOODLUST",
	desc = "Bloodlust",
	long_desc = function(self, eff) return ("The target is in a magical bloodlust, improving spellpower by %d."):format(eff.dur) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		local dur = new_eff.dur
		local max = math.floor(6 * self:getTalentLevel(self.T_BLOODLUST))
		local max_turn = math.floor(self:getTalentLevel(self.T_BLOODLUST))

		if old_eff.last_turn < game.turn then old_eff.used_this_turn = 0 end
		if old_eff.used_this_turn > max_turn then dur = 0 end

		old_eff.dur = math.min(old_eff.dur + dur, max)
		old_eff.last_turn = game.turn
		return old_eff
	end,
	activate = function(self, eff)
		eff.last_turn = game.turn
		eff.used_this_turn = 0
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ACID_SPLASH",
	desc = "Acid Splash",
	long_desc = function(self, eff) return ("The target has been splashed with acid, taking %0.2f acid damage per turn, reducing armour by %d and attack by %d."):format(eff.dam, eff.armor or 0, eff.atk) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is covered in acid!" end,
	on_lose = function(self, err) return "#Target# is free from the acid." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.dam)
	end,
	activate = function(self, eff)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
		if eff.armor then eff.armorid = self:addTemporaryValue("combat_armor", -eff.armor) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		if eff.armorid then self:removeTemporaryValue("combat_armor", eff.armorid) end
	end,
}

newEffect{
	name = "PACIFICATION_HEX",
	desc = "Pacification Hex",
	long_desc = function(self, eff) return ("The target is hexed, granting it %d%% chance each turn to be dazed for 3 turns."):format(eff.chance) end,
	type = "hex",
	status = "detrimental",
	parameters = {chance=10, power=10},
	on_gain = function(self, err) return "#Target# is hexed!", "+Pacification Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Pacification Hex" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if not self:hasEffect(self.EFF_DAZED) and rng.percent(eff.chance) then
			self:setEffect(self.EFF_DAZED, 3, {})
			if not self:checkHit(eff.power, self:combatSpellResist(), 0, 95, 15) then eff.dur = 0 end
		end
	end,
	activate = function(self, eff)
		self:setEffect(self.EFF_DAZED, 3, {})
	end,
}

newEffect{
	name = "BURNING_HEX",
	desc = "Burning Hex",
	long_desc = function(self, eff) return ("The target is hexed. Each time it uses an ability it takes %0.2f fire damage."):format(eff.dam) end,
	type = "hex",
	status = "detrimental",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# is hexed!", "+Burning Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Burning Hex" end,
}

newEffect{
	name = "EMPATHIC_HEX",
	desc = "Empathic Hex",
	long_desc = function(self, eff) return ("The target is hexed, creating an empathic bond with its victims. It takes %d%% feedback damage from all damage done."):format(eff.power) end,
	type = "hex",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is hexed.", "+Empathic Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Empathic hex" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("martyrdom", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("martyrdom", eff.tmpid)
	end,
}

newEffect{
	name = "DOMINATION_HEX",
	desc = "Domination Hex",
	long_desc = function(self, eff) return ("The target is hexed, temporarily changing its faction to %s."):format(engine.Faction.factions[eff.faction].name) end,
	type = "hex",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is hexed.", "+Domination Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Domination hex" end,
	activate = function(self, eff)
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
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
	name = "GLOOM_WEAKNESS",
	desc = "Gloom Weakness",
	long_desc = function(self, eff) return ("The gloom reduces the target's attack by %d and damage rating by %d."):format(eff.atk, eff.dam) end,
	type = "mental",
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#F53CBE##Target# is weakened by the gloom." end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer weakened." end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_weakness", 1))
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		self:removeTemporaryValue("combat_dam", eff.damid)
	end,
}

newEffect{
	name = "GLOOM_SLOW",
	desc = "Slowed by the gloom",
	long_desc = function(self, eff) return ("The gloom reduces the target's global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# moves reluctantly!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "GLOOM_STUNNED",
	desc = "Paralyzed by the gloom",
	long_desc = function(self, eff) return "The gloom has paralyzed the target, rendering it unable to act." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is paralyzed with fear!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Paralyzed" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "GLOOM_CONFUSED",
	desc = "Confused by the gloom",
	long_desc = function(self, eff) return ("The gloom has confused the target, making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is lost in despair!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "confusion")
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "STALKER",
	desc = "Stalking",
	long_desc = function(self, eff) return ("Stalking %s."):format(eff.target.name) end,
	type = "mental",
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		if not self.stalkee then
			self.stalkee = eff.target
			game.logSeen(self, "#F53CBE#%s is being stalked by %s!", eff.target.name:capitalize(), self.name)
		end
	end,
	deactivate = function(self, eff)
		self.stalkee = nil
		game.logSeen(self, "#F53CBE#%s is no longer being stalked by %s.", eff.target.name:capitalize(), self.name)
	end,
}

newEffect{
	name = "STALKED",
	desc = "Being Stalked",
	long_desc = function(self, eff) return "The target is being stalked." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		if not self.stalker then
			eff.particle = self:addParticles(Particles.new("stalked", 1))
			self.stalker = eff.target
		end
	end,
	deactivate = function(self, eff)
		self.stalker = nil
		if eff.particle then self:removeParticles(eff.particle) end
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
	name = "DOMINATED",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target is dominated, increasing damage done to it by its master by %d%%."):format(eff.dominatedDamMult * 100) end,
	type = "mental",
	status = "detrimental",
	on_gain = function(self, err) return "#F53CBE##Target# has been dominated!", "+Dominated" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer dominated.", "-Dominated" end,
	parameters = { dominatedDamMult = 1.3 },
	activate = function(self, eff)
		if not self.dominatedSource then
			self.dominatedSource = eff.dominatedSource
			self.dominatedDamMult = 1.3 or eff.dominatedDamMult
			eff.particle = self:addParticles(Particles.new("dominated", 1))
		end
	end,
	deactivate = function(self, eff)
		self.dominatedSource = nil
		self.dominatedDamMult = nil
		self:removeParticles(eff.particle)
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
	name = "RADIANT_FEAR",
	desc = "Radiating Fear",
	long_desc = function(self, eff) return "The target is frightening, pushing away other creatures." end,
	type = "mental",
	status = "beneficial",
	parameters = { knockback = 1, radius = 3 },
	on_gain = function(self, err) return "#F53CBE##Target# is surrounded by fear!", "+Radiant Fear" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer surrounded by fear.", "-Radiant Fear" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("radiant_fear", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		self:project({type="ball", radius=eff.radius, selffire=false}, self.x, self.y, function(xx, yy)
			local target = game.level.map(xx, yy, game.level.map.ACTOR)
			if target and target ~= self and target ~= eff.source and target:canBe("knockback") and (target.never_move or 0) ~= 1 then
				-- attempt to move target away from self
				local currentDistance = core.fov.distance(self.x, self.y, xx, yy)
				local bestDistance, bestX, bestY
				for i = 0, 8 do
					local x = xx + (i % 3) - 1
					local y = yy + math.floor((i % 9) / 3) - 1
					if x ~= xx or y ~= yy then
						local distance = core.fov.distance(self.x, self.y, x, y)
						if distance > currentDistance and (not bestDistance or distance > maxDistance) then
							-- this is a move away, see if it works
							if game.level.map:isBound(x, y) and not game.level.map:checkAllEntities(x, y, "block_move", target) then
								bestDistance, bestX, bestY = distance, x, y
								break
							end
						end
					end
				end

				if bestDistance then
					target:move(bestX, bestY, true)
					if not target.did_energy then target:useEnergy() end
				end
			end
		end)
	end,
}

newEffect{
	name = "INVIGORATED",
	desc = "Invigorated",
	long_desc = function(self, eff) return ("The target is invigorated by death, increasing global speed by %d%%."):format(eff.speed) end,
	type = "mental",
	status = "beneficial",
	parameters = { speed = 30, duration = 3 },
	on_gain = function(self, err) return nil, "+Invigorated" end,
	on_lose = function(self, err) return nil, "-Invigorated" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.speed * 0.01)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.min(old_eff.dur + new_eff.dur, 15)
		return old_eff
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
	name = "BLOOD_FURY",
	desc = "Bloodfury",
	long_desc = function(self, eff) return ("The target's blight and acid damage is increased by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {[DamageType.BLIGHT] = eff.power, [DamageType.ACID] = eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
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
	name = "PHOENIX_EGG",
	desc = "Reviving Phoenix",
	long_desc = function(self, eff) return "Target is being brought back to life." end,
	type = "magical",
	status = "beneficial",
	parameters = { life_regen = 25, mana_regen = -9.75, never_move = 1, silence = 1 },
	on_gain = function(self, err) return "#Target# is consumed in a burst of flame. All that remains is a fiery egg.", "+Phoenix" end,
	on_lose = function(self, err) return "#Target# bursts out from the egg.", "-Phoenix" end,
	activate = function(self, eff)
		self.display = "O"						             -- change the display of the phoenix to an egg, maybe later make it a fiery orb image
		eff.old_image = self.image
		self.image = "object/egg_dragons_egg_06_64.png"
		self:removeAllMOs()
		eff.life_regen = self:addTemporaryValue("life_regen", 25)	         -- gives it a 10 life regen, should I increase this?
		eff.mana_regen = self:addTemporaryValue("mana_regen", -9.75)          -- makes the mana regen realistic
		eff.never_move = self:addTemporaryValue("never_move", 1)	 -- egg form should not move
		eff.silence = self:addTemporaryValue("silence", 1)		          -- egg should not cast spells
		eff.combat = self.combat
		self.combat = nil						               -- egg shouldn't melee
	end,
	deactivate = function(self, eff)
		self.display = "B"
		self.image = eff.old_image
		self:removeAllMOs()
		self:removeTemporaryValue("life_regen", eff.life_regen)
		self:removeTemporaryValue("mana_regen", eff.mana_regen)
		self:removeTemporaryValue("never_move", eff.never_move)
		self:removeTemporaryValue("silence", eff.silence)
		self.combat = eff.combat
	end,
}

newEffect{
	name = "HURRICANE",
	desc = "Hurricane",
	long_desc = function(self, eff) return ("The target is in the center of a lightning hurricane, doing %0.2f to %0.2f lightning damage to itself and others around every turn."):format(eff.dam / 3, eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = { dam=10, radius=2 },
	on_gain = function(self, err) return "#Target# is caught inside a Hurricane.", "+Hurricane" end,
	on_lose = function(self, err) return "The Hurricane around #Target# dissipates.", "-Hurricane" end,
	on_timeout = function(self, eff)
		local tg = {type="ball", x=self.x, y=self.y, radius=eff.radius, selffire=false}
		local dam = eff.dam
		eff.src:project(tg, self.x, self.y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local x, y = self.x, self.y
		-- Lightning ball gets a special treatment to make it look neat
		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 16
		local angle_diff = 360 / nb_forks
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
			local tx = x + math.floor(math.cos(a) * tg.radius)
			local ty = y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=12, life=4})
		end

		game:playSoundNear(self, "talents/lightning")
	end,
}

newEffect{
	name = "RECALL",
	desc = "Recalling",
	long_desc = function(self, eff) return "The target is waiting to be recalled back to the worldmap." end,
	type = "magical",
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		if eff.allow_override or (self:canBe("worldport") and not self:attr("never_move")) then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level then
					game.logPlayer(self, "You are yanked out of this place!")
					game:changeLevel(1, eff.where or game.player.last_wilderness)
				end
			end)
		else
			game.logPlayer(self, "Space restabilizes around you.")
		end
	end,
}

newEffect{
	name = "TELEPORT_ANGOLWEN",
	desc = "Teleport: Angolwen",
	long_desc = function(self, eff) return "The target is waiting to be recalled back to Angolwen." end,
	type = "magical",
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk of teleporting to Angolwen.")
			return
		end

		if self:canBe("worldport") and not self:attr("never_move") then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level then
					game.logPlayer(self, "You are yanked out of this place!")
					game:changeLevel(1, "town-angolwen")
				end
			end)
		else
			game.logPlayer(self, "Space restabilizes around you.")
		end
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
	type = "magical",
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
	type = "magical",
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
	name = "PREMONITION_SHIELD",
	desc = "Premonition Shield",
	long_desc = function(self, eff) return ("Reduces %s damage received by %d%%."):format(DamageType:get(eff.damtype).name, eff.resist) end,
	type = "magical",
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target# casts a protective shield just in time!", "+Premonition Shield" end,
	on_lose = function(self, err) return "The protective shield of #Target# disappears.", "-Premonition Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[eff.damtype]=eff.resist})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "CORROSIVE_WORM",
	desc = "Corrosive Worm",
	long_desc = function(self, eff) return ("Target is infected with a corrosive worm doing %0.2f acid damage per turn."):format(eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target# is infected by a corrosive worm.", "+Corrosive Worm" end,
	on_lose = function(self, err) return "#Target# is free from the corrosive worm.", "-Corrosive Worm" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src or self, self.x, self.y, DamageType.ACID, eff.dam)
	end,
}

--Chronomancy Effects
newEffect{
	name = "DAMAGE_SMEARING",
	desc = "Damage Smearing",
	long_desc = function(self, eff) return ("Passes damage received in the present off onto the future self."):format(eff.power) end,
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The fabric of time alters around #target#.", "+Damage Smearing" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes.", "-Damage Smearing" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SMEARED",
	desc = "Smeared",
	long_desc = function(self, eff) return ("Damage received in the past is returned as %0.2f temporal damage per turn."):format(eff.power) end,
	type = "time",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is taking damage received in the past!", "+Smeared" end,
	on_lose = function(self, err) return "#Target# stops taking damage received in the past.", "-Smeared" end,
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
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "CRUSHED",
	desc = "Crushed",
	long_desc = function(self, eff) return ("Intense gravity that pins and deals %0.2f physical damage per turn."):format(eff.power) end,
	type = "magical",
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
	name = "WRAITHFORM",
	desc = "Wraithform",
	long_desc = function(self, eff) return ("Turn into a wraith, passing through walls (but not natural obstacles), granting %d defense and %d armour."):format(eff.def, eff.armor) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# turns into a wraith.", "+Wraithform" end,
	on_lose = function(self, err) return "#Target# returns to normal.", "-Wraithform" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("can_pass", {pass_wall=20})
		eff.defid = self:addTemporaryValue("combat_def", eff.def)
		eff.armid = self:addTemporaryValue("combat_armor", eff.armor)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("can_pass", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_armor", eff.armid)
	end,
}

newEffect{
	name = "EMPOWERED_HEALING",
	desc = "Empowered Healing",
	long_desc = function(self, eff) return ("Increases the effectiveness of all healing the target receives by %d%%."):format(eff.power * 100) end,
	type = "magical",
	status = "beneficial",
	parameters = { power = 0.1 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("healing_factor", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.tmpid)
	end,
}

newEffect{
	name = "PROVIDENCE",
	desc = "Providence",
	long_desc = function(self, eff) return ("The target is under protection and its life regeneration is boosted by %d."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {},
	on_timeout = function(self, eff)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "time" and e.type ~= "other" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "FEED",
	desc = "Feeding",
	long_desc = function(self, eff) return ("%s is feeding from %s."):format(self.name:capitalize(), eff.target.name) end,
	type = "mental",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.src = self

		-- hate
		if eff.hateGain and eff.hateGain > 0 then
			eff.hateGainId = self:addTemporaryValue("hate_regen", eff.hateGain)
		end

		-- health
		if eff.constitutionGain and eff.constitutionGain > 0 then
			eff.constitutionGainId = self:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_CON] = eff.constitutionGain,
			})
			eff.constitutionLossId = eff.target:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_CON] = -eff.constitutionGain,
			})
		end
		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			eff.lifeRegenGainId = self:addTemporaryValue("life_regen", eff.lifeRegenGain)
			eff.lifeRegenLossId = eff.target:addTemporaryValue("life_regen", -eff.lifeRegenGain)
		end

		-- power
		if eff.damageGain and eff.damageGain > 0 then
			eff.damageGainId = self:addTemporaryValue("inc_damage", {all=eff.damageGain})
			eff.damageLossId = eff.target:addTemporaryValue("inc_damage", {all=eff.damageLoss})
		end

		-- strengths
		if eff.resistGain and eff.resistGain > 0 then
			local gainList = {}
			local lossList = {}
			for id, resist in pairs(eff.target.resists) do
				if resist > 0 then
					local amount = eff.resistGain * 0.01 * resist
					gainList[id] = amount
					lossList[id] = -amount
				end
			end

			eff.resistGainId = self:addTemporaryValue("resists", gainList)
			eff.resistLossId = eff.target:addTemporaryValue("resists", lossList)
		end

		eff.target:setEffect(eff.target.EFF_FED_UPON, eff.dur, { src = eff.src, target = eff.target })
	end,
	deactivate = function(self, eff)
		-- hate
		if eff.hateGainId then self:removeTemporaryValue("hate_regen", eff.hateGainId) end

		-- health
		if eff.constitutionGainId then self:removeTemporaryValue("inc_stats", eff.constitutionGainId) end
		if eff.constitutionLossId then eff.target:removeTemporaryValue("inc_stats", eff.constitutionLossId) end
		if eff.lifeRegenGainId then self:removeTemporaryValue("life_regen", eff.lifeRegenGainId) end
		if eff.lifeRegenLossId then eff.target:removeTemporaryValue("life_regen", eff.lifeRegenLossId) end

		-- power
		if eff.damageGainId then self:removeTemporaryValue("inc_damage", eff.damageGainId) end
		if eff.damageLossId then eff.target:removeTemporaryValue("inc_damage", eff.damageLossId) end

		-- strengths
		if eff.resistGainId then self:removeTemporaryValue("resists", eff.resistGainId) end
		if eff.resistLossId then eff.target:removeTemporaryValue("resists", eff.resistLossId) end

		if eff.particles then
			-- remove old particle emitter
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end

		eff.target:removeEffect(eff.target.EFF_FED_UPON)
	end,
	updateFeed = function(self, eff)
		local source = eff.src
		local target = eff.target

		if source.dead or target.dead or not game.level:hasEntity(source) or not game.level:hasEntity(target) or not source:hasLOS(target.x, target.y) then
			source:removeEffect(source.EFF_FEED)
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end
			return
		end

		-- update particles position
		if not eff.particles or eff.particles.x ~= source.x or eff.particles.y ~= source.y or eff.particles.tx ~= target.x or eff.particles.ty ~= target.y then
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = target.x - source.x, target.y - source.y
			eff.particles = Particles.new("feed_hate", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = source.x
			eff.particles.y = source.y
			eff.particles.tx = target.x
			eff.particles.ty = target.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end
}

newEffect{
	name = "FED_UPON",
	desc = "Fed Upon",
	long_desc = function(self, eff) return ("%s is fed upon by %s."):format(self.name:capitalize(), eff.src.name) end,
	type = "mental",
	status = "detrimental",
	remove_on_clone = true,
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.target == self and eff.src:hasEffect(eff.src.EFF_FEED) then
			eff.src:removeEffect(eff.src.EFF_FEED)
		end
	end,
}

newEffect{
	name = "AGONY",
	desc = "Agony",
	long_desc = function(self, eff) return ("%s is writhing in agony, suffering from %d to %d damage over %d turns."):format(self.name:capitalize(), eff.damage / eff.duration, eff.damage, eff.duration) end,
	type = "mental",
	status = "detrimental",
	parameters = { damage=10, mindpower=10, range=10, minPercent=10 },
	on_gain = function(self, err) return "#Target# is writhing in agony!", "+Agony" end,
	on_lose = function(self, err) return "#Target# is no longer writhing in agony.", "-Agony" end,
	activate = function(self, eff)
		eff.power = 0
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		eff.turn = (eff.turn or 0) + 1

		local damage = math.floor(eff.damage * (eff.turn / eff.duration))
		if damage > 0 then
			DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, damage)
			game:playSoundNear(self, "talents/fire")
		end

		if self.dead then
			if eff.particle then self:removeParticles(eff.particle) end
			return
		end

		if eff.particle then self:removeParticles(eff.particle) end
		eff.particle = nil
		eff.particle = self:addParticles(Particles.new("agony", 1, { power = 10 * eff.turn / eff.duration }))
	end,
}

newEffect{
	name = "HATEFUL_WHISPER",
	desc = "Hateful Whisper",
	long_desc = function(self, eff) return ("%s has heard the hateful whisper."):format(self.name:capitalize()) end,
	type = "mental",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# has heard the hateful whisper!", "+Hateful Whisper" end,
	on_lose = function(self, err) return "#Target# no longer hears the hateful whisper.", "-Hateful Whisper" end,
	activate = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, eff.damage)

		if self.dead then
			-- only spread on activate if the target is dead
			self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			eff.duration = 0
		else
			eff.particle = self:addParticles(Particles.new("hateful_whisper", 1, { }))
		end

		game:playSoundNear(self, "talents/fire")
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		eff.duration = eff.duration - 1
		if eff.duration <= 0 then return false end

		if (eff.state or 0) == 0 then
			-- pause a turn before infecting others
			eff.state = 1
		elseif eff.state == 1 then
			self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			eff.state = 2
		end
	end,
	doSpread = function(self, eff)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, eff.jumpRange, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, game.level.map.ACTOR)
				if a and eff.source:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					if not a:hasEffect(a.EFF_HATEFUL_WHISPER) then
						targets[#targets+1] = a
					end
				end
			end
		end

		if #targets > 0 then
			local hitCount = 1
			if rng.percent(eff.extraJumpChance or 0) then hitCount = hitCount + 1 end

			-- Randomly take targets
			for i = 1, hitCount do
				local target = rng.tableRemove(targets)
				target:setEffect(target.EFF_HATEFUL_WHISPER, eff.duration, {
					source = eff.source,
					duration = eff.duration,
					damage = eff.damage,
					mindpower = eff.mindpower,
					jumpRange = eff.jumpRange,
					extraJumpChance = eff.extraJumpChance
				})

				game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })

				if #targets == 0 then break end
			end
		end
	end,
}

newEffect{
	name = "MADNESS_SLOW",
	desc = "Slowed by madness",
	long_desc = function(self, eff) return ("Madness reduces the target's global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# slows in the grip of madness!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the madness.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "MADNESS_STUNNED",
	desc = "Paralyzed by madness",
	long_desc = function(self, eff) return "Madness has paralyzed the target, rendering it unable to act." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is paralyzed by madness!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Paralyzed" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "MADNESS_CONFUSED",
	desc = "Confused by madness",
	long_desc = function(self, eff) return ("Madness has confused the target, making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is lost in madness!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "confusion")
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "TOTALITY",
	desc = "Totality",
	long_desc = function(self, eff) return ("The target's light and darkness spell penetration has been increased by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.penet = self:addTemporaryValue("resists_pen", {
			[DamageType.DARKNESS] = eff.power,
			[DamageType.LIGHT] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists_pen", eff.penet)
	end,
}

-- Circles

newEffect{
	name = "SANCTITY",
	desc = "Sanctity",
	long_desc = function(self, eff) return ("The target is protected from silence effects.") end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.silence = self:addTemporaryValue("silence_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence_immune", eff.silence)
	end,
}

newEffect{
	name = "SHIFTING_SHADOWS",
	desc = "Shifting Shadows",
	long_desc = function(self, eff) return ("The target's defense is increased by %d."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		eff.defense = self:addTemporaryValue("combat_def", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defense)
	end,
}

newEffect{
	name = "BLAZING_LIGHT",
	desc = "Blazing Light",
	long_desc = function(self, eff) return ("The target is gaining %d positive energy each turn."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		eff.pos = self:addTemporaryValue("positive_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("positive_regen", eff.pos)
	end,
}

newEffect{
	name = "WARDING",
	desc = "Warding",
	long_desc = function(self, eff) return ("Projectiles aimed at the target are slowed by %d%%."):format (eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		eff.ward = self:addTemporaryValue("slow_projectiles", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("slow_projectiles", eff.ward)
	end,
}

newEffect{
	name = "QUICKNESS",
	desc = "Quick",
	long_desc = function(self, eff) return ("Increases run speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Quick" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Quick" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("movement_speed", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
	end,
}
newEffect{
	name = "PSIFRENZY",
	desc = "Frenzied Psi-fighting",
	long_desc = function(self, eff) return ("Causes telekinetically-wielded weapons to hit up to %d targets each turn."):format(eff.power) end,
	type = "mental",
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# enters a frenzy!", "+Frenzy" end,
	on_lose = function(self, err) return "#Target# is no longer frenzied.", "-Frenzy" end,
}

newEffect{
	name = "KINSPIKE_SHIELD",
	desc = "Spiked Kinetic Shield",
	long_desc = function(self, eff) return ("The target erects a powerful kinetic shield capable of absorbing %d/%d physical or acid damage before it crumbles."):format(self.kinspike_shield_absorb, eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful kinetic shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful kinetic shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("kinspike_shield", eff.power)
		self.kinspike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("kinspike_shield", eff.tmpid)
		self.kinspike_shield_absorb = nil
	end,
}
newEffect{
	name = "THERMSPIKE_SHIELD",
	desc = "Spiked Thermal Shield",
	long_desc = function(self, eff) return ("The target erects a powerful thermal shield capable of absorbing %d/%d thermal damage before it crumbles."):format(self.thermspike_shield_absorb, eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful thermal shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful thermal shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("thermspike_shield", eff.power)
		self.thermspike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("thermspike_shield", eff.tmpid)
		self.thermspike_shield_absorb = nil
	end,
}
newEffect{
	name = "CHARGESPIKE_SHIELD",
	desc = "Spiked Charged Shield",
	long_desc = function(self, eff) return ("The target erects a powerful charged shield capable of absorbing %d/%d lightning or blight damage before it crumbles."):format(self.chargespike_shield_absorb, eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful charged shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful charged shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("chargespike_shield", eff.power)
		self.chargespike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("chargespike_shield", eff.tmpid)
		self.chargespike_shield_absorb = nil
	end,
}

newEffect{
	name = "CONTROL",
	desc = "Perfect control",
	long_desc = function(self, eff) return ("The target's combat attack and crit chance are improved by %d and %d%%, respectively."):format(eff.power, 0.5*eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.attack = self:addTemporaryValue("combat_atk", eff.power)
		eff.crit = self:addTemporaryValue("combat_physcrit", 0.5*eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.attack)
		self:removeTemporaryValue("combat_physcrit", eff.crit)
	end,
}

newEffect{
	name = "PSI_REGEN",
	desc = "Matter is energy",
	long_desc = function(self, eff) return ("The gem's matter gradually transforms, granting %0.2f energy per turn."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "Energy starts pouring from the gem into #Target#.", "+Energy" end,
	on_lose = function(self, err) return "The flow of energy from #Target#'s gem ceases.", "-Energy" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("psi_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("psi_regen", eff.tmpid)
	end,
}

newEffect{
	name = "MASTERFUL_TELEKINETIC_ARCHERY",
	desc = "Telekinetic Archery",
	long_desc = function(self, eff) return ("Your telekinetically-wielded bow automatically attacks the nearest target each turn.") end,
	type = "mental",
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# enters a telekinetic archer's trance!", "+Telekinetic archery" end,
	on_lose = function(self, err) return "#Target# is no longer in a telekinetic archer's trance.", "-Telekinetic archery" end,
}

newEffect{
	name = "PSIONIC_BIND",
	desc = "Immobilized",
	long_desc = function(self, eff) return "Immobilized by telekinetic forces." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is bound by telekinetic forces!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# shakes free of the telekinetic binding", "-Paralyzed" end,
	activate = function(self, eff)
		--eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
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
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is being crushed.", "+Imploding" end,
	on_lose = function(self, err) return "#Target# shakes off the crushing forces.", "-Imploding" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.5)
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "TURN_BACK_THE_CLOCK",
	desc = "Turn Back the Clock",
	long_desc = function(self, eff) return ("The target has been returned to a much younger state, reducing all its stats by %d."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# is returned to a much younger state!", "+Turn Back the Clock" end,
	on_lose = function(self, err) return "#Target# has regained its natural age.", "-Turn Back the Clock" end,
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats", {
				[Stats.STAT_STR] = -eff.power,
				[Stats.STAT_DEX] = -eff.power,
				[Stats.STAT_CON] = -eff.power,
				[Stats.STAT_MAG] = -eff.power,
				[Stats.STAT_WIL] = -eff.power,
				[Stats.STAT_CUN] = -eff.power,
		})
		-- Make sure the target doesn't have more life then it should
		if self.life > self.max_life then
			self.life = self.max_life
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
	end,
}

newEffect{
	name = "WASTING",
	desc = "Wasting",
	long_desc = function(self, eff) return ("The target is wasting away, taking %0.2f temporal damage per turn."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is wasting away!", "+Wasting" end,
	on_lose = function(self, err) return "#Target# stops wasting away.", "-Wasting" end,
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
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "PRESCIENCE",
	desc = "Prescience",
	long_desc = function(self, eff) return ("The target's awareness is fully in the present, increasing both physical and spell critical hit chance by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target#'s awareness returns to normal." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("combat_physcrit", eff.power)
		eff.sid = self:addTemporaryValue("combat_spellcrit", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physcrit", eff.pid)
		self:removeTemporaryValue("combat_spellcrit", eff.sid)
	end,
}

newEffect{
	name = "FORESIGHT",
	desc = "Foresight",
	long_desc = function(self, eff) return ("The target has glimpsed the future, improving all resistances by %d%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#Target# seems to know what's about to happen." end,
	on_lose = function(self, err) return "#Target# hasn't looked this far into the future." end,
	activate = function(self, eff)
		eff.resistsid = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsid)
	end,
}

-- Borrowed Time and the Borrowed Time stun effect
newEffect{
	name = "BORROWED_TIME",
	desc = "Borrowed Time",
	long_desc = function(self, eff) return ("The target's global speed has been increased by %d%%."):format(100) end,
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:setEffect(self.EFF_TEMPORAL_STUN, eff.power, {})
	end,
}

newEffect{
	name = "TEMPORAL_STUN",
	desc = "Temporal Stun",
	long_desc = function(self, eff) return "The target is paralyzed, preventing any actions." end,
	type = "time",  -- Time so very little can remove it.
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is paralyzed!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# is not paralyzed anymore.", "-Paralyzed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("time_stun", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "time_stun")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("time_stun", eff.tmpid)
	end,
}

newEffect{
	name = "INVIGORATE",
	desc = "Invigorate",
	long_desc = function(self, eff) return ("The target is regaining %d stamina per turn."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {power = 10},
	on_gain = function(self, err) return "#Target# is recovering stamina.", "+Invigorate" end,
	on_lose = function(self, err) return "#Target# is no longer recovering stamina.", "-Invigorate" end,
	activate = function(self, eff)
		self.stamina_regen = self.stamina_regen + eff.power
	end,
	deactivate = function(self, eff)
		self.stamina_regen = self.stamina_regen - eff.power
	end,
}

newEffect{
	name = "GATHER_THE_THREADS",
	desc = "Gather the Threads",
	long_desc = function(self, eff) return ("The target will inflict %d%% more damage on its next attack plus an additional %d%% for each turn spent gathering threads beyond the first."):
	format(eff.power + (eff.power / 5), eff.power/5) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is gathering energy from other timelines.", "+Gather the Threads" end,
	on_lose = function(self, err) return "#Target# is no longer manipulating the timestream.", "-Gather the Threads" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_damage", old_eff.tmpid)
		old_eff.cur_power = (old_eff.cur_power + new_eff.power)
		old_eff.tmpid = self:addTemporaryValue("inc_damage", {all = old_eff.cur_power})

		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local threads = eff.power / 5
		self:setEffect(self.EFF_GATHER_THE_THREADS, 1, {power=threads})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.particle = self:addParticles(Particles.new("arcane_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "PRECOGNITION",
	desc = "Precognition",
	long_desc = function(self, eff) return "You walk into the future; when the effect ends, if you are not dead, you are brought back to the past." end,
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		game:onTickEnd(function()
			game:chronoClone("precognition")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			if not game:chronoRestore("precognition", true) then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the spacetime continuum to a previous state!")
			game.player.tmp[self.EFF_PRECOGNITION] = nil
			if game._chronoworlds then game._chronoworlds = nil end
		end)
	end,
}

newEffect{
	name = "SEE_THREADS",
	desc = "See the Threads",
	long_desc = function(self, eff) return ("You walk three different timelines, choosing the one you prefer at the end (current timeline: %d)."):format(eff.thread) end,
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.thread = 1
		eff.max_dur = eff.dur
		game:onTickEnd(function()
			game:chronoClone("see_threads_base")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#The see the threads spell fizzles and cancels, leaving you in this timeline.")
				return
			end

			if eff.thread < 3 then
				local worlds = game._chronoworlds

				-- Clone but not the subworlds
				game._chronoworlds = nil
				local clone = game:chronoClone()

				-- Restore the base world and resave it
				game._chronoworlds = worlds
				game:chronoRestore("see_threads_base", true)

				-- Setup next thread
				local eff = game.player:hasEffect(game.player.EFF_SEE_THREADS)
				eff.thread = eff.thread + 1
				game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the space time continuum to the start of the time threads!")

				game._chronoworlds = worlds
				game:chronoClone("see_threads_base")

				-- Add the previous thread
				game._chronoworlds["see_threads_"..(eff.thread-1)] = clone
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
				return
			else
				game._chronoworlds.see_threads_base = nil
				local chat = Chat.new("chronomancy-see-threads", {name="See the Threads"}, self, {turns=eff.max_dur})
				chat:invoke()
			end
		end)
	end,
}

newEffect{
	name = "IMMINENT_PARADOX_CLONE",
	desc = "Imminent Paradox Clone",
	long_desc = function(self, eff) return "When the effect expires you'll be pulled into the past." end,
	type = "time",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
			game:onTickEnd(function()
			game:chronoClone("paradox_past")
		end)
	end,
	deactivate = function(self, eff)
		local t = self:getTalentFromId(self.T_PARADOX_CLONE)
		local base = t.getDuration(self, t) - 2
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#You've altered your destiny and will not be pulled into the past.")
				return
			end

			local worlds = game._chronoworlds
			-- save the players health so we can reload it
			local oldplayer = game.player

			-- Clone but not the subworlds
			game._chronoworlds = nil
			local clone = game:chronoClone()
			game._chronoworlds = worlds

			-- Move back in time, but keep the paradox_future world stored
			game:chronoRestore("paradox_past", true)
			game._chronoworlds["paradox_future"] = clone
			game.logPlayer(self, "#LIGHT_BLUE#You've been pulled into the past!")
			-- pass health and resources into the new timeline
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end

			-- Hack to remove the IMMINENT_PARADOX_CLONE effect in the past
			-- Note that we have to use game.player now since self refers to self from the future!
			game.player.tmp[self.EFF_IMMINENT_PARADOX_CLONE] = nil

			-- Setup the return effect
			game.player:setEffect(self.EFF_PARADOX_CLONE, base, {})
		end)
	end,
}

newEffect{
	name = "PARADOX_CLONE",
	desc = "Paradox Clone",
	long_desc = function(self, eff) return "You've been pulled into the past." end,
	type = "time",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		-- save the players rescources so we can reload it
		local oldplayer = game.player
		game:onTickEnd(function()
			game:chronoRestore("paradox_future")
			-- Reload the player's health and resources
			game.logPlayer(game.player, "#LIGHT_BLUE#You've been returned to the present!")
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end
		end)
	end,
}

newEffect{
	name = "FLAWED_DESIGN",
	desc = "Flawed Design",
	long_desc = function(self, eff) return ("The target's past has been altered, reducing all its resistances by %d%%."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is flawed.", "+Flawed" end,
	on_lose = function(self, err) return "#Target# is no longer flawed.", "-Flawed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
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

newEffect{
	name = "SPACETIME_TUNING",
	desc = "Spacetime Tuning",
	long_desc = function(self, eff) return "The target is retuning the fabric of spacetime; any damage will stop it." end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_timeout = function(self, eff)
		local t = self:getTalentFromId(self.T_SPACETIME_TUNING)
		local anomaly = t.getAnomaly(self, t)

		-- first check for anomaly
		if rng.percent(anomaly) and not game.zone.no_anomalies and eff.power > 0 then
			-- Random anomaly
			local ts = {}
			for id, t in pairs(self.talents_def) do
				if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
			end
			if not silent then game.logPlayer(self, "You lose control and unleash an anomaly!") end
			self:forceUseTalent(rng.table(ts), {ignore_energy=true})
			-- cancel tuning
			self:removeEffect(self.EFF_SPACETIME_TUNING)
		-- prevent abusive shananigans
		elseif self.paradox > math.max(self:getWil() * 20, 500) and eff.power > 0 then
			game.logPlayer(self, "Space time resists your will, you can raise Paradox no further.")
			self:removeEffect(self.EFF_SPACETIME_TUNING)
		else
			self:incParadox(eff.power)
		end

	end,
	activate = function(self, eff)
		-- energy gets used here instead of in the talent since the talent will use it when the dialog box pops up and mess with our daze
		self:useEnergy()
		-- set daze
		eff.tmpid = self:addTemporaryValue("dazed", 1)
	end,
	deactivate = function(self, eff)
		local modifier = self:paradoxChanceModifier()
		local _, failure = self:paradoxFailChance()
		local _, anomaly = self:paradoxAnomalyChance()
		local _, backfire = self:paradoxBackfireChance()
		self:removeTemporaryValue("dazed", eff.tmpid)
		game.logPlayer(self, "Your current failure chance is %d%%, your current anomaly chance is %d%%, and your current backfire chance is %d%%.", failure, anomaly, backfire)
	end,
}

newEffect{
	name = "FORESIGHT",
	desc = "Foresight",
	long_desc = function(self, eff) return ("The target has peered into the future and will ignore all damage from the next attack."):format() end,
	type = "magical",
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "MILITANT_MIND",
	desc = "Militant Mind",
	long_desc = function(self, eff) return ("Increases physical power, spellpower and mindpower by %d."):format(eff.power) end,
	type = "other",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
}

newEffect{
	name = "WEAKENED_MIND",
	desc = "Weakened Mind",
	long_desc = function(self, eff) return ("Decreases mind save by %d."):format(eff.power) end,
	type = "mental",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.mindid = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mindid)
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
		eff.dur = self:updateEffectDuration(eff.dur, "silence")
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
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
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
	name = "MANAWORM",
	desc = "Manaworm",
	long_desc = function(self, eff) return ("The target is infected by a manaworm, draining %0.2f mana per turns and releasing it as arcane damage to the target."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target# is infected by a manaworm!", "+Manaworm" end,
	on_lose = function(self, err) return "#Target# is no longer infected.", "-Manaworm" end,
	on_timeout = function(self, eff)
		local dam = eff.power
		if dam > self:getMana() then dam = self:getMana() end
		self:incMana(-dam)
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, dam)
	end,
}

newEffect{
	name = "SEVER_LIFELINE",
	desc = "Sever Lifeline",
	long_desc = function(self, eff) return ("The target lifeline is being cut. When the effect ends %0.2f temporal damage will hit the target."):format(eff.power) end,
	type = "time",
	status = "detrimental",
	parameters = {power=10000},
	on_gain = function(self, err) return "#Target# lifeline is being severed!", "+Sever Lifeline" end,
	deactivate = function(self, eff)
		if not eff.src or eff.src.dead then return end
		if not eff.src:hasLOS(self.x, self.y) then return end
		if eff.dur >= 1 then return end
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "SURGE_OF_UNDEATH",
	desc = "Surge of Undeath",
	long_desc = function(self, eff) return ("Increases the target combat power, spellpower, accuracy by %d, armour penetration by %d and critical chances by %d."):format(eff.power, eff.apr, eff.crit) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10, crit=10, apr=10 },
	on_gain = function(self, err) return "#Target# is engulfed in dark energies.", "+Undeath Surge" end,
	on_lose = function(self, err) return "#Target# seems less powerful.", "-Undeath Surge" end,
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.accid = self:addTemporaryValue("combat_attack", eff.power)
		eff.aprid = self:addTemporaryValue("combat_apr", eff.apr)
		eff.pcritid = self:addTemporaryValue("combat_physcrit", eff.crit)
		eff.scritid = self:addTemporaryValue("combat_spellcrit", eff.crit)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_attack", eff.accid)
		self:removeTemporaryValue("combat_apr", eff.aprid)
		self:removeTemporaryValue("combat_physcrit", eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", eff.scritid)
	end,
}

newEffect{
	name = "BONE_SHIELD",
	desc = "Bone Shield",
	long_desc = function(self, eff) return ("Fully protects from %d damaging actions."):format(#eff.particles) end,
	type = "magical",
	status = "beneficial",
	parameters = { nb=3 },
	on_gain = function(self, err) return "#Target# protected by flying bones.", "+Bone Shield" end,
	on_lose = function(self, err) return "#Target# flying bones crumble.", "-Bone Shield" end,
	absorb = function(self, eff)
		game.logPlayer(self, "Your bone shield absorbs the damage!")
		local pid = table.remove(eff.particles)
		if pid then self:removeParticles(pid) end
		if #eff.particles <= 0 then
			eff.dur = 0
		end
	end,
	activate = function(self, eff)
		local nb = eff.nb
		local ps = {}
		for i = 1, nb do ps[#ps+1] = self:addParticles(Particles.new("bone_shield", 1)) end
		eff.particles = ps
	end,
	deactivate = function(self, eff)
		for i, particle in ipairs(eff.particles) do self:removeParticles(particle) end
	end,
}

newEffect{
	name = "SPACTIME_STABILITY",
	desc = "Spacetime Stability",
	long_desc = function(self, eff) return "Chronomancy spells cast by the target will not fail, backfire, or cause an anomaly." end,
	type = "time",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "Spacetime has stabilized around #Target#.", "+Spactime Stability" end,
	on_lose = function(self, err) return "The fabric of spacetime around #Target# has returned to normal.", "-Spacetime Stability" end,
	activate = function(self, eff)
		self:attr("no_paradox_fail", 1)
	end,
	deactivate = function(self, eff)
		self:attr("no_paradox_fail", -1)
	end,
}

newEffect{
	name = "REDUX",
	desc = "Redux",
	long_desc = function(self, eff) return "The next activated chronomancy talent that the target uses will be cast twice." end,
	type = "magical",
	status = "beneficial",
	parameters = { power=1},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "TEMPORAL_DESTABILIZATION",
	desc = "Temporal Destabilization",
	long_desc = function(self, eff) return ("Target is destabilized and suffering %0.2f temporal damage per turn.  If it dies with this effect active it will explode."):format(eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target# is unstable.", "+Temporal Destabilization" end,
	on_lose = function(self, err) return "#Target# has regained stability.", "-Temporal Destabilization" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.TEMPORAL).projector(eff.src or self, self.x, self.y, DamageType.TEMPORAL, eff.dam)
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("destabilized", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "Haste",
	desc = "Haste",
	long_desc = function(self, eff) return ("Increases global action speed by %d%% and casting speed by %d%%."):format(eff.power * 100, eff.power * 50) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Haste" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Haste" end,
	activate = function(self, eff)
		eff.glbid = self:addTemporaryValue("global_speed_add", eff.power)
		eff.spdid = self:addTemporaryValue("combat_spellspeed", eff.power/2)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.glbid)
		self:removeTemporaryValue("combat_spellspeed", eff.spdid)
	end,
}

newEffect{
	name = "CEASE_TO_EXIST",
	desc = "Cease to Exist",
	long_desc = function(self, eff) return ("The target is being removed from the timeline and is suffering %d temporal damage per turn."):format(eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target# is being removed from the timeline.", "+Cease to Exist" end,
	activate = function(self, eff)
		eff.resists = self:addTemporaryValue("resists", { all = -eff.power})
	end,
	deactivate = function(self, eff)
		if game._chronoworlds then
			game._chronoworlds = nil
		end
		self:removeTemporaryValue("resists", eff.resists)
	end,
}

newEffect{
	name = "FADE_FROM_TIME",
	desc = "Fade From Time",
	long_desc = function(self, eff) return ("The target is partially removed from the timeline, reducing all damage dealt by %d%%, all damage recieved by %d%%, and the duration of all detrimental effects by %d%%."):
	format(eff.dur + 1, eff.cur_power or eff.power, eff.cur_power or eff.power) end,
	type = "time",  -- so no timeless shinanigans or removal by body reversion
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# has partially removed itself from the timeline.", "+Fade From Time" end,
	on_lose = function(self, err) return "#Target# has returned fully to the timeline.", "-Fade From Time" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_damage", old_eff.dmgid)
		self:removeTemporaryValue("resists", old_eff.rstid)
		old_eff.cur_power = (new_eff.power)
		old_eff.dmgid = self:addTemporaryValue("inc_damage", {all = - old_eff.dur})
		old_eff.rstid = self:addTemporaryValue("resists", {all = old_eff.cur_power})

		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local current = eff.power * eff.dur/10
		self:setEffect(self.EFF_FADE_FROM_TIME, 1, {power = current})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.rstid = self:addTemporaryValue("resists", { all = eff.power})
		eff.dmgid = self:addTemporaryValue("inc_damage", {all = -10})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.rstid)
		self:removeTemporaryValue("inc_damage", eff.dmgid)
	end,
}

newEffect{
	name = "IMPENDING_DOOM",
	desc = "Impending Doom",
	long_desc = function(self, eff) return ("The target's final doom is drawing near, preventing all forms of healing and dealing %0.2f arcane damage per turn. The effect will stop if the caster dies."):format(eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is doomed!", "+Doomed" end,
	on_lose = function(self, err) return "#Target# is freed from the impending doom.", "-Doomed" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("no_healing", 1)
	end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then return true end
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_healing", eff.healid)
	end,
}

newEffect{
	name = "RIGOR_MORTIS",
	desc = "Rigor Mortis",
	long_desc = function(self, eff) return ("The target takes %d%% more damage from necrotic minions."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {power=20},
	on_gain = function(self, err) return "#Target# feels death coming!", "+Rigor Mortis" end,
	on_lose = function(self, err) return "#Target# is freed from the rigor mortis.", "-Rigor Mortis" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_necrotic_minions", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_necrotic_minions", eff.tmpid)
	end,
}

newEffect{
	name = "SHADOW_VEIL",
	desc = "Shadow Veil",
	long_desc = function(self, eff) return ("You veil yourself in shadows and let them control you. While in the veil you become immune to status effects, gain %d%% all damage reduction and each turn you blink to a nearby foe, hitting it for %d%% darkness weapon damage. While this goes on you can not be stopped unless you are killed and can not control you character."):format(eff.res, eff.dam * 100) end,
	type = "time",
	status = "beneficial",
	parameters = { res=10, dam=1.5 },
	on_gain = function(self, err) return "#Target# is covered in a veil of shadows!", "+Assail" end,
	on_lose = function(self, err) return "#Target# is no longer covered by shadows.", "-Assail" end,
	activate = function(self, eff)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
	end,
	on_timeout = function(self, eff)
		-- Choose a target in FOV
		local acts = {}
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and not act.dead then
				local sx, sy = util.findFreeGrid(act.x, act.y, 1, true, {[engine.Map.ACTOR]=true})
				if sx then acts[#acts+1] = {act, sx, sy} end
			end
		end
		if #acts == 0 then return end

		act = rng.table(acts)
		self:move(act[2], act[3], true)
		game.level.map:particleEmitter(act[2], act[3], 1, "dark")
		self:attackTarget(act[1], DamageType.DARKNESS, eff.dam) -- Attack *and* use energy
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self:removeTemporaryValue("resists", eff.resid)
	end,
}

newEffect{
	name = "ZERO_GRAVITY",
	desc = "Zero Gravity",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("There is no gravity here, you float in the air. Movement three times as slow, any melee or archery blows have a chance to knockback. Maximum encumberance is greatly increased.") end,
	decrease = 0, no_remove = true,
	type = "spacetime",
	status = "detrimental",
	cancel_on_level_change = true,
	parameters = {},
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.encumb = self:addTemporaryValue("max_encumber", self:getMaxEncumbrance() * 20),
		self:checkEncumbrance()
		game.logPlayer(self, "#LIGHT_BLUE#You enter a zero gravity zone, beware!")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_encumber", eff.encumb)
		self:checkEncumbrance()
	end,
}

newEffect{
	name = "VOID_ECHOES",
	desc = "Void Echoes",
	long_desc = function(self, eff) return ("The target is seeing echoes from the void and will take %0.2f mind damage as well as some resource damage each turn it fails a mental save."):format(eff.power) end,
	type = "mental",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is being driven mad by the void.", "+Void Echoes" end,
	on_lose = function(self, err) return "#Target# has survived the void madness.", "-Void Echoes" end,
	on_timeout = function(self, eff)
		local drain = DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power) / 2
		self:incMana(-drain)
		self:incVim(-drain * 0.5)
		self:incPositive(-drain * 0.25)
		self:incNegative(-drain * 0.25)
		self:incStamina(-drain * 0.65)
		self:incHate(-drain * 0.05)
		self:incPsi(-drain * 0.2)
	end,
}

newEffect{
	name = "WAKING_NIGHTMARE",
	desc = "Waking Nightmare",
	long_desc = function(self, eff) return ("The target is lost in a waking nightmare that deals %0.2f darkness damage each turn and has a %d%% chance to cause a random effect detrimental."):format(eff.dam, eff.chance) end,
	type = "magical",
	status = "detrimental",
	parameters = { chance=10, dam = 10 },
	on_gain = function(self, err) return "#Target# is lost in a waking nightmare.", "+Waking Nightmare" end,
	on_lose = function(self, err) return "#Target# is free from the nightmare.", "-Waking Nightmare" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
		if rng.percent(eff.chance or 0) then
			-- Pull random effect
			local chance = rng.range(1, 3)
			if chance == 1 then
				if self:canBe("blind") then
					self:setEffect(self.EFF_BLINDED, 3, {})
				end
			elseif chance == 2 then
				if self:canBe("stun") then
					self:setEffect(self.EFF_STUNNED, 3, {})
				end
			elseif chance == 3 then
				if self:canBe("confusion") then
					self:setEffect(self.EFF_CONFUSED, 3, {power=50})
				end
			end
			game.logSeen(self, "%s succumbs to the nightmare!", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "ABYSSAL_SHROUD",
	desc = "Abyssal Shroud",
	long_desc = function(self, eff) return ("The target's lite radius has been reduced by %d and it's darkness resistance by %d%%."):format(eff.lite, eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {power=20},
	on_gain = function(self, err) return "#Target# feels closer to the abyss!", "+Abyssal Shroud" end,
	on_lose = function(self, err) return "#Target# is free from the abyss.", "-Abyssal Shroud" end,
	activate = function(self, eff)
		eff.liteid = self:addTemporaryValue("lite", -eff.lite)
		eff.darkid = self:addTemporaryValue("resists", { [DamageType.DARKNESS] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("lite", eff.liteid)
		self:removeTemporaryValue("resists", eff.darkid)
	end,
}

newEffect{
	name = "INNER_DEMONS",
	desc = "Inner Demons",
	long_desc = function(self, eff) return ("The target is plagued by inner demons and each turn there's a %d%% chance that one will appear.  If the caster is killed or the target resists setting his demons loose the effect will end early."):format(eff.chance) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is plagued by inner demons!", "+Inner Demons" end,
	on_lose = function(self, err) return "#Target# is freed from the demons.", "-Inner Demons" end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then eff.dur = 0 return true end
		if rng.percent(eff.chance or 0) then
			if self:checkHit(eff.src:combatSpellpower(), self:combatSpellResist(), 0, 95, 5) then
				local t = eff.src:getTalentFromId(eff.src.T_INNER_DEMONS)
				t.summon_inner_demons(eff.src, self, t)
			else
				eff.dur = 0
			end
		end
	end,
}

newEffect{
	name = "WORM_ROT",
	desc = "Worm Rot",
	long_desc = function(self, eff) return ("The target is infected with carrion worm larvae.  Each turn it will lose one beneficial physical effect and %0.2f blight and acid damage will be inflicted.\nAfter five turns the disease will inflict %0.2f blight damage and spawn a carrion worm mass."):format(eff.dam, eff.burst) end,
	type = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by a terrible worm rot!" end,
	on_lose = function(self, err) return "#Target# is free from the worm rot." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		self.worm_rot_timer = self.worm_rot_timer - 1

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
		if self.worm_rot_timer == 0 then
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.burst, {from_disease=true})
			local t = eff.src:getTalentFromId(eff.src.T_WORM_ROT)
			t.spawn_carrion_worm(eff.src, self, t)
			game.logSeen(self, "#LIGHT_RED#A carrion worm mass bursts out of %s!", self.name:capitalize())
			self:removeEffect(self.EFF_WORM_ROT)
		end
	end,
	activate = function(self, eff)
		self.worm_rot_timer = 5
	end,
	deactivate = function(self, eff)
		self.worm_rot_timer = nil
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
			game.logSeen(self, "%s dies when it's frenzy ends!", self.name:capitalize())
			self:die(self)
		end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("combat_physcrit", eff.critid)
		self:removeTemporaryValue("die_at", eff.dieatid)
	end,
}

