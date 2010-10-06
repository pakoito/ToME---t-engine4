-- ToME - Tales of Middle-Earth
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
		return self:attackTarget(target)
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
		elseif self.move_others then
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

	if not self:attr("disarmed") then
		-- All weapons in main hands
		if self:getInven(self.INVEN_MAINHAND) then
			for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
				if o.combat then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, o.combat, damtype, mult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = o.combat.sound
					elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
				end
			end
		end
		-- All wpeaons in off hands
		-- Offhand atatcks are with a damage penality, taht can be reduced by talents
		if self:getInven(self.INVEN_OFFHAND) then
			local offmult = (mult or 1) / 2
			if self:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
				offmult = (mult or 1) / (2 - (self:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
			elseif self:knowTalent(Talents.T_CORRUPTED_STRENGTH) then
				offmult = (mult or 1) / (2 - (self:getTalentLevel(Talents.T_CORRUPTED_STRENGTH) / 9))
			end
			for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
				if o.combat then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, o.combat, damtype, offmult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = o.combat.sound
					elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
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
	self:breakStealth()
	return hit
end

--- Computes a logarithmic chance to hit, opposing chance to hit to chance to miss
-- This will be used for melee attacks, physical and spell resistance
function _M:checkHit(atk, def, min, max, factor)
	print("checkHit", atk, def)
	if atk == 0 then atk = 1 end
	local hit = nil
	factor = factor or 5
	if atk > def then
		local d = atk - def
		hit = math.log10(1 + 5 * d / 50) * 100 + 50
	else
		local d = def - atk
		hit = -math.log10(1 + 5 * d / 50) * 100 + 50
	end
	hit = util.bound(hit, min or 5, max or 95)
	print("=> chance to hit", hit)
	return rng.percent(hit), hit
end

--- Try to totaly evade an attack
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
	print("[ATTACK] to ", target.name, " :: ", dam, apr, armor, "::", mult)

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	local evaded = false
	if self:checkEvasion(target) then
		evaded = true
		game.logSeen(target, "%s evades %s.", target.name:capitalize(), self.name)
	elseif self:checkHit(atk, def) then
		print("[ATTACK] raw dam", dam, "versus", armor, "with APR", apr)
		dam = math.max(0, dam - math.max(0, armor - apr))
		local damrange = self:combatDamageRange(weapon)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK] after range", dam)
		dam, crit = self:physicalCrit(dam, weapon, target)
		print("[ATTACK] after crit", dam)
		dam = dam * mult
		print("[ATTACK] after mult", dam)
		if crit then game.logSeen(self, "%s performs a critical stike!", self.name:capitalize()) end
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
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(self.T_WEAPON_OF_LIGHT)
			self.energy.value = old
		end
	end

	-- Shadow cast
	if hitted and not target.dead and self:knowTalent(self.T_SHADOW_COMBAT) and self:isTalentActive(self.T_SHADOW_COMBAT) and self:getMana() > 0 then
		local dam = 3 + self:getTalentLevel(self.T_SHADOW_COMBAT) * 2
		local mana = 1 + self:getTalentLevelRaw(t) / 1.5
		DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
		self:incMana(-mana)
	end

	-- Autospell cast
	if hitted and not target.dead and self:knowTalent(self.T_ARCANE_COMBAT) and self:isTalentActive(self.T_ARCANE_COMBAT) and rng.percent(20 + self:getTalentLevel(self.T_ARCANE_COMBAT) * (1 + self:getDex(9, true))) then
		local spells = {}
		if self:knowTalent(self.T_FLAME) then spells[#spells+1] = self.T_FLAME end
		if self:knowTalent(self.T_FLAMESHOCK) then spells[#spells+1] = self.T_FLAMESHOCK end
		if self:knowTalent(self.T_LIGHTNING) then spells[#spells+1] = self.T_LIGHTNING end
		if self:knowTalent(self.T_CHAIN_LIGHTNING) then spells[#spells+1] = self.T_CHAIN_LIGHTNING end
		local tid = rng.table(spells)
		if tid then
			print("[ARCANE COMBAT] autocast ",self:getTalentFromId(tid).name)
			local old_cd = self:isTalentCoolingDown(self:getTalentFromId(tid))
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(tid, nil, nil, nil, target)
			self.energy.value = old
			-- Do not setup a cooldown
			if not old_cd then
				self.talents_cd[tid] = nil
			end
			self.changed = true
		end
	end

	-- On hit talent
	if hitted and not target.dead and weapon.talent_on_hit and next(weapon.talent_on_hit) then
		for tid, data in pairs(weapon.talent_on_hit) do
			if rng.percent(data.chance) then
				local old = self.energy.value
				self.energy.value = 100000
				self:useTalent(tid, nil, data.level, true, target)
				self.energy.value = old
			end
		end
	end

	-- Shattering Impact
	if hitted and self:attr("shattering_impact") then
		local dam = dam * self.shattering_impact
		self:project({type="ball", radius=1, friendlyfire=false}, target.x, target.y, DamageType.PHYSICAL, dam)
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
		if rt and rt:checkHit(self:combatAttack(weapon), rt:combatPhysicalResist(), 0, 95, 10) and r+t:canBe("knockback") then
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

	-- Regen on being hit
	if hitted and not target.dead and target:attr("stamina_regen_on_hit") then target:incStamina(target.stamina_regen_on_hit) end
	if hitted and not target.dead and target:attr("mana_regen_on_hit") then target:incMana(target.mana_regen_on_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_on_hit") then target:incEquilibrium(-target.equilibrium_regen_on_hit) end

	-- Riposte!
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_RIPOSTE) and rng.percent(util.bound(target:getTalentLevel(target.T_RIPOSTE) * target:getDex(40), 10, 60)) then
		game.logSeen(self, "%s ripostes!", target.name:capitalize())
		target:attackTarget(self, nil, nil, true)
	end

	return self:combatSpeed(weapon), hitted
end

local weapon_talents = {
	sword = Talents.T_SWORD_MASTERY,
	axe =   Talents.T_AXE_MASTERY,
	mace =  Talents.T_MACE_MASTERY,
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
	return self.combat_armor + add
end

--- Gets the attack
function _M:combatAttack(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getStr(50) - 5) + (self:getDex(50) - 5) + (self:getLck() - 50) * 0.4
end

--- Gets the attack using only strength
function _M:combatAttackStr(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getStr(100) - 10) + (self:getLck() - 50) * 0.4
end

--- Gets the attack using only dexterity
function _M:combatAttackDex(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getDex(100) - 10) + (self:getLck() - 50) * 0.4
end

--- Gets the attack using only magic
function _M:combatAttackDex(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getMag(100) - 10) + (self:getLck() - 50) * 0.4
end

--- Gets the armor penetration
function _M:combatAPR(weapon)
	weapon = weapon or self.combat or {}
	return self.combat_apr + (weapon.apr or 0)
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

--- Gets the damage
function _M:combatDamage(weapon)
	weapon = weapon or self.combat or {}

	local sub_con_to_str = false
	if weapon.talented and weapon.talented == "knife" and self:knowTalent(Talents.T_LETHALITY) then sub_con_to_str = true end

	local totstat = 0
	local dammod = weapon.dammod or {str=0.6}
	for stat, mod in pairs(dammod) do
		if sub_con_to_str and stat == "str" then stat = "cun" end
		totstat = totstat + self:getStat(stat) * mod
	end

	local add = 0
	if self:knowTalent(Talents.T_ARCANE_DESTRUCTION) then
		add = add + self:combatSpellpower() * self:getTalentLevel(Talents.T_ARCANE_DESTRUCTION) / 9
	end
	if self:isTalentActive(Talents.T_BLOOD_FRENZY) then
		add = add + self.blood_frenzy
	end

	local talented_mod = math.sqrt(self:combatCheckTraining(weapon) / 10) + 1
	local power = math.max(self.combat_dam + (weapon.dam or 1) + add, 1)
	power = (math.sqrt(power / 10) - 1) * 0.8 + 1
	print(("[COMBAT DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
	return totstat / 1.5 * power * talented_mod
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
	return (base + (spellpower_override or self:combatSpellpower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod
end

--- Gets weapon damage mult based on talent
function _M:combatTalentWeaponDamage(t, base, max, t2)
	if t2 then t2 = t2 / 2 else t2 = 0 end
	local diff = max - base
	local mult = base + diff * math.sqrt((self:getTalentLevel(t) + t2) / 5)
	print("[TALENT WEAPON MULT]", self:getTalentLevel(t), base, max, t2, mult)
	return mult
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

	if target:hasHeavyArmor() and target:knowTalent(target.T_HEAVY_ARMOUR_TRAINING) then
		chance = chance - target:getTalentLevel(target.T_HEAVY_ARMOUR_TRAINING) * 1.9
	end
	if target:hasMassiveArmor() and target:knowTalent(target.T_MASSIVE_ARMOUR_TRAINING) then
		chance = chance - target:getTalentLevel(target.T_MASSIVE_ARMOUR_TRAINING) * 1.5
	end

	chance = util.bound(chance, 0, 100)

	print("[PHYS CRIT %]", chance)
	if rng.percent(chance) then
		dam = dam * (1.5 + (self.combat_critical_power or 0))
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
		dam = dam * 1.5
		crit = true
		game.logSeen(self, "%s's spell looks more powerful!", self.name:capitalize())
	end
	return dam, crit
end

--- Do we get hit by our own AOE ?
function _M:spellFriendlyFire()
	print("[SPELL] friendly fire chance", self:getTalentLevelRaw(self.T_SPELL_SHAPING) * 20 + (self:getLck() - 50) * 0.2)
	return not rng.percent(self:getTalentLevelRaw(self.T_SPELL_SHAPING) * 20 + (self:getLck() - 50) * 0.2)
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
	return (base + (self:combatMindpower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod
end

--- Computes physical resistance
function _M:combatPhysicalResist()
	return self.combat_physresist + (self:getCon() + self:getStr() + (self:getLck() - 50) * 0.5) * 0.25
end

--- Computes spell resistance
function _M:combatSpellResist()
	return self.combat_spellresist + (self:getMag() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.25
end

--- Computes mental resistance
function _M:combatMentalResist()
	return self.combat_mentalresist + (self:getCun() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.25
end

--- Computes movement speed
function _M:combatMovementSpeed()
	return self.movement_speed or 1
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
