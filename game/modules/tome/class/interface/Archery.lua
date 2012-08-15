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

require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Chat = require "engine.Chat"
local Target = require "engine.Target"
local Talents = require "engine.interface.ActorTalents"

--- Interface to add ToME archery combat system
module(..., package.seeall, class.make)

--- Look for possible archery targets
-- Take care of removing enough ammo
function _M:archeryAcquireTargets(tg, params)
	local weapon, ammo = self:hasArcheryWeapon()
	if not weapon then
		game.logPlayer(self, "You must wield a bow or a sling (%s)!", ammo)
		return nil
	end
	if not ammo or ammo.combat.shots_left <= 0 then
		game.logPlayer(self, "You do not have enough ammo left!")
		return nil
	end
	params = params or {}

	print("[ARCHERY ACQUIRE TARGETS WITH]", weapon.name, ammo.name)
	local realweapon = weapon
	weapon = weapon.combat

	local tg = tg or {}
	tg.type = tg.type or weapon.tg_type or ammo.combat.tg_type or tg.type or "bolt"

	if not tg.range then tg.range=weapon.range or 6 end
	tg.display = tg.display or {display='/'}
	tg.speed = (tg.speed or 10) + (ammo.combat.travel_speed or 0) + (weapon.travel_speed or 0) + (self.travel_speed or 0)
	print("[PROJECTILE SPEED] ::", tg.speed)
	local x, y = self:getTarget(tg)
	if not x or not y then return nil end

	-- Find targets to know how many ammo we use
	local targets = {}
	if params.one_shot then
		local a = ammo
		if not ammo.infinite then
			ammo.combat.shots_left = ammo.combat.shots_left - 1
		end
		if a then
			targets = {{x=x, y=y, ammo=a.combat}}
		end
	else
		local limit_shots = params.limit_shots

		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, game.level.map.ACTOR)
			if not target then return end
			if tx == self.x and ty == self.y then return end

			if limit_shots then
				if limit_shots <= 0 then return end
				limit_shots = limit_shots - 1
			end

			for i = 1, params.multishots or 1 do
				local a = ammo
				if not ammo.infinite then
					if ammo.combat.shots_left > 0 then ammo.combat.shots_left = ammo.combat.shots_left - 1
					else break
					end
				end
				if a then targets[#targets+1] = {x=tx, y=ty, ammo=a.combat}
				else break end
			end
		end)
	end

	if #targets > 0 then
		local sound = weapon.sound

		local speed = self:combatSpeed(weapon)
		print("[SHOOT] speed", speed or 1, "=>", game.energy_to_act * (speed or 1))
		self:useEnergy(game.energy_to_act * (speed or 1))

		if sound then game:playSoundNear(self, sound) end

--		if not ammo.infinite and (ammo.combat.shots_left < 10 or ammo:getNumber() == 50 or ammo:getNumber() == 40 or ammo:getNumber() == 25) then
--			game.logPlayer(self, "You only have %s left!", ammo:getName{do_color=true})
--		end

		return targets
	else
		return nil
	end
end

--- Archery projectile code
local function archery_projectile(tx, ty, tg, self, tmp)
	local DamageType = require "engine.DamageType"
	local weapon, ammo = tg.archery.weapon, tg.archery.ammo
	local talent = self:getTalentFromId(tg.talent_id)

	local target = game.level.map(tx, ty, game.level.map.ACTOR)
	if talent.archery_onreach then
		talent.archery_onreach(self, talent, tx, ty)
	end
	if not target then return end

	local damtype = tg.archery.damtype or ammo.damtype or DamageType.PHYSICAL
	local mult = tg.archery.mult or 1

	-- Does the blow connect? yes .. complex :/
	if tg.archery.use_psi_archery then self.use_psi_combat = true end
	local atk, def = self:combatAttackRanged(weapon, ammo), target:combatDefenseRanged()
	local dam, apr, armor = self:combatDamage(ammo), self:combatAPR(ammo), target:combatArmor()
	atk = atk + (tg.archery.atk or 0)
	dam = dam + (tg.archery.dam or 0)
	print("[ATTACK ARCHERY] to ", target.name, " :: ", dam, apr, armor, "::", mult)

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	if self:checkHit(atk, def) and (self:canSee(target) or self:attr("blind_fight") or rng.chance(3)) then
		apr = apr + (tg.archery.apr or 0)
		print("[ATTACK ARCHERY] raw dam", dam, "versus", armor, "with APR", apr)

		local pres = util.bound(target:combatArmorHardiness() / 100, 0, 1)
		armor = math.max(0, armor - apr)
		dam = math.max(dam * pres - armor, 0) + (dam * (1 - pres))
		print("[ATTACK ARCHERY] after armor", dam)

		local damrange = self:combatDamageRange(ammo)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK ARCHERY] after range", dam)

		if target:hasEffect(target.EFF_COUNTERSTRIKE) then
			dam = dam * 2
			local eff = target.tmp[target.EFF_COUNTERSTRIKE]
			eff.nb = eff.nb - 1
			if eff.nb == 0 then target:removeEffect(target.EFF_COUNTERSTRIKE) end
			print("[ATTACK] after counterstrike", dam)
		end

		if ammo and ammo.inc_damage_type then
			for t, idt in pairs(ammo.inc_damage_type) do
				if target.type.."/"..target.subtype == t or target.type == t then dam = dam + dam * idt / 100 break end
			end
			print("[ATTACK] after inc by type", dam)
		end

		dam, crit = self:physicalCrit(dam, ammo, target, atk, def, tg.archery.crit_chance or 0, tg.archery.crit_power or 0)
		print("[ATTACK ARCHERY] after crit", dam)

		dam = dam * mult
		print("[ATTACK ARCHERY] after mult", dam)

		if crit then game.logSeen(self, "#{bold}#%s performs a critical strike!#{normal}#", self.name:capitalize()) end

		-- Damage conversion?
		-- Reduces base damage but converts it into another damage type
		local conv_dam
		local conv_damtype
		if ammo and ammo.convert_damage then
			for typ, conv in pairs(ammo.convert_damage) do
				if dam > 0 then
					conv_dam = math.min(dam, dam * (conv / 100))
					conv_damtype = typ
					dam = dam - conv_dam
					if conv_dam > 0 then
						DamageType:get(conv_damtype).projector(self, target.x, target.y, conv_damtype, math.max(0, conv_dam))
					end
				end
			end
		end

		if weapon and weapon.convert_damage then
			for typ, conv in pairs(weapon.convert_damage) do
				if dam > 0 then
					conv_dam = math.min(dam, dam * (conv / 100))
					conv_damtype = typ
					dam = dam - conv_dam
					if conv_dam > 0 then
						DamageType:get(conv_damtype).projector(self, target.x, target.y, conv_damtype, math.max(0, conv_dam))
					end
				end
			end
		end

		DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam), tmp)

		game.level.map:particleEmitter(target.x, target.y, 1, "archery")
		hitted = true

		if talent.archery_onhit then talent.archery_onhit(self, talent, target, target.x, target.y) end
	else
		local srcname = game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
		game.logSeen(target, "%s misses %s.", srcname, target.name)
	end

	-- cross-tier effect for accuracy vs. defense
	local tier_diff = self:getTierDiff(atk, target:combatDefense(false, target:attr("combat_def_ct")))
	if hitted and not target.dead and tier_diff > 0 then
		local reapplied = false
		-- silence the apply message it if the target already has the effect
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.desc == "Off-guard" then
				reapplied = true
			end
		end
		target:setEffect(target.EFF_OFFGUARD, tier_diff, {}, reapplied)
	end

	-- Ranged project
	local weapon_ranged_project = weapon.ranged_project or {}
	local ammo_ranged_project = ammo.ranged_project or {}
	local self_ranged_project = self.ranged_project or {}
	local total_ranged_project = {}
	table.mergeAdd(total_ranged_project, weapon_ranged_project, true)
	table.mergeAdd(total_ranged_project, ammo_ranged_project, true)
	table.mergeAdd(total_ranged_project, self_ranged_project, true)
	if hitted and not target.dead then for typ, dam in pairs(total_ranged_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam, tmp)
		end
	end end

	if not tg.archery.hit_burst then
		-- Ranged project (burst)
		local weapon_burst_on_hit = weapon.burst_on_hit or {}
		local ammo_burst_on_hit = ammo.burst_on_hit or {}
		local self_burst_on_hit = self.burst_on_hit or {}
		local total_burst_on_hit = {}
		table.mergeAdd(total_burst_on_hit, weapon_burst_on_hit, true)
		table.mergeAdd(total_burst_on_hit, ammo_burst_on_hit, true)
		table.mergeAdd(total_burst_on_hit, self_burst_on_hit, true)
		if hitted and not target.dead then for typ, dam in pairs(total_burst_on_hit) do
			if dam > 0 then
				self:project({type="ball", radius=1, friendlyfire=false}, target.x, target.y, typ, dam)
				tg.archery.hit_burst = true
			end
		end end
	end

	-- Ranged project (burst on crit)
	if not tg.archery.crit_burst then
		local weapon_burst_on_crit = weapon.burst_on_crit or {}
		local ammo_burst_on_crit = ammo.burst_on_crit or {}
		local self_burst_on_crit = self.burst_on_crit or {}
		local total_burst_on_crit = {}
		table.mergeAdd(total_burst_on_crit, weapon_burst_on_crit, true)
		table.mergeAdd(total_burst_on_crit, ammo_burst_on_crit, true)
		table.mergeAdd(total_burst_on_crit, self_burst_on_crit, true)
		if hitted and crit and not target.dead then for typ, dam in pairs(total_burst_on_crit) do
			if dam > 0 then
				self:project({type="ball", radius=2, friendlyfire=false}, target.x, target.y, typ, dam)
				tg.archery.crit_burst = true
			end
		end end
	end

	-- Talent on hit
	if hitted and not target.dead and weapon and weapon.talent_on_hit and next(weapon.talent_on_hit) and not self.turn_procs.ranged_talent then
		for tid, data in pairs(weapon.talent_on_hit) do
			if rng.percent(data.chance) then
				self.turn_procs.ranged_talent = true
				self:forceUseTalent(tid, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=data.level, ignore_ressources=true})
			end
		end
	end

	-- Talent on hit...  AMMO!
	if hitted and not target.dead and ammo and ammo.talent_on_hit and next(ammo.talent_on_hit) and not self.turn_procs.ranged_talent then
		for tid, data in pairs(ammo.talent_on_hit) do
			if rng.percent(data.chance) then
				self.turn_procs.ranged_talent = true
				self:forceUseTalent(tid, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=data.level, ignore_ressources=true})
			end
		end
	end

	-- Special effect
	if hitted and weapon and weapon.special_on_hit and weapon.special_on_hit.fct and (not target.dead or weapon.special_on_hit.on_kill) then
		weapon.special_on_hit.fct(weapon, self, target)
	end

	-- Special effect... AMMO!
	if hitted and ammo and ammo.special_on_hit and ammo.special_on_hit.fct and (not target.dead or ammo.special_on_hit.on_kill) then
		ammo.special_on_hit.fct(ammo, self, target)
	end

	-- Special effect on crit
	if crit and weapon and weapon.special_on_crit and weapon.special_on_crit.fct and (not target.dead or weapon.special_on_crit.on_kill) then
		weapon.special_on_crit.fct(weapon, self, target)
	end

	-- Special effect on crit AMMO!
	if crit and ammo and ammo.special_on_crit and ammo.special_on_crit.fct and (not target.dead or ammo.special_on_crit.on_kill) then
		ammo.special_on_crit.fct(ammo, self, target)
	end

	-- Special effect on kill
	if hitted and weapon and weapon.special_on_kill and weapon.special_on_kill.fct and target.dead then
		weapon.special_on_kill.fct(weapon, self, target)
	end

	-- Special effect on kill A-A-A-AMMMO!
	if hitted and ammo and ammo.special_on_kill and ammo.special_on_kill.fct and target.dead then
		ammo.special_on_kill.fct(ammo, self, target)
	end

	-- Temporal cast
	if hitted and not target.dead and self:knowTalent(self.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) then
		local t = self:getTalentFromId(self.T_WEAPON_FOLDING)
		local dam = t.getDamage(self, t) * 2
		DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam, tmp)
		self:incParadox(- t.getParadoxReduction(self, t) * 2)
	end

	-- Conduit (Psi)
	if hitted and not target.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) and self.use_psi_combat then
		local t =  self:getTalentFromId(self.T_CONDUIT)
		--t.do_combat(self, t, target)
		local mult = 1 + 0.2*(self:getTalentLevel(t))
		local auras = self:isTalentActive(t.id)
		if auras.k_aura_on then
			local k_aura = self:getTalentFromId(self.T_KINETIC_AURA)
			local k_dam = mult * k_aura.getAuraStrength(self, k_aura)
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, k_dam, tmp)
		end
		if auras.t_aura_on then
			local t_aura = self:getTalentFromId(self.T_THERMAL_AURA)
			local t_dam = mult * t_aura.getAuraStrength(self, t_aura)
			DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, t_dam, tmp)
		end
		if auras.c_aura_on then
			local c_aura = self:getTalentFromId(self.T_CHARGED_AURA)
			local c_dam = mult * c_aura.getAuraStrength(self, c_aura)
			DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, c_dam, tmp)
		end
	end


	-- Regen on being hit
	if hitted and not target.dead and target:attr("stamina_regen_when_hit") then target:incStamina(target.stamina_regen_when_hit) end
	if hitted and not target.dead and target:attr("mana_regen_when_hit") then target:incMana(target.mana_regen_when_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_when_hit") then target:incEquilibrium(-target.equilibrium_regen_when_hit) end
	if hitted and not target.dead and target:attr("psi_regen_when_hit") then target:incPsi(target.psi_regen_when_hit) end
	if hitted and not target.dead and target:attr("hate_regen_when_hit") then target:incHate(target.hate_regen_when_hit) end

	-- Resource regen on hit
	if hitted and self:attr("stamina_regen_on_hit") then self:incStamina(self.stamina_regen_on_hit) end
	if hitted and self:attr("mana_regen_on_hit") then self:incMana(self.mana_regen_on_hit) end

	-- Ablative armor
	if hitted and not target.dead and target:attr("carbon_spikes") then
		if target.carbon_armor >= 1 then
			target.carbon_armor = target.carbon_armor - 1
		else
			-- Deactivate without loosing energy
			target:forceUseTalent(target.T_CARBON_SPIKES, {ignore_energy=true})
		end
	end

	-- Zero gravity
	if hitted and game.level.data.zero_gravity and rng.percent(util.bound(dam, 0, 100)) then
		target:knockback(self.x, self.y, math.ceil(math.log(dam)))
	end

	self.use_psi_combat = false
end

--- Shoot at one target
function _M:archeryShoot(targets, talent, tg, params)
	local weapon, ammo = self:hasArcheryWeapon()
	if not weapon then
		game.logPlayer(self, "You must wield a bow or a sling (%s)!", ammo)
		return nil
	end
	if self:attr("disarmed") then
		game.logPlayer(self, "You are disarmed!")
		return nil
	end
	print("[SHOOT WITH]", weapon.name, ammo.name)
	local realweapon = weapon
	weapon = weapon.combat

	local tg = tg or {}
	tg.type = tg.type or weapon.tg_type or ammo.combat.tg_type or tg.type or "bolt"
	tg.talent = tg.talent or talent

	if not tg.range then tg.range=weapon.range or 6 end
	tg.display = tg.display or {display=' ', particle="arrow", particle_args={tile="shockbolt/"..(ammo.proj_image or realweapon.proj_image):gsub("%.png$", "")}}
	tg.speed = (tg.speed or 10) + (ammo.combat.travel_speed or 0) + (weapon.travel_speed or 0) + (self.travel_speed or 0)
	tg.archery = params or {}
	tg.archery.weapon = weapon
	for i = 1, #targets do
		local tg = table.clone(tg)
		tg.archery.ammo = targets[i].ammo
		self:projectile(tg, targets[i].x, targets[i].y, archery_projectile)
	end
end

--- Check if the actor has a bow or sling and corresponding ammo
function _M:hasArcheryWeapon(type)
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return nil, "no shooter" end
	if not self:getInven("QUIVER") then return nil, "no ammo" end
	local weapon = self:getInven("MAINHAND")[1]
	local ammo = self:getInven("QUIVER")[1]
	if self.inven[self.INVEN_PSIONIC_FOCUS] then
		local pf_weapon = self:getInven("PSIONIC_FOCUS")[1]
		if pf_weapon and pf_weapon.archery then
			weapon = pf_weapon
		end
	end
	if not weapon or not weapon.archery then
		return nil, "no shooter"
	end
	if not ammo then
		return nil, "no ammo"
	else
		if not ammo.archery_ammo or weapon.archery ~= ammo.archery_ammo then
			return nil, "bad ammo"
		end
	end
	if type and weapon.archery ~= type then return nil, "bad type" end
	return weapon, ammo
end

--- Check if the actor has a bow or sling and corresponding ammo
function _M:hasAmmo(type)
	if not self:getInven("QUIVER") then return nil, "no ammo" end
	local ammo = self:getInven("QUIVER")[1]

	if not ammo then return nil, "no ammo" end
	if not ammo.archery_ammo then return nil, "bad ammo" end
	if not ammo.combat then return nil, "bad ammo" end
	if not ammo.combat.capacity then return nil, "bad ammo" end
	if type and ammo.archery_ammo ~= type then return nil, "bad type" end
	return ammo
end
