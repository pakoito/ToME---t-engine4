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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

-- Item specific
newEffect{
	name = "ITEM_ANTIMAGIC_SCOURED", image = "talents/acidic_skin.png",
	desc = "Scoured",
	long_desc = function(self, eff) return ("Scoured by natural acid, reducing their offensive power ratings by %d%%."):format(eff.pct*100 or 0) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = {pct = 0.3, spell = 0, mind = 0, phys = 0, power_str = ""},
	on_gain = function(self, err) return "#Target#'s powers is greatly reduced!" end,
	on_lose = function(self, err) return "#Target# is fully powered again." end,
	on_timeout = function(self, eff)
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "scoured", 1)
	end,
	deactivate = function(self, eff)

	end,
}

newEffect{
	name = "RELENTLESS_TEMPO", image = "talents/sunder_mind.png",
	desc = "Relentless Tempo",
	long_desc = function(self, eff) return ("Attuning to the flow of combat, increasing their combat stats.  \nDefense:  %d\nAll Damage:  %d%%\nStamina Regeneration:  %d\n%s"):
		format( eff.cur_defense or 0, eff.cur_damage or 0, eff.cur_stamina or 0, eff.stacks >= 5 and "All Resistance:  20%" or "") end,
	charges = function(self, eff) return eff.stacks end,
	type = "physical",
	subtype = { tempo=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target# is gaining tempo.", "+Tempo" end,
	on_lose = function(self, err) return "#Target# loses their tempo.", "-Tempo" end,
	parameters = { stamina = 0, defense = 0, damage = 0, stacks = 0, resists = 0 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur =3

		if old_eff.stacks >= 5 then
			if old_eff.resists ~= 20 then
				old_eff.resists = 20
				old_eff.resid = self:addTemporaryValue("resists", {all=old_eff.resists})
			end
			return old_eff
		end

		old_eff.stacks = old_eff.stacks + 1

		self:removeTemporaryValue("stamina_regen", old_eff.staminaid)
		self:removeTemporaryValue("combat_def", old_eff.defenseid)
		self:removeTemporaryValue("inc_damage", old_eff.damageid)

		old_eff.cur_stamina = old_eff.cur_stamina + new_eff.stamina
		old_eff.cur_defense = old_eff.cur_defense + new_eff.defense
		old_eff.cur_damage = old_eff.cur_damage + new_eff.damage

		old_eff.staminaid = self:addTemporaryValue("stamina_regen", old_eff.cur_stamina)
		old_eff.defenseid = self:addTemporaryValue("combat_def", old_eff.cur_defense)
		old_eff.damageid = self:addTemporaryValue("inc_damage", {all = old_eff.cur_damage})

		return old_eff
	end,
	activate = function(self, eff)
		eff.stacks = 1
		eff.cur_stamina = eff.stamina
		eff.cur_defense = eff.defense
		eff.cur_damage = eff.damage

		eff.staminaid = self:addTemporaryValue("stamina_regen", eff.cur_defense)
		eff.defenseid = self:addTemporaryValue("combat_def", eff.cur_defense)
		eff.damageid = self:addTemporaryValue("inc_damage", {all = eff.cur_damage})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stamina_regen", eff.staminaid)
		self:removeTemporaryValue("combat_def", eff.defenseid)
		self:removeTemporaryValue("inc_damage", eff.damageid)
		if eff.resid then self:removeTemporaryValue("resists", eff.resid) end
	end,
}


newEffect{
	name = "DELIRIOUS_CONCUSSION", image = "talents/slippery_moss.png",
	desc = "Concussion",
	long_desc = function(self, eff) return ("The target can't think straight, causing their actions to fail."):format() end,
	type = "physical",
	subtype = { concussion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#'s brain isn't quite working right!", "+Concussion" end,
	on_lose = function(self, err) return "#Target# regains their concentration.", "-Concussion" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}



newEffect{
	name = "CUT", image = "effects/cut.png",
	desc = "Bleeding",
	long_desc = function(self, eff) return ("Huge cut that bleeds, doing %0.2f physical damage per turn."):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
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
	activate = function(self, eff)
		if eff.src:knowTalent(self.T_BLOODY_BUTCHER) then
			local t = eff.src:getTalentFromId(eff.src.T_BLOODY_BUTCHER)
			local resist = math.min(t.getResist(eff.src, t), math.max(0, self:combatGetResist(DamageType.PHYSICAL)))
			self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL] = -resist})
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "DEEP_WOUND", image = "talents/bleeding_edge.png",
	desc = "Deep Wound",
	long_desc = function(self, eff) return ("Huge cut that bleeds, doing %0.2f physical damage per turn and decreasing all heals received by %d%%."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
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
	name = "REGENERATION", image = "talents/infusion__regeneration.png",
	desc = "Regeneration",
	long_desc = function(self, eff) return ("A flow of life spins around the target, regenerating %0.2f life per turn."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, healing=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts regenerating health quickly.", "+Regen" end,
	on_lose = function(self, err) return "#Target# stops regenerating health quickly.", "-Regen" end,
	activate = function(self, eff)
		if not eff.no_wild_growth then
			if self:attr("liferegen_factor") then eff.power = eff.power * (100 + self:attr("liferegen_factor")) / 100 end
			if self:attr("liferegen_dur") then eff.dur = eff.dur + self:attr("liferegen_dur") end
		end
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)

		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, circleColor={0,0,0,0}, beamsCount=9}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, circleColor={0,0,0,0}, beamsCount=9}))
		end

		if self:knowTalent(self.T_ANCESTRAL_LIFE) then
			local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
			self.energy.value = self.energy.value + (t.getTurn(self, t) * game.energy_to_act / 100)
		end
	end,
	on_timeout = function(self, eff)
		if self:knowTalent(self.T_ANCESTRAL_LIFE) then
			local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
			self:incEquilibrium(-t.getEq(self, t))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "POISONED", image = "effects/poisoned.png",
	desc = "Poison",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn."):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
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
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
}

newEffect{
	name = "SPYDRIC_POISON", image = "effects/spydric_poison.png",
	desc = "Spydric Poison",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn and unable to move (but can otherwise act freely)."):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, pin=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target# is poisoned and cannot move!", "+Spydric Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Spydric Poison" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "INSIDIOUS_POISON", image = "effects/insidious_poison.png",
	desc = "Insidious Poison",
	long_desc = function(self, eff) return ("The target is poisoned, taking %0.2f nature damage per turn and decreasing all heals received by %d%%."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Insidious Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Insidious Poison" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}


newEffect{
	name = "CRIPPLING_POISON", image = "talents/crippling_poison.png",
	desc = "Crippling Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, doing %0.2f nature damage per turn. Each time it tries to use a talent there is %d%% chance of failure."):format(eff.power, eff.fail) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, fail=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Crippling Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Crippling Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
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
	name = "NUMBING_POISON", image = "effects/numbing_poison.png",
	desc = "Numbing Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, doing %0.2f nature damage per turn. All damage it does is reduced by %d%%."):format(eff.power, eff.reduce) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Numbing Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Numbing Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
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
	name = "STONE_POISON", image = "talents/stoning_poison.png",
	desc = "Stoning Poison",
	long_desc = function(self, eff) return ("The target is poisoned and sick, taking %0.2f nature damage per turn. If the effect runs its full course, the target will turn to stone for %d turns."):format(eff.power, eff.stone) end,
	type = "physical",
	subtype = { poison=true, earth=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target# is poisoned!", "+Stoning Poison" end,
	on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Stoning Poison" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.dur <= 0 and self:canBe("stun") and self:canBe("stone") and self:canBe("instakill") then
			self:setEffect(self.EFF_STONED, eff.stone, {})
		end
	end,
}

newEffect{
	name = "BURNING", image = "talents/flame.png",
	desc = "Burning",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn."):format(eff.power) end,
	type = "physical",
	subtype = { fire=true },
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
	name = "BURNING_SHOCK", image = "talents/flameshock.png",
	desc = "Burning Shock",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn, reducing damage by 70%%, putting random talents on cooldown and reducing movement speed by 50%%. While flameshocked talents do not cooldown."):format(eff.power) end,
	type = "physical",
	subtype = { fire=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned by the burning flame!", "+Burning Shock" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Burning Shock" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "STUNNED", image = "effects/stunned.png",
	desc = "Stunned",
	long_desc = function(self, eff) return ("The target is stunned, reducing damage by 60%%, putting 3 random talents on cooldown and reducing movement speed by 50%%. While stunned talents do not cooldown."):format() end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Stunned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
		end
		for i = 1, 3 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "DISARMED", image = "talents/disarm.png",
	desc = "Disarmed",
	long_desc = function(self, eff) return "The target is maimed, unable to correctly wield a weapon." end,
	type = "physical",
	subtype = { disarm=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is disarmed!", "+Disarmed" end,
	on_lose = function(self, err) return "#Target# rearms.", "-Disarmed" end,
	activate = function(self, eff)
		self:removeEffect(self.EFF_COUNTER_ATTACKING) -- Cannot parry or counterattack while disarmed
		self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) 
		eff.tmpid = self:addTemporaryValue("disarmed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("disarmed", eff.tmpid)
	end,
}

newEffect{
	name = "CONSTRICTED", image = "talents/constrict.png",
	desc = "Constricted",
	long_desc = function(self, eff) return ("The target is constricted, preventing movement and making it suffocate (loses %0.2f air per turn)."):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {power=10},
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
	name = "DAZED", image = "effects/dazed.png",
	desc = "Dazed",
	long_desc = function(self, eff) return "The target is dazed, rendering it unable to move, halving all damage done, defense, saves, accuracy, spell, mind and physical power. Any damage will remove the daze." end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is dazed!", "+Dazed" end,
	on_lose = function(self, err) return "#Target# is not dazed anymore.", "-Dazed" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dazed", 1)
		self:effectTemporaryValue(eff, "never_move", 1)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "EVASION", image = "talents/evasion.png",
	desc = "Evasion",
	long_desc = function(self, eff)
		return ("The target has %d%% chance to evade melee attacks"):format(eff.chance) .. ((eff.defense>0 and (" and gains %d defense"):format(eff.defense)) or "") .. "." 
	end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { chance=10, defense=0 },
	on_gain = function(self, err) return "#Target# tries to evade attacks.", "+Evasion" end,
	on_lose = function(self, err) return "#Target# is no longer evading attacks.", "-Evasion" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("evasion", eff.chance)
		eff.defid = self:addTemporaryValue("combat_def", eff.defense)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("evasion", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.defid)
	end,
}

newEffect{
	name = "SPEED", image = "talents/shaloren_speed.png",
	desc = "Speed",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	subtype = { speed=true },
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
	name = "SLOW", image = "talents/slow.png",
	desc = "Slow",
	long_desc = function(self, eff) return ("Reduces global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	subtype = { slow=true },
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
	name = "BLINDED", image = "effects/blinded.png",
	desc = "Blinded",
	long_desc = function(self, eff) return "The target is blinded, unable to see anything." end,
	type = "physical",
	subtype = { blind=true },
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
	name = "DWARVEN_RESILIENCE", image = "talents/dwarf_resilience.png",
	desc = "Dwarven Resilience",
	long_desc = function(self, eff) return ("The target's skin turns to stone, granting %d armour, %d physical save and %d spell save."):format(eff.armor, eff.physical, eff.spell) end,
	type = "physical",
	subtype = { earth=true },
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
	name = "STONE_SKIN", image = "talents/stoneskin.png",
	desc = "Stoneskin",
	long_desc = function(self, eff) return ("The target's skin reacts to damage, granting %d armour."):format(eff.power) end,
	type = "physical",
	subtype = { earth=true },
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
	name = "THORNY_SKIN", image = "talents/stoneskin.png",
	desc = "Thorny Skin",
	long_desc = function(self, eff) return ("The target's skin reacts to damage, granting %d armour and %d%% armour hardiness."):format(eff.ac, eff.hard) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { ac=10, hard=10 },
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.ac)
		eff.hid = self:addTemporaryValue("combat_armor_hardiness", eff.hard)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
		self:removeTemporaryValue("combat_armor_hardiness", eff.hid)
	end,
}

newEffect{
	name = "FROZEN_FEET", image = "talents/frozen_ground.png",
	desc = "Frozen Feet",
	long_desc = function(self, eff) return "The target is frozen on the ground, able to act freely but not move." end,
	type = "physical",
	subtype = { cold=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is frozen to the ground!", "+Frozen" end,
	on_lose = function(self, err) return "#Target# warms up.", "-Frozen" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
		self:removeTemporaryValue("frozen", eff.frozid)
	end,
}

newEffect{
	name = "FROZEN", image = "talents/freeze.png",
	desc = "Frozen",
	long_desc = function(self, eff) return ("The target is encased in ice. All damage done to it will be split, 40%% absorbed by the ice and 60%% by the target. The target's defense is nullified while in the ice, and it may only attack the ice, but it is also immune to any new detrimental status effects. The target cannot teleport or heal while frozen. %d HP on the iceblock remaining."):format(eff.hp) end,
	type = "physical", -- Frozen has some serious effects beyond just being frozen, no healing, no teleport, etc.  But it can be applied by clearly non-magical sources i.e. Ice Breath
	subtype = { cold=true, stun=true },
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
		eff.ice = mod.class.Object.new{name = "Iceblock", type = "wall", image='npc/iceblock.png', display = ' '} -- use type Object to facilitate the combat log
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		eff.hp = eff.hp or 100
		eff.tmpid = self:addTemporaryValue("encased_in_ice", 1)
		eff.healid = self:addTemporaryValue("no_healing", 1)
		eff.moveid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.defid = self:addTemporaryValue("combat_def", -self:combatDefenseBase()-10)
		eff.rdefid = self:addTemporaryValue("combat_def_ranged", -self:combatDefenseBase()-10)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)

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
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
		self:setTarget(nil)
	end,
}

newEffect{
	name = "ETERNAL_WRATH", image = "talents/thaloren_wrath.png",
	desc = "Wrath of the Eternals",
	long_desc = function(self, eff) return ("The target calls upon its inner resources, improving all damage by %d%% and reducing all damage taken by %d%%."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
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
	name = "SHELL_SHIELD", image = "talents/shell_shield.png",
	desc = "Shell Shield",
	long_desc = function(self, eff) return ("The target takes cover in its shell, reducing all damage taken by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
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
	name = "PAIN_SUPPRESSION", image = "talents/infusion__wild.png",
	desc = "Pain Suppression",
	long_desc = function(self, eff) return ("The target ignores pain, reducing all damage taken by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
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

-- artifact wild infusion
newEffect{
	name = "PRIMAL_ATTUNEMENT", image = "talents/infusion__wild.png",
	desc = "Primal Attunement",
	long_desc = function(self, eff) return ("The target is attuned to the wild, increasing all damage affinity by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# attunes to the wild.", "+Primal" end,
	on_lose = function(self, err) return "#Target# is no longer one with nature.", "-Primal" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("damage_affinity", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("damage_affinity", eff.pid)
	end,
}

newEffect{
	name = "PURGE_BLIGHT", image = "talents/infusion__wild.png",
	desc = "Purge Blight",
	long_desc = function(self, eff) return ("The target is infused with the power of nature, reducing all blight damage taken by %d%%, increasing spell saves by %d, and granting immunity to diseases."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# rejects blight!", "+Purge" end,
	on_lose = function(self, err) return "#Target# is susceptible to blight again.", "-Purge" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.BLIGHT]=eff.power})
		eff.spell_save = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.disease = self:addTemporaryValue("disease_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellresist", eff.spell_save)
		self:removeTemporaryValue("disease_immune", eff.disease)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "SENSE", image = "talents/track.png",
	desc = "Sensing",
	long_desc = function(self, eff) return "Improves senses, allowing the detection of unseen things." end,
	type = "physical",
	subtype = { sense=true },
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
	name = "HEROISM", image = "talents/infusion__heroism.png",
	desc = "Heroism",
	long_desc = function(self, eff) return ("Increases your three highest stats by %d."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		local l = { {Stats.STAT_STR, self:getStat("str")}, {Stats.STAT_DEX, self:getStat("dex")}, {Stats.STAT_CON, self:getStat("con")}, {Stats.STAT_MAG, self:getStat("mag")}, {Stats.STAT_WIL, self:getStat("wil")}, {Stats.STAT_CUN, self:getStat("cun")}, }
		table.sort(l, function(a,b) return a[2] > b[2] end)
		local inc = {}
		for i = 1, 3 do inc[l[i][1]] = eff.power end
		self:effectTemporaryValue(eff, "inc_stats", inc)
		self:effectTemporaryValue(eff, "die_at", -eff.die_at)
	end,
}

newEffect{
	name = "SUNDER_ARMOUR", image = "talents/sunder_armour.png",
	desc = "Sunder Armour",
	long_desc = function(self, eff) return ("The target's armour and saves are broken, reducing them by %d."):format(eff.power) end,
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", -eff.power)
		self:effectTemporaryValue(eff, "combat_physresist", -eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", -eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.power)
	end,
}

newEffect{
	name = "SUNDER_ARMS", image = "talents/sunder_arms.png",
	desc = "Sunder Arms",
	long_desc = function(self, eff) return ("The target's combat ability is reduced, reducing its attack by %d."):format(eff.power) end,
	type = "physical",
	subtype = { sunder=true },
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
	name = "PINNED", image = "effects/pinned.png",
	desc = "Pinned to the ground",
	long_desc = function(self, eff) return "The target is pinned to the ground, unable to move." end,
	type = "physical",
	subtype = { pin=true },
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
	name = "BONE_GRAB", image = "talents/bone_grab.png",
	desc = "Pinned to the ground",
	long_desc = function(self, eff) return "The target is pinned to the ground, unable to move." end,
	type = "physical",
	subtype = { pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is pinned to the ground.", "+Bone Grab" end,
	on_lose = function(self, err) return "#Target# is no longer pinned.", "-Bone Grab" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)

		if not self.add_displays then
			self.add_displays = { Entity.new{image='npc/bone_grab_pin.png', display=' ', display_on_seen=true } }
			eff.added_display = true
		end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if eff.added_display then self.add_displays = nil end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "MIGHTY_BLOWS", image = "effects/mighty_blows.png",
	desc = "Mighty Blows",
	long_desc = function(self, eff) return ("The target's combat damage is improved by %d."):format(eff.power) end,
	type = "physical",
	subtype = { golem=true },
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
	name = "CRIPPLE", image = "talents/cripple.png",
	desc = "Cripple",
	long_desc = function(self, eff) return ("The target is crippled, reducing melee, spellcasting and mind speed by %d%%."):format(eff.speed*100) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { speed=0.3 },
	on_gain = function(self, err) return "#Target# is crippled." end,
	on_lose = function(self, err) return "#Target# is not cripple anymore." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", -eff.speed)
		self:effectTemporaryValue(eff, "combat_spellspeed", -eff.speed)
		self:effectTemporaryValue(eff, "combat_mindspeed", -eff.speed)
	end,
}

newEffect{
	name = "BURROW", image = "talents/burrow.png",
	desc = "Burrow",
	long_desc = function(self, eff) return "The target is able to burrow into walls." end,
	type = "physical",
	subtype = { earth=true },
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
	name = "DIM_VISION", image = "talents/sticky_smoke.png",
	desc = "Reduced Vision",
	long_desc = function(self, eff) return ("The target's vision range is decreased by %d."):format(eff.sight) end,
	type = "physical",
	subtype = { sense=true },
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
	name = "RESOLVE", image = "talents/resolve.png",
	desc = "Resolve",
	long_desc = function(self, eff) return ("You gain %d%% resistance against %s."):format(eff.res, DamageType:get(eff.damtype).name) end,
	type = "physical",
	subtype = { antimagic=true, nature=true },
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
	name = "WILD_SPEED", image = "talents/infusion__movement.png",
	desc = "Wild Speed",
	long_desc = function(self, eff) return ("The movement infusion allows you to run at extreme fast pace. Any other action other than movement will cancel it. Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Wild Speed" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Wild Speed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("wild_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_speed", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "HUNTER_SPEED", image = "talents/infusion__movement.png",
	desc = "Hunter",
	long_desc = function(self, eff) return ("You are searching for a new target. Any other action other than movement will cancel it. Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Hunter" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Hunter" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("wild_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_speed", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "STEP_UP", image = "talents/step_up.png",
	desc = "Step Up",
	long_desc = function(self, eff) return ("Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { speed=true, tactic=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Step Up" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Step Up" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("step_up", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("step_up", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "LIGHTNING_SPEED", image = "talents/lightning_speed.png",
	desc = "Lightning Speed",
	long_desc = function(self, eff) return ("Turn into pure lightning, moving %d%% faster. It also increases your lightning resistance by 100%% and your physical resistance by 30%%."):format(eff.power) end,
	type = "physical",
	subtype = { lightning=true, speed=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# turns into pure lightning!.", "+Lightning Speed" end,
	on_lose = function(self, err) return "#Target# is back to normal.", "-Lightning Speed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("lightning_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
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
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "DRAGONS_FIRE", image = "talents/fire_breath.png",
	desc = "Dragon's Fire",
	long_desc = function(self, eff) return ("Dragon blood runs through your veins. You can breathe fire (or have it improved if you already could)."):format() end,
	type = "physical",
	subtype = { fire=true },
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
	name = "GREATER_WEAPON_FOCUS", image = "talents/greater_weapon_focus.png",
	desc = "Greater Weapon Focus",
	long_desc = function(self, eff) return ("%d%% chance to score a secondary blow."):format(eff.chance) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { chance=50 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

-- Grappling stuff
newEffect{
	name = "GRAPPLING", image = "talents/clinch.png",
	desc = "Grappling",
	long_desc = function(self, eff) return ("Engaged in a grapple draining %d stamina per turn and redirecting %d%% of damage taken to %s.  Any movement will break the effect as will some unarmed talents."):format(eff.drain, eff.sharePct*100, eff.trgt.name or "unknown") end,
	type = "physical",
	subtype = { grapple=true, },
	status = "beneficial",
	parameters = {trgt, sharePct = 0.1, drain = 0},
	on_gain = function(self, err) return "#Target# is engaged in a grapple!", "+Grappling" end,
	on_lose = function(self, err) return "#Target# has released the hold.", "-Grappling" end,
	on_timeout = function(self, eff)
		local p = eff.trgt:hasEffect(eff.trgt.EFF_GRAPPLED)
		if not p or p.src ~= self or core.fov.distance(self.x, self.y, eff.trgt.x, eff.trgt.y) > 1 or eff.trgt.dead or not game.level:hasEntity(eff.trgt) then
			self:removeEffect(self.EFF_GRAPPLING)
		else
			self:incStamina(-eff.drain)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnHit = function(self, eff, cb, src)
		if not src then return cb.value end
		local share = cb.value * eff.sharePct
		
		-- deal the redirected damage as physical because I don't know how to preserve the damage type in a callback
		DamageType:get(DamageType.PHYSICAL).projector(self or eff.src, eff.trgt.x, eff.trgt.y, DamageType.PHYSICAL, share)
		
		return cb.value - share
	end,
}

newEffect{
	name = "GRAPPLED", image = "talents/grab.png",
	desc = "Grappled",
	long_desc = function(self, eff) return ("The target is grappled, unable to move, and limited in its offensive capabilities.\n#RED#Silenced\nPinned\n%s\n%s\n%s"):format("Damage reduced by " .. eff.reduce, "Slowed by " .. eff.slow, "Damage per turn " .. math.ceil(eff.power) ) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {silence = 0, slow = 0, reduce = 1, power = 1},
	remove_on_clone = true,
	on_gain = function(self, err) return "#Target# is grappled!", "+Grappled" end,
	on_lose = function(self, err) return "#Target# is free from the grapple.", "-Grappled" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_dam", -eff.reduce)
		if (eff.silence > 0) then
			self:effectTemporaryValue(eff, "silence", 1)
		end
		if (eff.slow > 0) then
			self:effectTemporaryValue(eff, "global_speed_add", -eff.slow)
		end
	end,
	on_timeout = function(self, eff)
		if not self.x or not eff.src or not eff.src.x or core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_GRAPPLED)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		end
	end,
	deactivate = function(self, eff)

	end, 
}

newEffect{
	name = "CRUSHING_HOLD", image = "talents/crushing_hold.png",
	desc = "Crushing Hold",
	long_desc = function(self, eff) return ("The target is being crushed and suffers %d damage each turn"):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being crushed.", "+Crushing Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the crushing hold.", "-Crushing Hold" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) or not (p and p.src == eff.src) then
			self:removeEffect(self.EFF_CRUSHING_HOLD)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		end
	end,
}

newEffect{
	name = "STRANGLE_HOLD", image = "talents/clinch.png",
	desc = "Strangle Hold",
	long_desc = function(self, eff) return ("The target is being strangled and may not cast spells and suffers %d damage each turn."):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, silence=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being strangled.", "+Strangle Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the strangle hold.", "-Strangle Hold" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) or not (p and p.src == eff.src) then
			self:removeEffect(self.EFF_STRANGLE_HOLD)
		elseif eff.damtype then
			local type = eff.damtype
			DamageType:get(DamageType[type]).projector(eff.src or self, self.x, self.y, DamageType[type], eff.power)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
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
	name = "MAIMED", image = "talents/maim.png",
	desc = "Maimed",
	long_desc = function(self, eff) return ("The target is maimed, reducing damage by %d and global speed by 30%%."):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, slow=true },
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
	name = "COMBO", image = "talents/combo_string.png",
	desc = "Combo",
	display_desc = function(self, eff) return eff.cur_power.." Combo" end,
	long_desc = function(self, eff) return ("The target is in the middle of a combo chain and has earned %d combo points."):format(eff.cur_power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { power=1, max=5 },
	charges = function(self, eff) return eff.cur_power end,
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
	name = "DEFENSIVE_MANEUVER", image = "talents/set_up.png",
	desc = "Defensive Maneuver",
	long_desc = function(self, eff) return ("The target's defense is increased by %d."):format(eff.power) end,
	type = "physical",
	subtype = { evade=true },
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
	name = "SET_UP", image = "talents/set_up.png",
	desc = "Set Up",
	long_desc = function(self, eff) return ("The target is off balance and is %d%% more likely to be crit by the target that set it up.  In addition all its saves are reduced by %d."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { tactic=true },
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
	name = "Recovery",
	desc = "Recovery",
	long_desc = function(self, eff) return ("The target is recovering %d life each turn."):format(math.min(100, eff.pct * self.max_life)) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power=10, pct = 0.01 },
	on_gain = function(self, err) return "#Target# is recovering from the damage!", "+Recovery" end,
	on_lose = function(self, err) return "#Target# has finished recovering.", "-Recovery" end,
	activate = function(self, eff)
		--eff.regenid = self:addTemporaryValue("life_regen", eff.regen)
		--eff.healid = self:addTemporaryValue("healing_factor", eff.heal_mod / 100)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
		end
	end,
	on_timeout = function(self, eff)
		local heal = math.min(100, self.max_life * eff.pct)
		self:heal(heal, src)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		--self:removeTemporaryValue("life_regen", eff.regenid)
		--self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "REFLEXIVE_DODGING", image = "talents/heightened_reflexes.png",
	desc = "Reflexive Dodging",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	subtype = { evade=true, speed=true },
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
	name = "WEAKENED_DEFENSES", image = "talents/exploit_weakness.png",
	desc = "Weakened Defenses",
	long_desc = function(self, eff) return ("The target's physical resistance has been reduced by %d%%."):format(eff.cur_inc) end,
	type = "physical",
	subtype = { sunder=true },
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
	name = "WATERS_OF_LIFE", image = "talents/waters_of_life.png",
	desc = "Waters of Life",
	long_desc = function(self, eff) return ("The target purifies all diseases and poisons, turning them into healing effects.") end,
	type = "physical",
	subtype = { nature=true, heal=true },
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
	name = "ELEMENTAL_HARMONY", image = "effects/elemental_harmony.png",
	desc = "Elemental Harmony",
	long_desc = function(self, eff)
		if eff.type == DamageType.FIRE then return ("Increases global speed by %d%%."):format(100 * self:callTalent(self.T_ELEMENTAL_HARMONY, "fireSpeed"))
		elseif eff.type == DamageType.COLD then return ("Increases armour by %d."):format(3 + eff.power *2)
		elseif eff.type == DamageType.LIGHTNING then return ("Increases all stats by %d."):format(math.floor(eff.power))
		elseif eff.type == DamageType.ACID then return ("Increases life regen by %0.2f%%."):format(5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then return ("Increases all resists by %d%%."):format(5 + eff.power * 1.4)
		end
	end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		if eff.type == DamageType.FIRE then
			eff.tmpid = self:addTemporaryValue("global_speed_add", self:callTalent(self.T_ELEMENTAL_HARMONY, "fireSpeed"))
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
	name = "HEALING_NEXUS", image = "talents/healing_nexus.png",
	desc = "Healing Nexus",
	long_desc = function(self, eff) return ("All healing done to the target is instead redirected to %s by %d%%."):format(eff.src.name, eff.pct * 100, eff.src.name) end,
	type = "physical",
	subtype = { nature=true, heal=true },
	status = "detrimental",
	parameters = { pct = 1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "PSIONIC_BIND", image = "effects/psionic_bind.png",
	desc = "Immobilized",
	long_desc = function(self, eff) return "Immobilized by telekinetic forces." end,
	type = "physical",
	subtype = { telekinesis=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is bound by telekinetic forces!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# shakes free of the telekinetic binding", "-Paralyzed" end,
	activate = function(self, eff)
		--eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		--self:removeParticles(eff.particle)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "IMPLODING", image = "talents/implode.png",
	desc = "Imploding (slow)",
	long_desc = function(self, eff) return ("Slowed by 50%% and taking %d crushing damage per turn."):format( eff.power) end,
	type = "physical",
	subtype = { telekinesis=true, slow=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is being crushed.", "+Imploding" end,
	on_lose = function(self, err) return "#Target# shakes off the crushing forces.", "-Imploding" end,
	activate = function(self, eff)
		if core.shader.allow("distort") then eff.particle = self:addParticles(Particles.new("gravity_well2", 1, {radius=1})) end
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.5)
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "FREE_ACTION", image = "effects/free_action.png",
	desc = "Free Action",
	long_desc = function(self, eff) return ("The target gains %d%% stun, daze and pinning immunity."):format(eff.power * 100) end,
	type = "physical",
	subtype = { nature=true },
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
	name = "ADRENALINE_SURGE", image = "talents/adrenaline_surge.png",
	desc = "Adrenaline Surge",
	long_desc = function(self, eff) return ("The target's combat damage is improved by %d and it an continue to fight past the point of exhaustion, supplementing life for stamina."):format(eff.power) end,
	type = "physical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# feels a surge of adrenaline." end,
	on_lose = function(self, err) return "#Target#'s adrenaline surge has come to an end." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDSIDE_BONUS", image = "talents/blindside.png",
	desc = "Blindside Bonus",
	long_desc = function(self, eff) return ("The target has appeared out of nowhere! It's defense is boosted by %d."):format(eff.defenseChange) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { defenseChange=10 },
	activate = function(self, eff)
		eff.defenseChangeId = self:addTemporaryValue("combat_def", eff.defenseChange)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defenseChangeId)
	end,
}

newEffect{
	name = "OFFBALANCE",
	desc = "Off-balance",
	long_desc = function(self, eff) return ("Badly off balance. Global damage is reduced by 15%.") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Off-balance" end,
	on_lose = function(self, err) return nil, "-Off-balance" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("numbed", 15)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.speedid)
	end,
}

newEffect{
	name = "OFFGUARD",
	desc = "Off-guard", image = "talents/precise_strikes.png",
	long_desc = function(self, eff) return ("Badly off guard. Attackers gain a 10% bonus to physical critical strike chance and physical critcal strike power.") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Off-guard" end,
	on_lose = function(self, err) return nil, "-Off-guard" end,
	activate = function(self, eff)
		eff.crit_vuln = self:addTemporaryValue("combat_crit_vulnerable", 10) -- increases chance to be crit
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_crit_vulnerable", eff.crit_vuln)
	end,
}

newEffect{
	name = "SLOW_MOVE",
	desc = "Slow movement", image = "talents/slow.png",
	long_desc = function(self, eff) return ("Movement speed is reduced by %d%%."):format(eff.power*100) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Slow movement" end,
	on_lose = function(self, err) return nil, "-Slow movement" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "WEAKENED",
	desc = "Weakened", image = "talents/ruined_earth.png",
	long_desc = function(self, eff) return ("The target has been weakened, reducing all damage inflicted by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# has been weakened." end,
	on_lose = function(self, err) return "#Target#'s is no longer weakened." end,
	activate = function(self, eff)
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "LOWER_FIRE_RESIST",
	desc = "Lowered fire resistance",
	long_desc = function(self, eff) return ("The target fire resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to fire.", "+Low. fire resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to fire.", "-Low. fire resist" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.FIRE]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_COLD_RESIST",
	desc = "Lowered cold resistance",
	long_desc = function(self, eff) return ("The target cold resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to cold.", "+Low. cold resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to cold.", "-Low. cold resist" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.COLD]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_NATURE_RESIST",
	desc = "Lowered nature resistance",
	long_desc = function(self, eff) return ("The target nature resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to nature.", "+Low. nature resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to nature.", "-Low. nature resist" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.NATURE]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_PHYSICAL_RESIST",
	desc = "Lowered physical resistance",
	long_desc = function(self, eff) return ("The target physical resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to physical.", "+Low. physical resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to physical.", "-Low. physical resist" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "CURSED_WOUND", image = "talents/slash.png",
	desc = "Cursed Wound",
	long_desc = function(self, eff) return ("The target's has a cursed wound, reducing healing by %d%%."):format(-eff.healFactorChange * 100) end,
	type = "physical",
	subtype = { wound=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = { healFactorChange=-0.1 },
	on_gain = function(self, err) return "#Target# has a cursed wound!", "+Cursed Wound" end,
	on_lose = function(self, err) return "#Target# no longer has a cursed wound.", "-Cursed Wound" end,
	activate = function(self, eff)
		eff.healFactorId = self:addTemporaryValue("healing_factor", eff.healFactorChange)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healFactorId)
	end,
	on_merge = function(self, old_eff, new_eff)
		-- add the remaining healing reduction spread out over the new duration
		old_eff.healFactorChange = math.max(-0.75, (old_eff.healFactorChange / old_eff.totalDuration) * old_eff.dur + new_eff.healFactorChange)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)

		self:removeTemporaryValue("healing_factor", old_eff.healFactorId)
		old_eff.healFactorId = self:addTemporaryValue("healing_factor", old_eff.healFactorChange)
		game.logSeen(self, "%s has re-opened a cursed wound!", self.name:capitalize())

		return old_eff
	end,
}

newEffect{
	name = "LUMINESCENCE",
	desc = "Luminescence ", image = "talents/infusion__sun.png",
	long_desc = function(self, eff) return ("The target has been revealed, reducing its stealth power by %d."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, light=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# has been illuminated.", "+Luminescence" end,
	on_lose = function(self, err) return "#Target# is no longer illuminated.", "-Luminescence" end,
	activate = function(self, eff)
		eff.stealthid = self:addTemporaryValue("inc_stealth", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stealth", eff.stealthid)
	end,
}

newEffect{
	name = "SPELL_DISRUPTION", image = "talents/mana_clash.png",
	desc = "Spell Disruption",
	long_desc = function(self, eff) return ("The target has a %d%% chance to fail any spell it casts and a chance each turn to lose spell sustains."):format(eff.cur_power) end,
	type = "physical",
	subtype = { antimagic=true },
	status = "detrimental",
	parameters = { power=10, max=50 },
	on_gain = function(self, err) return "#Target#'s magic has been disrupted." end,
	on_lose = function(self, err) return "#Target#'s is no longer disrupted." end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("spell_failure", old_eff.tmpid)
		old_eff.cur_power = math.min(old_eff.cur_power + new_eff.power, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("spell_failure", old_eff.cur_power)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("spell_failure", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("spell_failure", eff.tmpid)
	end,
}

newEffect{
	name = "RESONANCE", image = "talents/alchemist_protection.png",
	desc = "Resonance",
	long_desc = function(self, eff) return ("+%d%% %s damage."):format(eff.dam, DamageType:get(eff.damtype).name) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { dam=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target# resonates with the damage.", "+Resonance" end,
	on_lose = function(self, err) return "#Target# is no longer resonating.", "-Resonance" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {[eff.damtype]=eff.dam})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "THORN_GRAB", image = "talents/thorn_grab.png",
	desc = "Thorn Grab",
	long_desc = function(self, eff) return ("The target is encased in thorny vines, dealing %d nature damage each turn and reducing its speed by %d%%."):format(eff.dam, eff.speed*100) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { dam=10, speed=20 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.speed)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.NATURE).projector(eff.src or self, self.x, self.y, DamageType.NATURE, eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "LEAVES_COVER", image = "talents/leaves_tide.png",
	desc = "Leaves Cover",
	long_desc = function(self, eff) return ("%d%% chance to fully absorb any damaging actions."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is protected by a layer of thick leaves.", "+Leaves Cover" end,
	on_lose = function(self, err) return "#Target# cover of leaves falls apart.", "-Leaves Cover" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("cancel_damage_chance", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("cancel_damage_chance", eff.tmpid)
	end,
}

newEffect{ -- Note: This effect is cancelled by EFF_DISARMED
	name = "DUAL_WEAPON_DEFENSE", image = "talents/dual_weapon_defense.png",
	desc = "Parrying",
	deflectchance = function(self, eff) -- The last partial deflect has a reduced chance to happen
		if self:attr("encased_in_ice") or self:hasEffect(self.EFF_DISARMED) then return 0 end
		return util.bound(eff.deflects>=1 and eff.chance or eff.chance*math.mod(eff.deflects,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("Parrying melee attacks: Has a %d%% chance to deflect up to %d damage from the next %0.1f attack(s)."):format(self.tempeffect_def.EFF_DUAL_WEAPON_DEFENSE.deflectchance(self, eff),eff.dam, math.max(eff.deflects,1))
	end,
	charges = function(self, eff) return math.ceil(eff.deflects) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10,dam = 1, deflects = 1},
	activate = function(self, eff)
--		if self:attr("disarmed") or not self:hasDualWeapon() then eff.dur = 0 return end
		if self:attr("disarmed") or not self:hasDualWeapon() then
			eff.dur = 0 self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) return
			end
		eff.dam = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDamageChange")
		eff.deflects = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDeflects")
		eff.chance = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDeflectChance")
		if eff.dam <= 0 or eff.deflects <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BLOCKING", image = "talents/block.png",
	desc = "Blocking",
	long_desc = function(self, eff) return ("Absorbs %d damage from the next blockable attack."):format(eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
	do_block = function(type, dam, eff, self, src)
		local dur_inc = 0
		local crit_inc = 0
		local nb = 1
		if self:knowTalent(self.T_RIPOSTE) then
			local t = self:getTalentFromId(self.T_RIPOSTE)
			dur_inc = t.getDurInc(self, t)
			crit_inc = t.getCritInc(self, t)
			nb = nb + dur_inc
		end
		local b = false
		if eff.d_types[type] then b = true end
		if not b then return dam end
		if not self:knowTalent(self.T_ETERNAL_GUARD) then eff.dur = 0 end
		local amt = util.bound(dam - eff.power, 0, dam)
		local blocked = dam - amt
		local shield = self:hasShield()
		if shield and shield.on_block and shield.on_block.fct then shield.on_block.fct(shield, self, src, type, dam, eff) end
		if eff.properties.br then
			self:heal(blocked, src)
			game:delayedLogMessage(self, src, "block_heal", "#CRIMSON##Source# heals from blocking with %s shield!", string.his_her(self))
		end
		if eff.properties.ref and src.life then DamageType.defaultProjector(src, src.x, src.y, type, blocked, tmp, true) end
		if (self:knowTalent(self.T_RIPOSTE) or amt == 0) and src.life then src:setEffect(src.EFF_COUNTERSTRIKE, (1 + dur_inc) * (src.global_speed or 1), {power=eff.power, no_ct_effect=true, src=self, crit_inc=crit_inc, nb=nb}) if eff.properties.sb then if src:canBe("disarm") then src:setEffect(src.EFF_DISARMED, 3, {apply_power=self:combatPhysicalpower()}) else game.logSeen(target, "%s resists the disarming attempt!", src.name:capitalize()) end end end-- specify duration here to avoid stacking for high speed attackers
		return amt
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("block", eff.power)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.ctdef = self:addTemporaryValue("combat_def_ct", eff.power)
		if eff.properties.sp then eff.spell = self:addTemporaryValue("combat_spellresist", eff.power) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("block", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_def_ct", eff.ctdef)
		if eff.properties.sp then self:removeTemporaryValue("combat_spellresist", eff.spell) end
	end,
}

newEffect{
	name = "COUNTER_ATTACKING", image = "talents/counter_attack.png",
	desc = "Counter Attacking",
	counterchance = function(self, eff) --The last partial counter attack has a reduced chance to happen
		if self:attr("encased_in_ice") or self:hasEffect(self.EFF_DISARMED) then return 0 end
		return util.bound(eff.counterattacks>=1 and eff.chance or eff.chance*math.mod(eff.counterattacks,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("Countering melee attacks: Has a %d%% chance to get an automatic counter attack when avoiding a melee attack. (%0.1f counters remaining)"):format(self.tempeffect_def.EFF_COUNTER_ATTACKING.counterchance(self, eff), math.max(eff.counterattacks,1))
	end,
	charges = function(self, eff) return math.ceil(eff.counterattacks) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10, counterattacks = 1},
	activate = function(self, eff)
		if self:attr("disarmed") then eff.dur = 0 return end
		eff.counterattacks = self:callTalent(self.T_COUNTER_ATTACK,"getCounterAttacks")
		eff.chance = self:callTalent(self.T_COUNTER_ATTACK,"counterchance")
		if eff.counterattacks <= 0 or eff.chance <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "DEFENSIVE_GRAPPLING", image = "talents/defensive_throw.png",
	desc = "Grappling Defensively",
	throwchance = function(self, eff) -- the last partial defensive throw has a reduced chance to happen
		if not self:isUnarmed() or self:attr("encased_in_ice") then return 0 end	-- Must be unarmed
		return util.bound(eff.throws>=1 and eff.chance or eff.chance*math.mod(eff.throws,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("Has a %d%% chance to counter attack with a defensive throw when avoiding a melee attack, possibly throwing the target to the ground and stunning it. (%0.1f throws remaining)"):format(self.tempeffect_def.EFF_DEFENSIVE_GRAPPLING.throwchance(self, eff), math.max(eff.throws,1))
	end,
	charges = function(self, eff) return math.ceil(eff.throws) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10, throws = 1},
	activate = function(self, eff)
		if not self:isUnarmed() then eff.dur = 0 self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING) return end
--		if not self:isUnarmed() then eff.dur = 0 return end
		eff.throws = self:callTalent(self.T_DEFENSIVE_THROW,"getThrows")
		eff.chance = self:callTalent(self.T_DEFENSIVE_THROW,"getchance")
		if eff.throws <= 0 or eff.chance <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "COUNTERSTRIKE", image = "effects/counterstrike.png",
	desc = "Counterstrike",
	long_desc = function(self, eff) return "Vulnerable to deadly counterstrikes. Next melee attack will inflict double damage." end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, "+Counter" end,
	on_lose = function(self, eff) return nil, "-Counter" end,
	onStrike = function(self, eff, dam, src)
		eff.nb = eff.nb - 1
		if eff.nb <= 0 then self:removeEffect(self.EFF_COUNTERSTRIKE) end

		if self.x and src.x and core.fov.distance(self.x, self.y, src.x, src.y) >= 5 then
			game:setAllowedBuild("rogue_skirmisher", true)
		end

		return dam * 2
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("counterstrike", 1)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.crit = self:addTemporaryValue("combat_crit_vulnerable", eff.crit_inc or 0)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("counterstrike", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_crit_vulnerable", eff.crit)
	end,
}

newEffect{
	name = "RAVAGE", image = "talents/ravage.png",
	desc = "Ravage",
	long_desc = function(self, eff)
		local ravaged = "each turn."
		if eff.ravage then ravaged = "and is losing one physical effect turn." end
		return ("The target is being ravaged by distortion, taking %0.2f physical damage %s"):format(eff.dam, ravaged)
	end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {dam=1, distort=0},
	on_gain = function(self, err) return  nil, "+Ravage" end,
	on_lose = function(self, err) return "#Target# is no longer being ravaged." or nil, "-Ravage" end,
	on_timeout = function(self, eff)
		if eff.ravage then
			-- Go through all physical effects
			local effs = {}
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained techniques
			for tid, act in pairs(self.sustain_talents) do
				if act then
					local talent = self:getTalentFromId(tid)
					if talent.type[1]:find("^technique/") then effs[#effs+1] = {"talent", tid} end
				end
			end

			if #effs > 0 then
				local eff = rng.tableRemove(effs)
				if eff[1] == "effect" then
					self:removeEffect(eff[2])
				else
					self:forceUseTalent(eff[2], {ignore_energy=true})
				end
			end
		end
		self:setEffect(self.EFF_DISTORTION, 2, {power=eff.distort})
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.dam)
	end,
	activate = function(self, eff)
		self:setEffect(self.EFF_DISTORTION, 2, {power=eff.distort})
		if eff.ravage then
			game.logSeen(self, "#LIGHT_RED#%s is being ravaged by distortion!", self.name:capitalize())
			eff.dam = eff.dam * 1.5
		end
		local particle = Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=220, bM=255, am=35, aM=90, radius=0.2, density=15, life=28, instop=40})
		if core.shader.allow("distort") then particle:setSub("gravity_well2", 1, {radius=1}) end
		eff.particle = self:addParticles(particle)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DISTORTION", image = "talents/maelstrom.png",
	desc = "Distortion",
	long_desc = function(self, eff) return ("The target has recently taken distortion damage, is vulnerable to distortion effects, and has its physical resistance decreased by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {power=0},
	on_gain = function(self, err) return  nil, "+Distortion" end,
	on_lose = function(self, err) return "#Target# is no longer distorted." or nil, "-Distortion" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=-eff.power})
	end,

}

newEffect{
	name = "DISABLE", image = "talents/cripple.png",
	desc = "Disable",
	long_desc = function(self, eff) return ("The target is disabled, reducing movement speed by %d%% and accuracy by %d."):format(eff.speed * 100, eff.atk) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { speed=0.15, atk=10 },
	on_gain = function(self, err) return "#Target# is disabled.", "+Disabled" end,
	on_lose = function(self, err) return "#Target# is not disabled anymore.", "-Disabled" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", -eff.speed)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
		self:removeTemporaryValue("combat_atk", eff.atkid)
	end,
}

newEffect{
	name = "ANGUISH", image = "talents/agony.png",
	desc = "Anguish",
	long_desc = function(self, eff) return ("The target is in extreme anguish, preventing them from making tactical decisions, and reducing Willpower by %d and Cunning by %d."):format(eff.will, eff.cun) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { will=5, cun=5 },
	on_gain = function(self, err) return "#Target# is in anguish.", "+Anguish" end,
	on_lose = function(self, err) return "#Target# is no longer in anguish.", "-Anguish" end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("inc_stats", {[Stats.STAT_WIL]=-eff.will, [Stats.STAT_CUN]=-eff.cun})
--		if self.ai_state then eff.ai = self:addTemporaryValue("ai_state", {forbid_tactical=1}) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.sid)
--		if eff.ai then self:removeTemporaryValue("ai_state", eff.ai) end
	end,
}

newEffect{
	name = "FAST_AS_LIGHTNING", image = "talents/fast_as_lightning.png",
	desc = "Fast As Lightning",
	long_desc = function(self, eff) return ("The target is so fast it may blink throught obstacles if moving in the same direction for over two turns."):format() end,
	type = "physical",
	subtype = { speed=true },
	status = "beneficial",
	parameters = { },
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	on_gain = function(self, err) return "#Target# is speeding up.", "+Fast As Lightning" end,
	on_lose = function(self, err) return "#Target# is slowing down.", "-Fast As Lightning" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_NATURE", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Nature",
	long_desc = function(self, eff) return ("Immune to physical effects.") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "spell_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "STEAMROLLER", image = "talents/steamroller.png",
	desc = "Steamroller",
	long_desc = function(self, eff) return ("Resets Rush cooldown if killed.") end,
	type = "physical",
	subtype = { status=true },
	status = "detrimental",
	parameters = { },
	activate = function(self, eff)
		self.reset_rush_on_death = eff.src
	end,
	deactivate = function(self, eff)
		self.reset_rush_on_death = nil
	end,
}


newEffect{
	name = "STEAMROLLER_USER", image = "talents/steamroller.png",
	desc = "Steamroller",
	long_desc = function(self, eff) return ("Grants a +%d%% damage bonus."):format(eff.buff) end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { buff=20 },
	on_merge = function(self, old_eff, new_eff)
		new_eff.buff = math.min(100, old_eff.buff + new_eff.buff)
		self:removeTemporaryValue("inc_damage", old_eff.buffid)
		new_eff.buffid = self:addTemporaryValue("inc_damage", {all=new_eff.buff})
		return new_eff
	end,
	activate = function(self, eff)
		eff.buffid = self:addTemporaryValue("inc_damage", {all=eff.buff})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.buffid)
	end,
}

newEffect{
	name = "SPINE_OF_THE_WORLD", image = "talents/spine_of_the_world.png",
	desc = "Spine of the World",
	long_desc = function(self, eff) return ("Immune to physical effects.") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target# become impervious to physical effects.", "+Spine of the World" end,
	on_lose = function(self, err) return "#Target# is less impervious to physical effects.", "-Spine of the World" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "physical_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "FUNGAL_BLOOD", image = "talents/fungal_blood.png",
	desc = "Fungal Blood",
	long_desc = function(self, eff) return ("You have %d fungal energies stored. Release them to heal by using the Fungal Blood prodigy."):format(eff.power) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return nil, "+Fungal Blood" end,
	on_lose = function(self, err) return nil, "-Fungal Blood" end,
	on_merge = function(self, old_eff, new_eff)
		new_eff.power = new_eff.power + old_eff.power
		return new_eff
	end,
	on_timeout = function(self, eff)
		eff.power = util.bound(eff.power * 0.9, 0, eff.power - 10)
	end,
}

newEffect{
	name = "MUCUS", image = "talents/mucus.png",
	desc = "Mucus",
	long_desc = function(self, eff) return ("You lay mucus where you walk."):format() end,
	type = "physical",
	subtype = { mucus=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return nil, "+Mucus" end,
	on_lose = function(self, err) return nil, "-Mucus" end,
	on_timeout = function(self, eff)
		self:callTalent(self.T_MUCUS, nil, self.x, self.y, self:getTalentLevel(self.T_MUCUS) >=4 and 1 or 0, eff)
	end,
}

newEffect{
	name = "CORROSIVE_NATURE", image = "talents/corrosive_nature.png",
	desc = "Corrosive Nature",
	long_desc = function(self, eff) return ("Acid damage increased by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "beneficial",
	parameters = { power=1, bonus_level=1},
	charges = function(self, eff) return math.round(eff.power) end,
	on_gain = function(self, err) return "#Target#'s acid damage is more potent.", "+Corrosive Nature" end,
	on_lose = function(self, err) return "#Target#'s acid damage is no longer so potent.", "-Corrosive Nature" end,
	on_merge = function(self, eff, new_eff)
		if game.turn < eff.last_update + 10 then return eff end -- update once a turn
		local t = self:getTalentFromId(self.T_CORROSIVE_NATURE)
		eff.dur = t.getDuration(self, t)
		if eff.bonus_level >=5 then return eff end
		game.logSeen(self, "%s's corrosive nature intensifies!",self.name:capitalize())
		eff.last_update = game.turn
		eff.bonus_level = eff.bonus_level + 1
		eff.power = t.getAcidDamage(self, t, eff.bonus_level)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.ACID]=eff.power})
		return eff
	end,
	activate = function(self, eff)
		eff.power = self:callTalent(self.T_CORROSIVE_NATURE, "getAcidDamage")
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.ACID]=eff.power})
		eff.last_update = game.turn
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
	end,
}

newEffect{
	name = "NATURAL_ACID", image = "talents/natural_acid.png",
	desc = "Natural Acid",
	long_desc = function(self, eff) return ("Nature damage increased by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "beneficial",
	parameters = { power=1, bonus_level=1},
	charges = function(self, eff) return math.round(eff.power) end,
	on_gain = function(self, err) return "#Target#'s nature damage is more potent.", "+Natural Acid" end,
	on_lose = function(self, err) return "#Target#'s nature damage is no longer so potent.", "-Nature Acid" end,
	on_merge = function(self, eff, new_eff)
		if game.turn < eff.last_update + 10 then return eff end -- update once a turn
		local t = self:getTalentFromId(self.T_NATURAL_ACID)
		eff.dur = t.getDuration(self, t)
		if eff.bonus_level >=5 then return eff end
		game.logSeen(self, "%s's natural acid becomes more concentrated!",self.name:capitalize())
		eff.last_update = game.turn
		eff.bonus_level = eff.bonus_level + 1
		eff.power = t.getNatureDamage(self, t, eff.bonus_level)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.NATURE]=eff.power})
		return eff
	end,
	activate = function(self, eff)
		eff.power = self:callTalent(self.T_NATURAL_ACID, "getNatureDamage")
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.NATURE]=eff.power})
		eff.last_update = game.turn
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
	end,
}

newEffect{
	name = "CORRODE", image = "talents/blightzone.png",
	desc = "Corrode",
	long_desc = function(self, eff) return ("The target is corroded, reducing their accuracy by %d, their armor by %d, and their defense by %d."):format(eff.atk, eff.armor, eff.defense) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = { atk=5, armor=5, defense=10 }, no_ct_effect = true,
	on_gain = function(self, err) return "#Target# is corroded." end,
	on_lose = function(self, err) return "#Target# has shook off the effects of their corrosion." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_atk", -eff.atk)
		self:effectTemporaryValue(eff, "combat_armor", -eff.armor)
		self:effectTemporaryValue(eff, "combat_def", -eff.defense)
	end,
}

newEffect{
	name = "SLIPPERY_MOSS", image = "talents/slippery_moss.png",
	desc = "Slippery Moss",
	long_desc = function(self, eff) return ("The target is covered in slippery moss. Each time it tries to use a talent there is %d%% chance of failure."):format(eff.fail) end,
	type = "physical",
	subtype = { moss=true, nature=true },
	status = "detrimental",
	parameters = {fail=5},
	on_gain = function(self, err) return "#Target# is covered in slippery moss!", "+Slippery Moss" end,
	on_lose = function(self, err) return "#Target# is free from the slippery moss.", "-Slippery Moss" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.fail)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}

newEffect{
	name = "JUGGERNAUT", image = "talents/juggernaut.png",
	desc = "Juggernaut",
	long_desc = function(self, eff) return ("Reduces physical damage received by %d%% and provides %d%% chances to ignore critial hits."):format(eff.power, eff.crits) end,
	type = "physical",
	subtype = { superiority=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# hardens its skin.", "+Juggernaut" end,
	on_lose = function(self, err) return "#Target#'s skin returns to normal.", "-Juggernaut" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("stone_skin", 1, {density=4}))
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=eff.power})
		self:effectTemporaryValue(eff, "ignore_direct_crits", eff.crits)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "NATURE_REPLENISHMENT", image = "talents/meditation.png",
	desc = "Natural Replenishment",
	long_desc = function(self, eff) return ("The target has been directly exposed to arcane energies and has responded by reasserting it's connection to nature, restoring %0.1f Equilibrium per turn."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = {power=1},
	on_gain = function(self, err) return ("#Target# defiantly reasserts %s connection to nature!"):format(string.his_her(self)), "+Nature Replenishment" end,
	on_lose = function(self, err) return "#Target# stops restoring Equilibrium.", "-Nature Replenishment" end,
	on_timeout = function(self, eff)
		self:incEquilibrium(-eff.power)
	end,
}


newEffect{
	name = "BERSERKER_RAGE", image = "talents/berserker.png",
	desc = "Berserker Rage",
	long_desc = function(self, eff) return ("Increases critical hit chance by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	decrease = 0, no_remove = true,
	parameters = {power=1},
	charges = function(self, eff) return ("%0.1f%%"):format(eff.power) end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.power)
	end,
}


newEffect{
	name = "RELENTLESS_FURY", image = "talents/relentless_fury.png",
	desc = "Relentless Fury",
	long_desc = function(self, eff) return ("Increases stamina regeneration by %d, movement and attack speed by %d%%."):format(eff.stamina, eff.speed) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = {stamina=1, speed=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stamina_regen", eff.stamina)
		self:effectTemporaryValue(eff, "movement_speed", eff.speed/100)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.speed/100)
	end,
}

local normalize_direction = function(direction)
	local pi2 = math.pi * 2
	while direction > pi2 do
		direction = direction - pi2
	end
	while direction < 0 do
		direction = direction + pi2
	end
	return direction
end

local in_angle = function(angle, min, max)
	if min <= max then
		return min <= angle and angle <= max
	else
		return min <= angle or angle <= max
	end
end

newEffect {
	name = "SKIRMISHER_DIRECTED_SPEED",
	desc = "Directed Speed",
	type = "physical",
	subtype = {speed = true},
	parameters = {
		-- Movement direction in radians.
		direction = 0,
		-- Allowed deviation from movement direction in radians.
		leniency = math.pi * 0.1,
		-- Movement speed bonus
		move_speed_bonus = 1.00
	},
	status = "beneficial",
	on_lose = function(self, eff) return "#Target# loses speed.", "-Directed Speed" end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		local angle_start = normalize_direction(math.atan2(self.y - eff.start_y, self.x - eff.start_x))
		local angle_last = normalize_direction(math.atan2(self.y - eff.last_y, self.x - eff.last_x))
		if ((self.x ~= eff.start_x or self.y ~= eff.start_y) and
				not in_angle(angle_start, eff.min_angle_start, eff.max_angle_start)) or
			((self.x ~= eff.last_x or self.y ~= eff.last_y) and
			 not in_angle(angle_last, eff.min_angle_last, eff.max_angle_last))
		then
			self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
		end
		eff.last_x = self.x
		eff.last_y = self.y
		eff.min_angle_last = normalize_direction(angle_last - eff.leniency_last)
		eff.max_angle_last = normalize_direction(angle_last + eff.leniency_last)
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", eff.move_speed_bonus)
		eff.leniency_last = math.max(math.pi * 0.25, eff.leniency)

		eff.start_x = self.x
		eff.start_y = self.y
		eff.min_angle_start = normalize_direction(eff.direction - eff.leniency)
		eff.max_angle_start = normalize_direction(eff.direction + eff.leniency)
		eff.last_x = self.x
		eff.last_y = self.y
		eff.min_angle_last = normalize_direction(eff.direction - eff.leniency_last)
		eff.max_angle_last = normalize_direction(eff.direction + eff.leniency_last)

		-- AI won't use talents while active.
		if self.ai_state then
			self:effectTemporaryValue(eff, "ai_state", {no_talents=1})
		end
	end,
	long_desc = function(self, eff)
		return ([[Target is currently moving with %d%% in a single direction. Stopping or changing directions will remove this effect.]])
		:format(eff.move_speed_bonus * 100)
	end,
}

-- If they don't have stun, stun them. If they do, increase its
-- duration.
newEffect {
	name = "SKIRMISHER_STUN_INCREASE",
	desc = "Stun Lengthen",
	type = "physical",
	subtype = {stun = true},
	status = "detrimental",
	on_gain = function(self, eff)
		local stun = self:hasEffect(self.EFF_STUNNED)
		if stun and stun.dur and stun.dur > 1 then
			return ("#Target# is stunned further! (now %d turns)"):format(stun.dur), "Stun Lengthened"
		end
	end,
	activate = function(self, eff)
		local stun = self:hasEffect(self.EFF_STUNNED)
		if stun then
			stun.dur = stun.dur + eff.dur
		else
			self:setEffect(self.EFF_STUNNED, eff.dur, {})
		end
		self:removeEffect(self.EFF_SKIRMISHER_STUN_INCREASE)
	end,
}

newEffect {
	name = "SKIRMISHER_ETERNAL_WARRIOR",
	desc = "Eternal Warrior",
	image = "talents/skirmisher_the_eternal_warrior.png",
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {
		-- Resist all increase
		res=.5,
		-- Resist caps increase
		cap=.5,
		-- Maximum stacking applications
		max=5
	},
	on_gain = function(self, err) return nil, "+Eternal Warrior" end,
	on_lose = function(self, err) return nil, "-Eternal Warrior" end,
	long_desc = function(self, eff)
		return ("The target stands strong, increasing all resistances %0.1f%% and resistance caps by %0.1f%%."):
		format(eff.res, eff.cap)
	end,
	activate = function(self, eff)
		eff.res_id = self:addTemporaryValue("resists", {all = eff.res})
		eff.cap_id = self:addTemporaryValue("resists_cap", {all = eff.cap})
	end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("resists", old_eff.res_id)
			self:removeTemporaryValue("resists_cap", old_eff.cap_id)
		new_eff.res = math.min(new_eff.res + old_eff.res, new_eff.res * new_eff.max)
		new_eff.cap = math.min(new_eff.cap + old_eff.cap, new_eff.cap * new_eff.max)
		new_eff.res_id = self:addTemporaryValue("resists", {all = new_eff.res})
		new_eff.cap_id = self:addTemporaryValue("resists_cap", {all = new_eff.cap})
		return new_eff
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.res_id)
		self:removeTemporaryValue("resists_cap", eff.cap_id)
	end,
}

newEffect {
	name = "SKIRMISHER_TACTICAL_POSITION",
	desc = "Tactical Position",
	type = "physical",
	subtype = {tactic = true},
	status = "beneficial",
	parameters = {combat_physcrit = 10},
	long_desc = function(self, eff)
		return ([[The target has relocated to a favorable position, giving them +%d%% physical critical chance.]])
		:format(eff.combat_physcrit)
	end,
	on_gain = function(self, eff) return "#Target# is poised to strike!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.combat_physcrit)
	end,
}

newEffect {
	name = "SKIRMISHER_DEFENSIVE_ROLL",
	desc = "Defensive Roll",
	type = "physical",
	subtype = {tactic = true},
	status = "beneficial",
	parameters = {
		-- percent of all damage to ignore
		reduce = 50
	},
	on_gain = function(self, eff) return "#Target# rolls to avoid some damage!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "incoming_reduce", eff.reduce)
	end,
	long_desc = function(self, eff)
		return ([[The target is in a defensive roll, ignoring %d%% of all incoming damage.]])
		:format(eff.reduce)
	end,
}

newEffect {
	name = "SKIRMISHER_TRAINED_REACTIONS_COOLDOWN",
	desc = "Trained Reactions Cooldown",
	type = "other",
	subtype = {cooldown = true},
	status = "detrimental",
	no_stop_resting = true,
	on_lose = function(self, eff) return "#LIGHT_BLUE##Target# may dodge again.", "+Trained Reactions" end,
	long_desc = function(self, eff)
		return "Trained Reactions may not trigger."
	end,
}

newEffect {
	name = "SKIRMISHER_SUPERB_AGILITY",
	desc = "Superb Agility",
	image = "talents/skirmisher_superb_agility.png",
	type = "physical",
	subtype = {speed = true},
	status = "beneficial",
	parameters = {
		global_speed_add = 0.1,
	},
	on_gain = function(self, eff) return "#Target# has sped up!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "global_speed_add", eff.global_speed_add)
	end,
	long_desc = function(self, eff)
		return ([[The target's reactions have quickened, giving +%d%% global speed.]])
		:format(eff.global_speed_add * 100)
	end,
}
