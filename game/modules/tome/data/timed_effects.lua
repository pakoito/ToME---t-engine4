-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

newEffect{
	name = "CUT",
	desc = "Bleeding",
	long_desc = function(self, eff) return ("Huge cut that bleeds blood, doing %0.2f physical damage per turn."):format(eff.power) end,
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
	name = "MANAFLOW",
	desc = "Manaflow",
	long_desc = function(self, eff) return ("The mana surge engulfs the target, regenerating %0.2f mana per turn."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts to surge mana.", "+Manaflow" end,
	on_lose = function(self, err) return "#Target# stops surging mana.", "-Manaflow" end,
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
	on_gain = function(self, err) return "#Target# starts to regenerating health quickly.", "+Regen" end,
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
	long_desc = function(self, eff) return ("The target is on fire, doing %0.2f fire damage per turn."):format(eff.power) end,
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
	long_desc = function(self, eff) return ("The target is poisoned, doing %0.2f nature damage per turn."):format(eff.power) end,
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
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
	end,
}

newEffect{
	name = "FROZEN",
	desc = "Frozen",
	long_desc = function(self, eff) return "The target is frozen in ice, completly unable to act." end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is frozen!", "+Frozen" end,
	on_lose = function(self, err) return "#Target# warms up.", "-Frozen" end,
	activate = function(self, eff)
		-- Change color
		eff.old_r = self.color_r
		eff.old_g = self.color_g
		eff.old_b = self.color_b
		self.color_r = 0
		self.color_g = 255
		self.color_b = 155
		game.level.map:updateMap(self.x, self.y)

		eff.tmpid = self:addTemporaryValue("encased_in_ice", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.dur = self:updateEffectDuration(eff.dur, "freeze")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("encased_in_ice", eff.tmpid)
		self:removeTemporaryValue("frozen", eff.frozid)
		self.color_r = eff.old_r
		self.color_g = eff.old_g
		self.color_b = eff.old_b
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
	long_desc = function(self, eff) return "The target is has been turned to stone, making it subject to shattering and improving physical(+20%), fire(+80%) and lightning(+50%) resistances." end,
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
	long_desc = function(self, eff) return ("The target is on fire, doing %0.2f fire damage per turn and making it unable to act."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned by the burning flame!", "+Burning Shock" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Burning Shock" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		-- Start the stun counter only if this is the first stun
		if self.stunned == 1 then self.stunned_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		if not self:attr("stunned") then self.stunned_counter = nil end
	end,
}

newEffect{
	name = "STUNNED",
	desc = "Stunned",
	long_desc = function(self, eff) return "The target is stunned, preventing any actions." end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Stunned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		-- Start the stun counter only if this is the first stun
		if self.stunned == 1 then self.stunned_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		if not self:attr("stunned") then self.stunned_counter = nil end
	end,
}

newEffect{
	name = "SPYDRIC_POISON",
	desc = "Spydric Poison",
	long_desc = function(self, eff) return ("The target is poisoned, doing %0.2f nature damage per turn and preventing any movements (but can still act freely)."):format(eff.power) end,
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
		DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
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
	long_desc = function(self, eff) return ("The target is constricted, preventing movement and making it suffocate(loses %0.2f air per turn)."):format(eff.power) end,
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is constricted!", "+Constricted" end,
	on_lose = function(self, err) return "#Target# is free to breathe.", "-Constricted" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if math.floor(core.fov.distance(self.x, self.y, eff.src.x, eff.src.y)) > 1 or eff.src.dead then
			return true
		end
		self:suffocate(eff.power, eff.src)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "DAZED",
	desc = "Dazed",
	long_desc = function(self, eff) return "The target is dazed, redering it unable to act. Any damage will remove the daze." end,
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
	long_desc = function(self, eff) return ("The target has %d%% chances to evade melee attacks."):format(eff.chance) end,
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
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format((1 / (1 - eff.power) - 1) * 100) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Fast" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Fast" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("energy", {mod=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
	end,
}

newEffect{
	name = "SLOW",
	desc = "Slow",
	long_desc = function(self, eff) return ("Reduces global action speed by %d%%."):format((1 / (1 - eff.power) - 1) * 100) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# slows down.", "+Slow" end,
	on_lose = function(self, err) return "#Target# speeds up.", "-Slow" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("energy", {mod=-eff.power})
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
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
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
	end,
}

newEffect{
	name = "CONFUSED",
	desc = "Confused",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%) and unable to perform complex actions."):format(eff.power) end,
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		eff.dur = self:updateEffectDuration(eff.dur, "confusion")
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
	name = "HALFLING_LUCK",
	desc = "Halflings's Luck",
	long_desc = function(self, eff) return ("The target's luck and cunning combine to grant it %d%% more combat critical chances and %d%% more spell critical chances."):format(eff.physical, eff.spell) end,
	type = "physical",
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target# awareness returns to normal." end,
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
		eff.particle = self:addParticles(Particles.new("time_prison", 1))
		self.energy.value = 0
	end,
	on_timeout = function(self, eff)
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
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
	end,
	on_timeout = function(self, eff)
		-- Track an actor if it's not dead
		if eff.track and not eff.track.dead then
			eff.x = eff.track.x
			eff.y = eff.track.y
			game.level.map.changed = true
		end
	end,
	deactivate = function(self, eff)
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
	name = "STRENGTH",
	desc = "Strength",
	long_desc = function(self, eff) return ("Strength, dexterity and constitution increased by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_STR] = eff.power,
			[Stats.STAT_DEX] = eff.power,
			[Stats.STAT_CON] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
	end,
}

newEffect{
	name = "WILL",
	desc = "Will",
	long_desc = function(self, eff) return ("Willpower, cunning and magic increased by %d."):format(eff.power) end,
	type = "physical",
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_MAG] = eff.power,
			[Stats.STAT_WIL] = eff.power,
			[Stats.STAT_CUN] = eff.power,
		})
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
		self.displacement_shield = eff.power
		self.displacement_shield_chance = eff.chance
		--- Warning there can be only one time shield active at once for an actor
		self.displacement_shield_target = eff.target
		eff.particle = self:addParticles(Particles.new("displacement_shield", 1))
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
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		eff.particle = self:addParticles(Particles.new("damage_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_shield", eff.tmpid)
		self.damage_shield_absorb = nil
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
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
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
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Time Shield Backfire",
	long_desc = function(self, eff) return ("The time distortion protecting the target has ended. All damage forwarded in time is now applied, doing %d%% arcane damage per turn."):format(eff.power) end,
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
	desc = "Migth Blows",
	long_desc = function(self, eff) return ("The target's combat damage rating is improved by %d."):format(eff.power) end,
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
		DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
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
		DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
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
		DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
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
	long_desc = function(self, eff) return ("The target is infected by a disease, doing %0.2f blight damage per turn.\nEach non-disease blight damage done to it will spread the disease."):format(eff.dam) end,
	type = "disease",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is afflicted by an epidemic!" end,
	on_lose = function(self, err) return "#Target# is free from the epidemic." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("diseases_spread_on_blight", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("diseases_spread_on_blight", eff.tmpid)
	end,
}

newEffect{
	name = "CRIPPLE",
	desc = "Cripple",
	long_desc = function(self, eff) return ("The target is crippled, reducing attack by %d and damage rating by %d."):format(eff.atk, eff.dam) end,
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
	long_desc = function(self, eff) return ("The target puts all its willpower into its blows, improving damage rating by %d."):format(eff.power) end,
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
		eff.tmpid = self:addTemporaryValue("life_regen", -self.life_regen)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
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
	long_desc = function(self, eff) return ("The target has been splashed with acid, doing %0.2f acid damage per turn, reducing armour by %d and attack by %d."):format(eff.dam, eff.armor or 0, eff.atk) end,
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
	long_desc = function(self, eff) return ("The target is hexed, granting it %d%% chances each turn to be dazed for 3 turns."):format(eff.chance) end,
	type = "hex",
	status = "detrimental",
	parameters = {chance=10},
	on_gain = function(self, err) return "#Target# is hexed!", "+Pacification Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Pacification Hex" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if not self:hasEffect(self.EFF_DAZED) and rng.percent(eff.chance) then self:setEffect(self.EFF_DAZED, 3, {}) end
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
	long_desc = function(self, eff) return ("The gloom reduces the target's global speed by %d%%."):format((1 / (1 - eff.power) - 1) * 100) end,
	type = "mental",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# moves reluctantly!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("energy", {mod=-eff.power})
		eff.dur = self:updateEffectDuration(eff.dur, "slow")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "GLOOM_STUNNED",
	desc = "Stunned by the gloom",
	long_desc = function(self, eff) return "The gloom has stunned the target, redering it unable to act." end,
	type = "mental",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is paralyzed with fear!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Stunned" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		-- Start the stun counter only if this is the first stun
		if self.stunned == 1 then self.stunned_counter = (self:attr("stun_immune") or 0) * 100 end
		eff.dur = self:updateEffectDuration(eff.dur, "stun")
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("stunned", eff.tmpid)
		if not self:attr("stunned") then self.stunned_counter = nil end
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
			game.logSeen(self, "%s died when the effects of increased life wore off.", self.name:capitalize())
			self:die(self)
		end
	end,
}

newEffect{
	name = "DOMINATED",
	desc = "Dominated",
	long_desc = function(self, eff) return "The target is dominated, increasing damage done to it by its master." end,
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
		if eff.speed or 0 > 0 then eff.speedId = self:addTemporaryValue("energy", {mod=eff.speed * 0.01}) end
		if eff.attack or 0 > 0 then eff.attackId = self:addTemporaryValue("combat_atk", self.combat_atk * eff.attack * 0.01) end
		if eff.evasion or 0 > 0 then eff.evasionId = self:addTemporaryValue("evasion", eff.evasion) end

		eff.particle = self:addParticles(Particles.new("rampage", 1))
	end,
	deactivate = function(self, eff)
		if eff.hateLossId then self:removeTemporaryValue("hate_regen", eff.hateLossId) end
		if eff.criticalId then self:removeTemporaryValue("combat_physcrit", eff.criticalId) end
		if eff.damageId then self:removeTemporaryValue("inc_damage", eff.damageId) end
		if eff.speedId then self:removeTemporaryValue("energy", eff.speedId) end
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
		self:project({type="ball", radius=eff.radius, friendlyfire=false}, self.x, self.y, function(xx, yy)
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
		eff.tmpid = self:addTemporaryValue("energy", {mod=eff.speed * 0.01})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
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
	long_desc = function(self, eff) return ("The target's blight damage is increased by %d%%."):format(eff.power) end,
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
	long_desc = function(self, eff) return "The target is unstoppable! It refuses to die." end,
	type = "physical",
	status = "beneficial",
	parameters = { hp_per_kill=2 },
	activate = function(self, eff)
		eff.kills = 0
		eff.tmpid = self:addTemporaryValue("unstoppable", 1)
	end,
	deactivate = function(self, eff)
		self:heal(eff.kills * eff.hp_per_kill * self.max_life / 100)
		self:removeTemporaryValue("unstoppable", eff.tmpid)
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
		if self._mo then
			self._mo:invalidate()
			game.level.map:updateMap(self.x, self.y)
		end
		eff.life_regen = self:addTemporaryValue("life_regen", 25)	         -- gives it a 10 life regen, should I increase this?
		eff.mana_regen = self:addTemporaryValue("mana_regen", -9.75)          -- makes the mana regen realistic
		eff.never_move = self:addTemporaryValue("never_move", 1)	 -- egg form shouldnt move
		eff.silence = self:addTemporaryValue("silence", 1)		          -- egg shouldnt cast spells
		eff.combat = self.combat
		self.combat = nil						               -- egg shouldn't melee
	end,
	deactivate = function(self, eff)
		self.display = "B"
		if self._mo then
			self._mo:invalidate()
			game.level.map:updateMap(self.x, self.y)
		end
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
		local tg = {type="ball", x=self.x, y=self.y, radius=eff.radius, friendlyfire=false}
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
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if self:canBe("worldport") then
			game:onTickEnd(function()
				game.logPlayer(self, "You are yanked out of this place!")
				game:changeLevel(1, game.player.last_wilderness)
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
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk of teleporting to Angolwen.")
			return
		end

		if self:canBe("worldport") then
			game:onTickEnd(function()
				game.logPlayer(self, "You are yanked out of this place!")
				game:changeLevel(1, "town-angolwen")
			end)
		else
			game.logPlayer(self, "Space restabilizes around you.")
		end
	end,
}

newEffect{
	name = "NO_SUMMON",
	desc = "Suppress Summon",
	long_desc = function(self, eff) return "You cannot summon." end,
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
	name = "LIGHTNING_SPEED",
	desc = "Lightning Speed",
	long_desc = function(self, eff) return ("Turn into pure lightning, moving %d%% faster. It also increases your lightning resistance by 100%% and your physical resistance by 30%%."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# turn into pure lightning!.", "+Lightning Speed" end,
	on_lose = function(self, err) return "#Target# is back to normal.", "-Lightning Speed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("lightning_speed", 1)
		eff.moveid = self:addTemporaryValue("energy", {mod=self.energy.mod*eff.power/100})
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
		self:removeTemporaryValue("energy", eff.moveid)
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
	name = "DAMPENING_FIELD",
	desc = "Dampening Field",
	long_desc = function(self, eff) return ("An inertial field that provides %d%% stun, daze, knockback, and physical damage resistance."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is surrounded by a dampening field.", "+Dampening Field" end,
	on_lose = function(self, err) return "The field around #Target# dissipates.", "-Dampening Field" end,
	activate = function(self, eff)
		local effect = eff.power / 100
		eff.particle = self:addParticles(Particles.new("golden_shield", 1))
		eff.phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=eff.power})
		eff.stun = self:addTemporaryValue("stun_immune", effect)
		eff.daze = self:addTemporaryValue("daze_immune", effect)
		eff.knock = self:addTemporaryValue("knockback_immune", effect)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("stun_immune", eff.stun)
		self:removeTemporaryValue("daze_immune", eff.daze)
		self:removeTemporaryValue("knockback_immune", eff.knock)
		self:removeTemporaryValue("resists", eff.phys)
	end,
}

newEffect{
	name = "ENTROPIC_SHIELD",
	desc = "Entropic Shield",
	long_desc = function(self, eff) return ("Huge cut that bleeds blood, doing %0.2f physical damage per turn."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is surrounded by an entropic shield.", "+Entropic Shield" end,
	on_lose = function(self, err) return "The entropic shield around #Target# disappates.", "-Entropic Shield" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
		eff.phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=eff.power})
		eff.proj = self:addTemporaryValue("slow_projectiles", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resists", eff.phys)
		self:removeTemporaryValue("slow_projectiles", eff.proj)
	end,
}

newEffect{
	name = "DAMAGE_SMEARING",
	desc = "Damage Smearing",
	long_desc = function(self, eff) return ("Passes damage recieved in the present off onto the future self."):format(eff.power) end,
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The fabric of time alters around #target#.", "+Damage Smearing" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes.", "-Damage Smearing" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("damage_smearing", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_smearing", eff.tmpid)
	end,
}

newEffect{
	name = "SMEARED",
	desc = "Smeared",
	long_desc = function(self, eff) return ("Damage received in the past is returned as %0.2f arcane damage per turn."):format(eff.power) end,
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
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.power)
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
	name = "FRICTION",
	desc = "Friction",
	long_desc = function(self, eff) return ("Each time the target moves it takes %0.2f fire damage over three turns."):format(eff.dam) end,
	type = "magical",
	status = "detrimental",
	parameters = {dam=10},
	on_gain = function(self, err) return "The effect of friction on #Target# has been amplified!", "+Friction" end,
	on_lose = function(self, err) return "The effect of friction on #Target# has returned to normal.", "-Friction" end,
}

newEffect{
	name = "STOP",
	desc = "Stop",
	long_desc = function(self, eff) return ("The target is slowed but gradually recovering speed."):format(eff.chance) end,
	type = "magical",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# is stopped!", "+Stop" end,
	on_lose = function(self, err) return "#Target# has fully recovered from being stopped.", "-Stop" end,
	-- Recover each turn
	activate = function(self, eff)
		eff.dur = self:updateEffectDuration(eff.dur, "stop")
	end,
	on_timeout = function(self, eff)
		self:addTemporaryValue("energy", {mod= eff.power*eff.dur})
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
	long_desc = function(self, eff) return ("Increases the effectiveness of all healing the target receives."):format(eff.power) end,
	type = "magical",
	status = "beneficial",
	parameters = { power= 0.1 },
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
	long_desc = function(self, eff) return "The target is under protection." end,
	type = "magical",
	status = "beneficial",
	parameters = {},
	on_timeout = function(self, eff)
		local effs = {}
				-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				known = true
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
	name = "FEED_HATE",
	desc = "Feeding Hate",
	long_desc = function(self, eff) return ("%s is feeding %0.2f hate from %s."):format(self.name:capitalize(), eff.hateGain, eff.target.name) end,
	type = "mental",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.hateGainId = self:addTemporaryValue("hate_regen", eff.hateGain)

		eff.extension = eff.extension or 0
		eff.isSevered = false
	end,
	deactivate = function(self, eff)
		if eff.hateGainId then self:removeTemporaryValue("hate_regen", eff.hateGainId) end

		if eff.particles then
			-- remove old particle emitter
			eff.particles.x = nil
			eff.particles.y = nil
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end
	end,
	on_timeout = function(self, eff)
		if eff.isSevered then
			eff.extension = eff.extension - 1
			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_HATE)
			end
		elseif eff.target.dead or not self:hasLOS(eff.target.x, eff.target.y) then
			eff.isSevered = true

			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end

			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_HATE)
			end
		else
			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = eff.target.x - self.x, eff.target.y - self.y
			eff.particles = Particles.new("feed_hate", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = self.x
			eff.particles.y = self.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end,
}

newEffect{
	name = "FEED_HEALTH",
	desc = "Feeding Health",
	long_desc = function(self, eff)
		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			return ("#Target# is feeding %d constitution and %0.1f life per turn from %s."):format(eff.constitutionGain, eff.lifeRegenGain, eff.target.name)
		else
			return ("#Target# is feeding %d constitution from %s."):format(eff.constitutionGain, eff.target.name)
		end
	end,
	type = "mental",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.constitutionGainId = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_CON] = eff.constitutionGain,
		})
		eff.constitutionLossId = eff.target:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_CON] = -eff.constitutionGain,
		})

		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			eff.lifeRegenGainId = self:addTemporaryValue("life_regen", eff.lifeRegenGain)
			eff.lifeRegenLossId = eff.target:addTemporaryValue("life_regen", -eff.lifeRegenGain)
		end

		eff.extension = eff.extension or 0
		eff.isSevered = false
	end,
	deactivate = function(self, eff)
		if eff.constitutionGainId then self:removeTemporaryValue("inc_stats", eff.constitutionGainId) end
		if eff.constitutionLossId then eff.target:removeTemporaryValue("inc_stats", eff.constitutionLossId) end
		if eff.lifeRegenGainId then self:removeTemporaryValue("life_regen", eff.lifeRegenGainId) end
		if eff.lifeRegenLossId then eff.target:removeTemporaryValue("life_regen", eff.lifeRegenLossId) end

		if eff.particles then
			-- remove old particle emitter
			eff.particles.x = nil
			eff.particles.y = nil
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end
	end,
	on_timeout = function(self, eff)
		if eff.isSevered then
			eff.extension = eff.extension - 1
			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_HEALTH)
			end
		elseif eff.target.dead or not self:hasLOS(eff.target.x, eff.target.y) then
			eff.isSevered = true

			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end

			eff.target:removeTemporaryValue("inc_stats", eff.constitutionLossId)
			eff.constitutionLossId = nil
			eff.target:removeTemporaryValue("life_regen", eff.lifeRegenLossId)
			eff.lifeRegenLossId = nil

			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_HEALTH)
			end
		else
			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = eff.target.x - self.x, eff.target.y - self.y
			eff.particles = Particles.new("feed_health", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = self.x
			eff.particles.y = self.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end,
}

newEffect{
	name = "FEED_POWER",
	desc = "Feeding Power",
	long_desc = function(self, eff)
		return ("%s is feeding %d%% increased damage from %s."):format(self.name:capitalize(), eff.damageGain, eff.target.name)
	end,
	type = "mental",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.damageGainId = self:addTemporaryValue("inc_damage", {all=eff.damageGain})
		eff.damageLossId = eff.target:addTemporaryValue("inc_damage", {all=eff.damageLoss})
		eff.extension = eff.extension or 0
		eff.isSevered = false
	end,
	deactivate = function(self, eff)
		if eff.damageGainId then self:removeTemporaryValue("inc_damage", eff.damageGainId) end
		if eff.damageLossId then eff.target:removeTemporaryValue("inc_damage", eff.damageLossId) end

		if eff.particles then
			-- remove old particle emitter
			eff.particles.x = nil
			eff.particles.y = nil
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end
	end,
	on_timeout = function(self, eff)
		if eff.isSevered then
			eff.extension = eff.extension - 1
			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_POWER)
			end
		elseif eff.target.dead or not self:hasLOS(eff.target.x, eff.target.y) then
			eff.isSevered = true

			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end

			eff.target:removeTemporaryValue("inc_damage", eff.damageLossId)
			eff.damageLossId = nil

			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_POWER)
			end
		else
			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = eff.target.x - self.x, eff.target.y - self.y
			eff.particles = Particles.new("feed_power", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = self.x
			eff.particles.y = self.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end,
}

newEffect{
	name = "FEED_STRENGTHS",
	desc = "Feeding Strengths",
	long_desc = function(self, eff) return ("%s is feeding %d%% or resistances %s."):format(self.name:capitalize(), eff.resistGain, eff.target.name) end,
	type = "mental",
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
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

		eff.extension = eff.extension or 0
		eff.isSevered = false
	end,
	deactivate = function(self, eff)
		if eff.resistGainId then self:removeTemporaryValue("resists", eff.resistGainId) end
		if eff.resistLossId then eff.target:removeTemporaryValue("resists", eff.resistLossId) end

		if eff.particles then
			-- remove old particle emitter
			eff.particles.x = nil
			eff.particles.y = nil
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end
	end,
	on_timeout = function(self, eff)
		if eff.isSevered then
			eff.extension = eff.extension - 1
			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_STRENGTHS)
			end
		elseif eff.target.dead or not self:hasLOS(eff.target.x, eff.target.y) then
			eff.isSevered = true

			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end

			if eff.resistLossId then self:removeTemporaryValue("resists", eff.resistLossId) end
			eff.resistLossId = nil

			if eff.extension <= 0 then
				self:removeEffect(self.EFF_FEED_STRENGTHS)
			end
		else
			if eff.particles then
				-- remove old particle emitter
				eff.particles.x = nil
				eff.particles.y = nil
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = eff.target.x - self.x, eff.target.y - self.y
			eff.particles = Particles.new("feed_strengths", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = self.x
			eff.particles.y = self.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end,
}

newEffect{
	name = "AGONY",
	desc = "Agony",
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

		local power = 1 - (math.min(eff.range, core.fov.distance(eff.source.x, eff.source.y, self.x, self.y)) / eff.range)
		if power > 0 then
			if self:checkHit(eff.mindpower, self:combatMentalResist(), 0, 95, 5) then
				local damage = math.floor(eff.damage * power)
				if damage > 0 then
					DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, damage)
				end
			else
				return true
			end
		end

		if self.dead then
			if eff.particle then self:removeParticles(eff.particle) end
			return
		end

		if math.floor(power * 10) + 1 ~= eff.power then
			eff.power = math.floor(power * 10) + 1
			if eff.particle then self:removeParticles(eff.particle) end
			eff.particle = nil
			if eff.power > 0 then
				eff.particle = self:addParticles(Particles.new("agony", 1, { power = eff.power }))
			end
		end
	end,
}


newEffect{
	name = "TOTALITY",
	desc = "Totality",
	long_desc = function(self, eff) return ("The target's light and darkness spell penetration has been increased by %d%%."):format(eff.power, eff.power) end,
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

