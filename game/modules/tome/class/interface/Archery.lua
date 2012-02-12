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
		game.logPlayer(self, "(%s)", ammo)
		return nil
	end
	params = params or {}

	print("[ARCHERY ACQUIRE TARGETS WITH]", weapon.name, ammo.name)
	local realweapon = weapon
	weapon = weapon.combat

	local tg = tg or {type="bolt"}
	tg.type = weapon.tg_type or ammo.combat.tg_type or tg.type

	if not tg.range then tg.range=weapon.range or 6 end
	tg.display = tg.display or {display='/'}
	tg.speed = (tg.speed or 6) * ((ammo.combat.travel_speed or 100) / 100) * (weapon.travel_speed or 100) / 100
	local x, y = self:getTarget(tg)
	if not x or not y then return nil end

	-- Find targets to know how many ammo we use
	local targets = {}
	if params.one_shot then
		if not ammo.combat.shots_left then return nil end
		if ammo.combat.shots_left == 0 then
			game.logPlayer(self, "You are out of ammo!")
			return nil
		end
		ammo.combat.shots_left = ammo.combat.shots_left - 1
		targets = {{x=x, y=y, ammo=ammo.combat}}
	else
		if not ammo.combat.shots_left then return nil end
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
				if ammo.combat.shots_left == 0 then break end
				ammo.combat.shots_left = ammo.combat.shots_left - 1
				targets[#targets+1] = {x=tx, y=ty, ammo=ammo.combat}
			end
		end)
	end

	if #targets > 0 then
		local sound = weapon.sound

		local speed = self:combatSpeed(weapon)
		print("[SHOOT] speed", speed or 1, "=>", game.energy_to_act * (speed or 1))
		self:useEnergy(game.energy_to_act * (speed or 1))

		if sound then game:playSoundNear(self, sound) end
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
	local atk, def = self:combatAttack(weapon, ammo), target:combatDefenseRanged()
	local armor = target:combatArmor()
	local dam = self:combatDamage(ammo) + self:combatDamage(weapon)
	local apr = self:combatAPR(ammo) + self:combatAPR(weapon)
	atk = atk + (tg.archery.atk or 0)
	dam = dam + (tg.archery.dam or 0)
	print("[ATTACK ARCHERY] to ", target.name, " :: ", dam, apr, armor, "::", mult)

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	if self:checkHit(atk, def, 0, self:getMaxAccuracy("physical", ammo)) and (self:canSee(target) or self:attr("blind_fight") or rng.chance(3)) then
		apr = apr + (tg.archery.apr or 0)
		print("[ATTACK ARCHERY] raw dam", dam, "versus", armor, "with APR", apr)

		local pres = util.bound(target:combatArmorHardiness() / 100, 0, 1)
		armor = math.max(0, armor - apr)
		dam = math.max(dam * pres - armor, 0) + (dam * (1 - pres))
		print("[ATTACK ARCHERY] after armor", dam)

		local pre_crit_dam = dam
		if tg.archery.crit_chance then self.combat_physcrit = self.combat_physcrit + tg.archery.crit_chance end
		dam, crit = self:physicalCrit(dam, weapon, target, atk, def)
		if tg.archery.crit_chance then self.combat_physcrit = self.combat_physcrit - tg.archery.crit_chance end
		print("[ATTACK ARCHERY] after crit", dam)

		dam = dam * mult
		print("[ATTACK ARCHERY] after mult", dam)

		if crit then
			game.logSeen(self, "#{bold}#%s performs a critical strike!#{normal}#", self.name:capitalize())
			if (weapon.concussion or ammo.concussion) then
				dam = pre_crit_dam
				self:doConcussion(dam, target, {weapon, ammo})
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
	local tier_diff = self:getTierDiff(atk, def)
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
	local total_ranged_project = {}
	table.mergeAdd(total_ranged_project, weapon_ranged_project, true)
	table.mergeAdd(total_ranged_project, ammo_ranged_project, true)
	if hitted and not target.dead then for typ, dam in pairs(total_ranged_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam, tmp)
		end
	end end

	-- Talent on hit
	if hitted and not target.dead and weapon and weapon.talent_on_hit and next(weapon.talent_on_hit) then
		self:doTalentOnHit(target, weapon)
	end

	-- Special effect
	if hitted and not target.dead and weapon and weapon.special_on_hit and weapon.special_on_hit.fct then
		weapon.special_on_hit.fct(weapon, self, target)
	end

	-- Temporal cast
	if hitted and not target.dead and self:knowTalent(self.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) then
		local t = self:getTalentFromId(self.T_WEAPON_FOLDING)
		local dam = t.getDamage(self, t)
		DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam, tmp)
		self:incParadox(- t.getParadoxReduction(self, t))
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
	if hitted and not target.dead and target:attr("stamina_regen_on_hit") then target:incStamina(target.stamina_regen_on_hit) end
	if hitted and not target.dead and target:attr("mana_regen_on_hit") then target:incMana(target.mana_regen_on_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_on_hit") then target:incEquilibrium(-target.equilibrium_regen_on_hit) end

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

	-- Savagery
	if hitted and crit and self:knowTalent(self.T_SAVAGERY) then
		local t = self:getTalentFromId(self.T_SAVAGERY)
		t.do_savagery(self, t)
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

	local tg = tg or {type="bolt"}
	tg.type = weapon.tg_type or ammo.combat.tg_type or tg.type
	tg.talent = tg.talent or talent

	if not tg.range then tg.range=weapon.range or 6 end
	tg.display = tg.display or {display=' ', particle="arrow", particle_args={tile="shockbolt/"..(ammo.proj_image or realweapon.proj_image):gsub("%.png$", "")}}
	tg.speed = (tg.speed or 6) * ((ammo.combat.travel_speed or 100) / 100) * (weapon.travel_speed or 100) / 100
	tg.archery = params or {}
	tg.archery.weapon = weapon
	local grids = nil
	for i = 1, #targets do
		local tg = table.clone(tg)
		tg.archery.ammo = targets[i].ammo
		self:projectile(tg, targets[i].x, targets[i].y, archery_projectile)
		if ammo.combat.lite then self:project(tg, targets[i].x, targets[i].y, DamageType.LITE, 1) end
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
		return nil, "Your quiver is empty."
	else
		if not ammo.archery_ammo or weapon.archery ~= ammo.archery_ammo or not ammo.combat then
			return nil, "bad ammo"
		end
	end
	if type and weapon.archery ~= type then return nil, "bad type" end
	return weapon, ammo
end

--- Check if the actor has a bow or sling
function _M:hasShooter(type)
	if not self:getInven("MAINHAND") then return nil, "no shooter" end
	local weapon = self:getInven("MAINHAND")[1]
	if self.inven[self.INVEN_PSIONIC_FOCUS] then
		local pf_weapon = self:getInven("PSIONIC_FOCUS")[1]
		if pf_weapon and pf_weapon.archery then
			weapon = pf_weapon
		end
	end
	if not weapon or not weapon.archery then
		return nil, "no shooter"
	end

	if type and weapon.archery ~= type then return nil, "bad type" end
	return weapon
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
	return ammo, "no problem"
end
