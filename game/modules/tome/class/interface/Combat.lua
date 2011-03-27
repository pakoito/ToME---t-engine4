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

require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Chat = require "engine.Chat"
local Target = require "engine.Target"
local Talents = require "engine.interface.ActorTalents"

--- Interface to add ToME combat system
module(..., package.seeall, class.make)

--- Checks what to do with the target
-- Talk ? attack ? displace ?
function _M:bumpInto(target)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		if target.encounterAttack and self.player then self:onWorldEncounter(target) return end
		return self:useTalent(self.T_ATTACK, nil, nil, nil, target)
	elseif reaction >= 0 then
		-- Talk ?
		if self.player and target.can_talk then
			local chat = Chat.new(target.can_talk, target, self)
			chat:invoke()
			if target.can_talk_only_once then target.can_talk = nil end
		elseif target.player and self.can_talk then
			local chat = Chat.new(self.can_talk, self, target)
			chat:invoke()
			if target.can_talk_only_once then target.can_talk = nil end
		elseif self.move_others and not target.cant_be_moved then
			if target.move_others and self ~= game.player then return end

			-- Displace
			local tx, ty, sx, sy = target.x, target.y, self.x, self.y
			target.x = nil target.y = nil
			self.x = nil self.y = nil
			target:move(sx, sy, true)
			self:move(tx, ty, true)
		end
	end
end

--- Makes the death happen!
--[[
The ToME combat system has the following attributes:
- attack: increases chances to hit against high defense
- defense: increases chances to miss against high attack power
- armor: direct reduction of damage done
- armor penetration: reduction of target's armor
- damage: raw damage done
]]
function _M:attackTarget(target, damtype, mult, noenergy)
	local speed, hit = nil, false
	local sound, sound_miss = nil, nil

	-- Break before we do the blow, because it might start step up, we dont want to insta-cancel it
	self:breakStepUp()

	if self:attr("feared") then
		if not noenergy then
			self:useEnergy(game.energy_to_act * speed)
			self.did_energy = true
		end
		game.logSeen(self, "%s is too afraid to attack.", self.name:capitalize())
		return false
	end

	-- Cancel stealth early if we are noticed
	if self:isTalentActive(self.T_STEALTH) and target:canSee(self) then
		self:useTalent(self.T_STEALTH)
		self.changed = true
		game.logPlayer(self, "%s notices you at the last moment!", target.name:capitalize())
	end

	if target and target:hasEffect(self.EFF_DOMINATED) and target.dominatedSource and target.dominatedSource == self then
		-- target is being dominated by self
		mult = (mult or 1) * (target.dominatedDamMult or 1)
	end

	-- Change attack type if using gems
	if not damtype and self:getInven(self.INVEN_GEM) then
		local gems = self:getInven(self.INVEN_GEM)
		local types = {}
		for i = 1, #gems do
			if gems[i] and gems[i].attack_type then types[#types+1] = gems[i].attack_type end
		end
		if #types > 0 then
			damtype = rng.table(types)
		end
	end

	local break_stealth = false
	if not self:attr("disarmed") and not self:isUnarmed() then
		-- All weapons in main hands
		if self:getInven(self.INVEN_MAINHAND) then
			for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
				if o.combat and not o.archery then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, o.combat, damtype, mult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = o.combat.sound
					elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
					if not o.combat.no_stealth_break then break_stealth = true end
				end
			end
		end
		-- All weapons in off hands
		-- Offhand attacks are with a damage penalty, that can be reduced by talents
		if self:getInven(self.INVEN_OFFHAND) then
			local offmult = self:getOffHandMult(mult)
			for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
				if o.combat and not o.archery then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, o.combat, damtype, offmult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = o.combat.sound
					elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
					if not o.combat.no_stealth_break then break_stealth = true end
				end
			end
		end
	end

	-- Barehanded ?
	if not speed and self.combat then
		print("[ATTACK] attacking with innate combat")
		local s, h = self:attackTargetWith(target, self.combat, damtype, mult)
		speed = math.max(speed or 0, s)
		hit = hit or h
		if hit and not sound then sound = self.combat.sound
		elseif not hit and not sound_miss then sound_miss = self.combat.sound_miss end
		if not self.combat.no_stealth_break then break_stealth = true end
	end

	-- Mount attack ?
	local mount = self:hasMount()
	if mount and mount.mount.attack_with_rider and math.floor(core.fov.distance(self.x, self.y, target.x, target.y)) <= 1 then
		mount.mount.actor:attackTarget(target, nil, nil, nil)
	end

	-- We use up our own energy
	if speed and not noenergy then
		self:useEnergy(game.energy_to_act * speed)
		self.did_energy = true
	end

	if sound then game:playSoundNear(self, sound)
	elseif sound_miss then game:playSoundNear(self, sound_miss) end

	-- cleave second attack
	if self:knowTalent(self.T_CLEAVE) then
		local t = self:getTalentFromId(self.T_CLEAVE)
		t.on_attackTarget(self, t, target, multiplier)
	end

	-- Cancel stealth!
	if break_stealth then self:breakStealth() end
	self:breakLightningSpeed()
	self:breakGatherTheThreads()
	return hit
end

--- Computes a logarithmic chance to hit, opposing chance to hit to chance to miss
-- This will be used for melee attacks, physical and spell resistance
function _M:checkHit(atk, def, min, max, factor)
	print("checkHit", atk, def)
	if atk == 0 then atk = 1 end
	local hit = nil
	factor = factor or 5

	local one = 1 / (1 + math.exp(-(atk - def) / 7))
	local two = 0
	if atk + def ~= 0 then two = atk / (atk + def) end
	hit = 50 * (one + two)

	hit = util.bound(hit, min or 5, max or 95)
	print("=> chance to hit", hit)
	return rng.percent(hit), hit
end

--- Try to totally evade an attack
function _M:checkEvasion(target)
	if not target:attr("evasion") then return end

	local evasion = target:attr("evasion")
	print("checkEvasion", evasion, target.level, self.level)
	evasion = evasion * (target.level / self.level)
	print("=> evasion chance", evasion)
	return rng.percent(evasion)
end

--- Attacks with one weapon
function _M:attackTargetWith(target, weapon, damtype, mult)
	damtype = damtype or weapon.damtype or DamageType.PHYSICAL
	mult = mult or 1

	-- Does the blow connect? yes .. complex :/
	local atk, def = self:combatAttack(weapon), target:combatDefense()
	if not self:canSee(target) then atk = atk / 3 end
	local dam, apr, armor = self:combatDamage(weapon), self:combatAPR(weapon), target:combatArmor()
	print("[ATTACK] to ", target.name, " :: ", dam, apr, armor, def, "::", mult)

	if target:knowTalent(target.T_DUCK_AND_DODGE) then
		local diff = util.bound((self.size_category or 3) - (target.size_category or 2), 0, 5)
		def = def + diff * target:getTalentLevelRaw(target.T_DUCK_AND_DODGE) * 1.2
	end

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	local evaded = false
	if self:checkEvasion(target) then
		evaded = true
		game.logSeen(target, "%s evades %s.", target.name:capitalize(), self.name)
	elseif self:checkHit(atk, def) then
		apr = 1-math.pow(0.99, apr)
		armor = 1-math.pow(0.99, armor)
		print("[ATTACK] raw dam", dam, "versus", armor, "with APR", apr)
		armor = math.max(0, armor - apr)
		dam = dam * (1 - armor)
		print("[ATTACK] after armor", dam)
		local damrange = self:combatDamageRange(weapon)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK] after range", dam)
		dam, crit = self:physicalCrit(dam, weapon, target)
		print("[ATTACK] after crit", dam)
		dam = dam * mult
		print("[ATTACK] after mult", dam)

		if weapon.inc_damage_type then
			for t, idt in pairs(weapon.inc_damage_type) do
				if target.type.."/"..target.subtype == t or target.type == t then dam = dam + dam * idt / 100 break end
			end
			print("[ATTACK] after inc by type", dam)
		end

		if crit then game.logSeen(self, "%s performs a critical strike!", self.name:capitalize()) end
		DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam))
		hitted = true
	else
		local srcname = game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
		game.logSeen(target, "%s misses %s.", srcname, target.name)
	end

	-- Spread diseases
	if hitted and self:knowTalent(self.T_CARRIER) and rng.percent(4 * self:getTalentLevelRaw(self.T_CARRIER)) then
		-- Use epidemic talent spreading
		local t = self:getTalentFromId(self.T_EPIDEMIC)
		t.do_spread(self, t, target)
	end

	-- Melee project
	if hitted and not target.dead and weapon.melee_project then for typ, dam in pairs(weapon.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end
	if hitted and not target.dead then for typ, dam in pairs(self.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end

	-- Weapon of light cast
	if hitted and not target.dead and self:knowTalent(self.T_WEAPON_OF_LIGHT) and self:isTalentActive(self.T_WEAPON_OF_LIGHT) then
		local dam = 7 + self:getTalentLevel(self.T_WEAPON_OF_LIGHT) * self:combatSpellpower(0.092)
		DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, dam)
		self:incPositive(-3)
		if self:getPositive() <= 0 then
			self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true})
		end
	end

	-- Shadow cast
	if hitted and not target.dead and self:knowTalent(self.T_SHADOW_COMBAT) and self:isTalentActive(self.T_SHADOW_COMBAT) and self:getMana() > 0 then
		local dam = 3 + self:getTalentLevel(self.T_SHADOW_COMBAT) * 2
		local mana = 1 + self:getTalentLevelRaw(self.T_SHADOW_COMBAT) / 1.5
		if self:getMana() > mana then
			DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
			self:incMana(-mana)
		end
	end

	-- Temporal cast
	if hitted and not target.dead and self:knowTalent(self.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) and weapon.talented and weapon.talented ~= "bow" and weapon.talented ~= "sling" then
		local t = self:getTalentFromId(self.T_WEAPON_FOLDING)
		local dam = t.getDamage(self, t)
		DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam)
	end

	-- Autospell cast
	if hitted and not target.dead and self:knowTalent(self.T_ARCANE_COMBAT) and self:isTalentActive(self.T_ARCANE_COMBAT) then
		local t = self:getTalentFromId(self.T_ARCANE_COMBAT)
		t.do_trigger(self, t, target)
	end

	-- On hit talent
	if hitted and not target.dead and weapon.talent_on_hit and next(weapon.talent_on_hit) then
		for tid, data in pairs(weapon.talent_on_hit) do
			if rng.percent(data.chance) then
				self:forceUseTalent(tid, {ignore_energy=true, force_target=target, force_level=data.level})
			end
		end
	end

	-- Shattering Impact
	if hitted and self:attr("shattering_impact") then
		local dam = dam * self.shattering_impact
		self:project({type="ball", radius=1, selffire=false}, target.x, target.y, DamageType.PHYSICAL, dam)
		self:incStamina(-15)
	end

	-- Onslaught
	if hitted and self:attr("onslaught") then
		local dir = util.getDir(target.x, target.y, self.x, self.y)
		local lx, ly = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
		local rx, ry = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if target:checkHit(self:combatAttack(weapon), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("knockback") then
			target:knockback(self.x, self.y, self:attr("onslaught"))
		end
		if lt and lt:checkHit(self:combatAttack(weapon), lt:combatPhysicalResist(), 0, 95, 10) and lt:canBe("knockback") then
			lt:knockback(self.x, self.y, self:attr("onslaught"))
		end
		if rt and rt:checkHit(self:combatAttack(weapon), rt:combatPhysicalResist(), 0, 95, 10) and rt:canBe("knockback") then
			rt:knockback(self.x, self.y, self:attr("onslaught"))
		end
	end

	-- Reactive target on hit damage
	if hitted then for typ, dam in pairs(target.on_melee_hit) do
		if dam > 0 then
			DamageType:get(typ).projector(target, self.x, self.y, typ, dam)
		end
	end end

	-- Acid splash
	if hitted and target:knowTalent(target.T_ACID_BLOOD) then
		local t = target:getTalentFromId(target.T_ACID_BLOOD)
		t.do_splash(target, t, self)
	end

	-- Bloodbath
	if hitted and crit and self:knowTalent(self.T_BLOODBATH) then
		local t = self:getTalentFromId(self.T_BLOODBATH)
		t.do_bloodbath(self, t)
	end

	-- Mortal Terror
	if hitted and not target.dead and self:knowTalent(self.T_MORTAL_TERROR) then
		local t = self:getTalentFromId(self.T_MORTAL_TERROR)
		t.do_terror(self, t, target, dam)
	end

	-- Mortal Terror
	if hitted and not target.dead and target:knowTalent(target.T_STONESKIN) and rng.percent(15) then
		target:setEffect(target.EFF_STONE_SKIN, 5, {power=target:getTalentLevelRaw(target.T_STONESKIN)*3})
	end

	-- Conduit (Psi)
	if hitted and not target.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) and self.use_psi_combat then
		local t =  self:getTalentFromId(self.T_CONDUIT)
		t.do_combat(self, t, target)
	end

	-- Exploit Weakness
	if hitted and not target.dead and self:knowTalent(self.T_EXPLOIT_WEAKNESS) and self:isTalentActive(self.T_EXPLOIT_WEAKNESS) then
		local t = self:getTalentFromId(self.T_EXPLOIT_WEAKNESS)
		t.do_weakness(self, t, target)
	end

	-- Special effect
	if hitted and not target.dead and weapon.special_on_hit and weapon.special_on_hit.fct then
		weapon.special_on_hit.fct(weapon, self, target)
	end

	-- Regen on being hit
	if hitted and not target.dead and target:attr("stamina_regen_on_hit") then target:incStamina(target.stamina_regen_on_hit) end
	if hitted and not target.dead and target:attr("mana_regen_on_hit") then target:incMana(target.mana_regen_on_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_on_hit") then target:incEquilibrium(-target.equilibrium_regen_on_hit) end

	-- Ablative Armor
	if hitted and not target.dead and target:attr("carbon_spikes") then
		if target.carbon_armor >= 1 then
			target.carbon_armor = target.carbon_armor - 1
		else
			-- Deactivate without loosing energy
			target:forceUseTalent(target.T_CARBON_SPIKES, {ignore_energy=true})
		end
	end

	-- Riposte!
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_RIPOSTE) and rng.percent(target:getTalentLevel(target.T_RIPOSTE) * (5 + target:getDex(5))) then
		game.logSeen(self, "%s ripostes!", target.name:capitalize())
		target:attackTarget(self, nil, nil, true)
	end

	-- Set Up
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:hasEffect(target.EFF_DEFENSIVE_MANEUVER) then
		local t = target:getTalentFromId(target.T_SET_UP)
		local power = t.getPower(target, t)
		self:setEffect(self.EFF_SET_UP, 2, {src = target, power=power})
	end

	-- Defensive Throw!
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_DEFENSIVE_THROW) and rng.percent(target:getTalentLevel(target.T_DEFENSIVE_THROW) * (5 + target:getCun(5))) then
		local t = target:getTalentFromId(target.T_DEFENSIVE_THROW)
		t.do_throw(target, self, t)
	end

	-- Counter Attack!
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_COUNTER_ATTACK) and rng.percent(target:getTalentLevel(target.T_COUNTER_ATTACK) * (5 + target:getCun(5))) then
		game.logSeen(self, "%s counters the attack!", target.name:capitalize())
		local t = target:getTalentFromId(target.T_COUNTER_ATTACK)
		local damage = t.getDamage(target, t)
		local hit = target:attackTarget(self, nil, damage, true)
	end

	-- Greater Weapon Focus
	local gwf = self:hasEffect(self.EFF_GREATER_WEAPON_FOCUS)
	if hitted and not target.dead and gwf and not gwf.inside and rng.percent(gwf.chance) then
		gwf.inside = true
		self:attackTargetWith(target, weapon, damtype, mult)
		gwf.inside = nil
	end

	-- Visual feedback
	if hitted then game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=target.blood_color}) end

	return self:combatSpeed(weapon), hitted
end

local weapon_talents = {
	sword = Talents.T_WEAPONS_MASTERY,
	axe =   Talents.T_WEAPONS_MASTERY,
	mace =  Talents.T_WEAPONS_MASTERY,
	knife = Talents.T_KNIFE_MASTERY,
	whip  = Talents.T_EXOTIC_WEAPONS_MASTERY,
	trident=Talents.T_EXOTIC_WEAPONS_MASTERY,
	bow =   Talents.T_BOW_MASTERY,
	sling = Talents.T_SLING_MASTERY,
	staff = Talents.T_STAFF_MASTERY,
}

--- Checks weapon training
function _M:combatCheckTraining(weapon)
	if not weapon.talented then return 0 end
	if not weapon_talents[weapon.talented] then return 0 end
	return self:getTalentLevel(weapon_talents[weapon.talented])
end

--- Gets the defense
function _M:combatDefense()
	local add = 0
	if self:hasDualWeapon() and self:knowTalent(self.T_DUAL_WEAPON_DEFENSE) then
		add = add + 4 + (self:getTalentLevel(self.T_DUAL_WEAPON_DEFENSE) * self:getDex()) / 12
	end
	if self:knowTalent(self.T_TACTICAL_EXPERT) then
		local t = self:getTalentFromId(self.T_TACTICAL_EXPERT)
		add = add + t.do_tact_update(self, t)
	end
	if self:knowTalent(self.T_STEADY_MIND) then
		local t = self:getTalentFromId(self.T_STEADY_MIND)
		add = add + t.getDefense(self, t)
	end
	return self.combat_def + (self:getDex() - 10) * 0.35 + add + (self:getLck() - 50) * 0.4
end

--- Gets the defense ranged
function _M:combatDefenseRanged()
	return self:combatDefense() + (self.combat_def_ranged or 0)
end

--- Gets the armor
function _M:combatArmor()
	local add = 0
	if self:hasHeavyArmor() and self:knowTalent(self.T_HEAVY_ARMOUR_TRAINING) then
		add = add + self:getTalentLevel(self.T_HEAVY_ARMOUR_TRAINING) * 1.4
	end
	if self:hasMassiveArmor() and self:knowTalent(self.T_MASSIVE_ARMOUR_TRAINING) then
		add = add + self:getTalentLevel(self.T_MASSIVE_ARMOUR_TRAINING) * 1.6
	end
	if self:knowTalent(self.T_PHYSICAL_CONDITIONING) then
		local t = self:getTalentFromId(self.T_PHYSICAL_CONDITIONING)
		add = add + t.getArmor(self, t)
	end
	if self:knowTalent(self.T_CARBON_SPIKES) and self:isTalentActive(self.T_CARBON_SPIKES) then
		add = add + self.carbon_armor
	end
	return self.combat_armor + add
end

--- Gets the attack
function _M:combatAttackBase(weapon, ammo)
	weapon = weapon or self.combat or {}
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (ammo and ammo.atk or 0) + (self:getLck() - 50) * 0.4
end
function _M:combatAttack(weapon, ammo)
	local stats
	if self.use_psi_combat then stats = (self:getWil(50) - 5) + (self:getCun(50) - 5)
	else stats = (self:getStr(50) - 5) + (self:getDex(50) - 5)
	end
	return self:combatAttackBase(weapon, ammo) + stats
end

--- Gets the attack using only strength
function _M:combatAttackStr(weapon, ammo)
	return self:combatAttackBase(weapon, ammo) + (self:getStr(100) - 10)
end

--- Gets the attack using only dexterity
function _M:combatAttackDex(weapon, ammo)
	return self:combatAttackBase(weapon, ammo) + (self:getDex(100) - 10)
end

--- Gets the attack using only magic
function _M:combatAttackMag(weapon, ammo)
	return self:combatAttackBase(weapon, ammo) + (self:getMag(100) - 10)
end

--- Gets the armor penetration
function _M:combatAPR(weapon)
	weapon = weapon or self.combat or {}
	local addapr = 0
	if weapon.talented and weapon.talented ~= "bow" and weapon.talented ~= "sling" and self:knowTalent(Talents.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) then
		local t = self:getTalentFromId(self.T_WEAPON_FOLDING)
		addapr = t.getArmorPen(self, t)
	end
	return self.combat_apr + (weapon.apr or 0) + addapr
end

--- Gets the weapon speed
function _M:combatSpeed(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_physspeed + (weapon.physspeed or 1)
end

--- Gets the crit rate
function _M:combatCrit(weapon)
	weapon = weapon or self.combat or {}
	local addcrit = 0
	if weapon.talented and weapon.talented == "knife" and self:knowTalent(Talents.T_LETHALITY) then
		addcrit = 1 + self:getTalentLevel(Talents.T_LETHALITY) * 1.3
	end
	return self.combat_physcrit + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + (weapon.physcrit or 1) + addcrit
end

--- Gets the damage range
function _M:combatDamageRange(weapon)
	weapon = weapon or self.combat or {}
	return (self.combat_damrange or 0) + (weapon.damrange or 1.1)
end


--- Scale damage values
-- This makes low damage values equal to what they should be and puts disminishing returns to super high values
function _M:rescaleDamage(dam)
	if dam <= 0 then return dam end
	return dam * (1 - math.log10(dam * 2) / 7)
end

--- Gets the damage
function _M:combatDamage(weapon)
	weapon = weapon or self.combat or {}

	local sub_con_to_str = false
	if weapon.talented and weapon.talented == "knife" and self:knowTalent(Talents.T_LETHALITY) then sub_con_to_str = true end

	local totstat = 0
	local dammod = weapon.dammod or {str=0.6}
	for stat, mod in pairs(dammod) do
		if sub_con_to_str and stat == "str" then stat = "cun" end
		if self.use_psi_combat and stat == "str" then stat = "wil" end
		if self.use_psi_combat and stat == "dex" then stat = "cun" end
		totstat = totstat + self:getStat(stat) * mod
	end
	if self.use_psi_combat then totstat = totstat * 0.6 end

	local add = 0
	if self:knowTalent(Talents.T_ARCANE_DESTRUCTION) then
		add = add + self:combatSpellpower() * self:getTalentLevel(Talents.T_ARCANE_DESTRUCTION) / 9
	end
	if self:isTalentActive(Talents.T_BLOOD_FRENZY) then
		add = add + self.blood_frenzy
	end
	if self:knowTalent(self.T_EMPTY_HAND) and weapon == self.combat then
		local t = self:getTalentFromId(self.T_EMPTY_HAND)
		add = add + t.getDamage(self, t)
	end

	if weapon == self.combat then
		-- Handles unarmed mastery
		talented_mod = math.sqrt(self:getTalentLevel(Talents.T_UNARMED_MASTERY) / 10) + 1 or 0
	else
		talented_mod = math.sqrt(self:combatCheckTraining(weapon) / 10) + 1
	end

	local power = math.max(self.combat_dam + (weapon.dam or 1) + add, 1)
	power = (math.sqrt(power / 10) - 1) * 0.8 + 1
	print(("[COMBAT DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
	return self:rescaleDamage(totstat / 1.5 * power * talented_mod)
end

--- Gets spellpower
function _M:combatSpellpower(mod)
	mod = mod or 1
	local add = 0
	if self:knowTalent(self.T_ARCANE_DEXTERITY) then
		add = add + (15 + self:getTalentLevel(self.T_ARCANE_DEXTERITY) * 5) * self:getDex() / 100
	end
	if self:knowTalent(self.T_SHADOW_CUNNING) then
		add = add + (15 + self:getTalentLevel(self.T_SHADOW_CUNNING) * 3) * self:getCun() / 100
	end
	if self:hasEffect(self.EFF_BLOODLUST) then
		add = add + self:hasEffect(self.EFF_BLOODLUST).dur
	end

	return (self.combat_spellpower + add + self:getMag()) * mod
end

--- Gets damage based on talent
function _M:combatTalentSpellDamage(t, base, max, spellpower_override)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (spellpower_override or self:combatSpellpower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod)
end

--- Gets weapon damage mult based on talent
function _M:combatTalentWeaponDamage(t, base, max, t2)
	if t2 then t2 = t2 / 2 else t2 = 0 end
	local diff = max - base
	local mult = base + diff * math.sqrt((self:getTalentLevel(t) + t2) / 5)
	print("[TALENT WEAPON MULT]", self:getTalentLevel(t), base, max, t2, mult)
	return mult
end

--- Gets the off hand multiplier
function _M:getOffHandMult(mult)
	local offmult = (mult or 1) / 2
	if self:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
		offmult = (mult or 1) / (2 - (self:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
	elseif self:knowTalent(Talents.T_CORRUPTED_STRENGTH) then
		offmult = (mult or 1) / (2 - (self:getTalentLevel(Talents.T_CORRUPTED_STRENGTH) / 9))
	end
	return offmult
end

--- Gets fatigue
function _M:combatFatigue()
	if self.fatigue < 0 then return 0 end
	return self.fatigue
end

--- Gets spellcrit
function _M:combatSpellCrit()
	return self.combat_spellcrit + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + 1
end

--- Gets spellspeed
function _M:combatSpellSpeed()
	return self.combat_spellspeed + 1
end

--- Computes physical crit for a damage
function _M:physicalCrit(dam, weapon, target)
	if self:isTalentActive(self.T_STEALTH) and self:knowTalent(self.T_SHADOWSTRIKE) then
		return dam * (1.5 + self:getTalentLevel(self.T_SHADOWSTRIKE) / 7), true
	end

	if target.stalker and target.stalker == self and self:knowTalent(self.T_STALK) then
		local t = self:getTalentFromId(self.T_STALK)
		if rng.percent(math.min(100, 40 + self:getTalentLevel(t) * 12)) then
			return dam * 1.5, true
		end
	end

	local chance = self:combatCrit(weapon)
	local crit = false
	if self:knowTalent(self.T_BACKSTAB) and target:attr("stunned") then chance = chance + self:getTalentLevel(self.T_BACKSTAB) * 10 end

	if target:attr("combat_critical") then
		chance = chance + target:attr("combat_critical")
	end
	if target:hasEffect(target.EFF_SET_UP) then
		local p = target:hasEffect(target.EFF_SET_UP)
		if p and p.src == self then
			chance = chance + p.power
		end
	end

	if target:knowTalent(target.T_PROBABILITY_WEAVING) and target:isTalentActive(target.T_PROBABILITY_WEAVING) then
		chance = chance - target:getTalentLevel(target.T_PROBABILITY_WEAVING)
	end
	if target:hasHeavyArmor() and target:knowTalent(target.T_HEAVY_ARMOUR_TRAINING) then
		chance = chance - target:getTalentLevel(target.T_HEAVY_ARMOUR_TRAINING) * 1.9
	end
	if target:hasMassiveArmor() and target:knowTalent(target.T_MASSIVE_ARMOUR_TRAINING) then
		chance = chance - target:getTalentLevel(target.T_MASSIVE_ARMOUR_TRAINING) * 1.5
	end

	chance = util.bound(chance, 0, 100)

	print("[PHYS CRIT %]", chance)
	if rng.percent(chance) then
		dam = dam * (1.5 + (self.combat_critical_power or 0) / 100)
		crit = true

	end
	return dam, crit
end

--- Computes spell crit for a damage
function _M:spellCrit(dam, add_chance)
	if self:isTalentActive(self.T_STEALTH) and self:knowTalent(self.T_SHADOWSTRIKE) then
		return dam * (1.5 + self:getTalentLevel(self.T_SHADOWSTRIKE) / 7), true
	end

	local chance = self:combatSpellCrit() + (add_chance or 0)
	local crit = false

	print("[SPELL CRIT %]", chance)
	if rng.percent(chance) then
		dam = dam * (1.5 + (self.combat_critical_power or 0) / 100)
		crit = true
		game.logSeen(self, "%s's spell looks more powerful!", self.name:capitalize())

		if self:isTalentActive(self.T_BLOOD_FURY) then
			local t = self:getTalentFromId(self.T_BLOOD_FURY)
			t.on_crit(self, t)
		end

		if self:isTalentActive(self.T_CORONA) then
			local t = self:getTalentFromId(self.T_CORONA)
			t.on_crit(self, t)
		end

	end
	return dam, crit
end

--- Do we get hit by our own AOE ?
function _M:spellFriendlyFire()
	local chance = self:getTalentLevelRaw(self.T_SPELL_SHAPING) * 20 + (self:getLck() - 50) * 0.2
	chance = 100 - chance
	print("[SPELL] friendly fire chance", chance)
	return chance
end

--- Gets mindpower
function _M:combatMindpower(mod)
	mod = mod or 1
	local add = 0
	return (self.combat_mindpower + add + self:getWil() * 0.7 + self:getCun() * 0.4) * mod
end

--- Gets damage based on talent
function _M:combatTalentMindDamage(t, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (self:combatMindpower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod)
end

--- Gets damage based on talent
function _M:combatTalentStatDamage(t, stat, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (self:getStat(stat))) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod)
end

--- Gets damage based on talent, stat, and interval
function _M:combatTalentIntervalDamage(t, stat, min, max)
	return self:rescaleDamage(min + (1 + (self:getStat(stat) / 100) * (max / 6.5 - 1)) * self:getTalentLevel(t))
end

--- Computes physical resistance
function _M:combatPhysicalResist()
	local add = 0
	if self:knowTalent(self.T_PHYSICAL_CONDITIONING) then
		local t = self:getTalentFromId(self.T_PHYSICAL_CONDITIONING)
		add = add + t.getPhysical(self, t)
	end
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + util.bound(self.money / (80 - self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 5), 0, self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 10)
	end
	return self.combat_physresist + (self:getCon() + self:getStr() + (self:getLck() - 50) * 0.5) * 0.35 + add
end

--- Computes spell resistance
function _M:combatSpellResist()
	local add = 0
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + util.bound(self.money / (60 - self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 5), 0, self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 10)
	end
	return self.combat_spellresist + (self:getMag() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.35 + add
end

--- Computes mental resistance
function _M:combatMentalResist()
	local add = 0
	if self:knowTalent(self.T_STEADY_MIND) then
		local t = self:getTalentFromId(self.T_STEADY_MIND)
		add = add + t.getMental(self, t)
	end
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + util.bound(self.money / (60 - self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 5), 0, self:getTalentLevelRaw(self.T_POWER_IS_MONEY) * 10)
	end
	return self.combat_mentalresist + (self:getCun() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.35 + add
end

--- Computes movement speed
function _M:combatMovementSpeed()
	local v = util.bound(1 + (self.movement_speed or 0), 0.2, 10)
	if v >= 1 then return v
	else return math.pow(0.4, 1 - v)
	end
end

--- Check if the actor has a gem bomb in quiver
function _M:hasAlchemistWeapon()
	if not self:getInven("QUIVER") then return nil, "no ammo" end
	local ammo = self:getInven("QUIVER")[1]
	if not ammo or not ammo.alchemist_power then
		return nil, "bad or no ammo"
	end
	return ammo
end

--- Check if the actor has a staff weapon
function _M:hasStaffWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon or weapon.subtype ~= "staff" then
		return nil
	end
	return weapon
end

--- Check if the actor has an axe weapon
function _M:hasAxeWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon or (weapon.subtype ~= "battleaxe" and weapon.subtype ~= "waraxe") then
		return nil
	end
	return weapon
end

--- Check if the actor has a two handed weapon
function _M:hasTwoHandedWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon or not weapon.twohanded then
		return nil
	end
	return weapon
end

--- Check if the actor has a shield
function _M:hasShield()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") or not self:getInven("OFFHAND") then return end
	local shield = self:getInven("OFFHAND")[1]
	if not shield or not shield.special_combat then
		return nil
	end
	return shield
end

-- Check if actor is unarmed
function _M:isUnarmed()
	local unarmed = true
	if not self:getInven("MAINHAND") or not self:getInven("OFFHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	local offweapon = self:getInven("OFFHAND")[1]
	if weapon or offweapon then
		unarmed = false
	end
	return unarmed
end

--- Check if the actor dual wields
function _M:hasDualWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") or not self:getInven("OFFHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	local offweapon = self:getInven("OFFHAND")[1]
	if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
		return nil
	end
	return weapon, offweapon
end

--- Check if the actor has a heavy armor
function _M:hasHeavyArmor()
	if not self:getInven("BODY") then return end
	local armor = self:getInven("BODY")[1]
	if not armor or armor.subtype ~= "heavy" then
		return nil
	end
	return armor
end

--- Check if the actor has a massive armor
function _M:hasMassiveArmor()
	if not self:getInven("BODY") then return end
	local armor = self:getInven("BODY")[1]
	if not armor or armor.subtype ~= "massive" then
		return nil
	end
	return armor
end

--- Check if the actor has a mount
function _M:hasMount()
	if not self:getInven("MOUNT") then return end
	local mount = self:getInven("MOUNT")[1]
	if not mount or mount.type ~= "mount" then
		return nil
	end
	return mount
end

-- Unarmed Combat; this handles grapple checks and building combo points

-- Builds Comob; reduces the cooldown on all unarmed abilities on cooldown by one
function _M:buildCombo()

	local duration = 3
	local power = 1
	-- Combo String bonuses
	if self:knowTalent(self.T_COMBO_STRING) then
		local t= self:getTalentFromId(self.T_COMBO_STRING)
		if rng.percent(t.getChance(self, t)) then
			power = 2
		end
		duration = 3 + math.ceil(t.getDuration(self, t))
	end
	-- Relentless Strike bonus
	if self:hasEffect(self.EFF_RELENTLESS_STRIKES) then
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1]:find("^technique/") then
				self.talents_cd[tid] = cd - 1
			end
		end
	end

	self:setEffect(self.EFF_COMBO, duration, {power=power})

end

function _M:getCombo(combo)
	local combo = 0
	local p = self:hasEffect(self.EFF_COMBO)
	if p then
		combo = p.cur_power
	end
		return combo
end

function _M:clearCombo()
	if self:hasEffect(self.EFF_COMBO) then
		self:removeEffect(self.EFF_COMBO)
	end
end

-- Check to see if the target is already being grappled; many talents have extra effects on grappled targets
function _M:isGrappled(source)
	local p = self:hasEffect(self.EFF_GRAPPLED)
	if p and p.src == source then
		return true
	else
		return false
	end
end

-- Breaks active grapples; called by a few talents that involve a lot of movement
function _M:breakGrapples()
	if self:hasEffect(self.EFF_GRAPPLING) then
		-- deactivating GRAPPLING will clear the target's Grappled effect as well
		self:removeEffect(self.EFF_GRAPPLING)
	end
end

-- grapple size check; compares attackers size and targets size
function _M:grappleSizeCheck(target)
	size = target.size_category - self.size_category
	if size > 1 then
		game.logSeen(target, "%s fails because %s is too big!", self.name:capitalize(), target.name:capitalize())
		return true
	else
		return false
	end
end

-- Starts the grapple
function _M:startGrapple(target)
	-- pulls boosted grapple effect from the clinch talent if known
	if self:knowTalent(self.T_CLINCH) then
		local t = self:getTalentFromId(self.T_CLINCH)
		power = t.getPower(self, t)
		duration = t.getDuration(self, t)
		hitbonus = self:getTalentLevel(t)/2
	else
		power = 5
		duration = 4
		hitbonus = 0
	end
	-- Breaks the grapple before reapplying
	if self:hasEffect(self.EFF_GRAPPLING) then
		-- deactivating GRAPPLING will clear the targets Grappled effect and various holds
		self:removeEffect(self.EFF_GRAPPLING, true)
		target:setEffect(target.EFF_GRAPPLED, duration, {src=self, power=power}, true)
		self:setEffect(self.EFF_GRAPPLING, duration, {src=target}, true)
		return true
	elseif target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - hitbonus) and target:canBe("pin") then
		target:setEffect(target.EFF_GRAPPLED, duration, {src=self, power=power})
		self:setEffect(self.EFF_GRAPPLING, duration, {src=target}, true)
		return true
	else
		game.logSeen(target, "%s resists the grapple!", target.name:capitalize())
		return false
	end
end