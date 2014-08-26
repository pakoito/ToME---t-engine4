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
function _M:bumpInto(target, x, y)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		if target.encounterAttack and self.player then self:onWorldEncounter(target, x, y) return end
		if game.player == self and ((not config.settings.tome.actor_based_movement_mode and game.bump_attack_disabled) or (config.settings.tome.actor_based_movement_mode and self.bump_attack_disabled)) then return end
		return self:useTalent(self.T_ATTACK, nil, nil, nil, target)
	elseif reaction >= 0 then
		-- Talk ? Bump ?
		if self.player and target.on_bump then
			target:on_bump(self)
		elseif self.player and target.can_talk then
			local chat = Chat.new(target.can_talk, target, self, {npc=target, player=self})
			chat:invoke()
			if target.can_talk_only_once then target.can_talk = nil end
		elseif target.player and self.can_talk then
			local chat = Chat.new(self.can_talk, self, target, {npc=self, player=target})
			chat:invoke()
			if target.can_talk_only_once then target.can_talk = nil end
		elseif self.move_others and not target.cant_be_moved then
			if target.move_others and self ~= game.player then return end

			-- Check we can both walk in the tile we will end up in
			local blocks = game.level.map:checkAllEntitiesLayersNoStop(target.x, target.y, "block_move", self)
			for kind, v in pairs(blocks) do if kind[1] ~= Map.ACTOR and v then return end end
			blocks = game.level.map:checkAllEntitiesLayersNoStop(self.x, self.y, "block_move", target)
			for kind, v in pairs(blocks) do if kind[1] ~= Map.ACTOR and v then return end end

			-- Displace
			local tx, ty, sx, sy = target.x, target.y, self.x, self.y
			target.x = nil target.y = nil
			self.x = nil self.y = nil

			target:move(sx, sy, true)
			self:move(tx, ty, true)
			if target.describeFloor then target:describeFloor(target.x, target.y, true) end
			if self.describeFloor then self:describeFloor(self.x, self.y, true) end

			if self:attr("bump_swap_speed_divide") then
				self:useEnergy(game.energy_to_act * self:combatMovementSpeed(x, y) / self:attr("bump_swap_speed_divide"))
				self.did_energy = true
			end
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
function _M:attackTarget(target, damtype, mult, noenergy, force_unharmed)
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

	if self:attr("terrified") and rng.percent(self:attr("terrified")) then
		if not noenergy then
			self:useEnergy(game.energy_to_act)
			self.did_energy = true
		end
		game.logSeen(self, "%s is too terrified to attack.", self.name:capitalize())
		return false
	end

	-- Cancel stealth early if we are noticed
	if self:isTalentActive(self.T_STEALTH) and target:canSee(self) then
		self:useTalent(self.T_STEALTH)
		self.changed = true
		if self.player then self:logCombat(target, "#Target# notices you at the last moment!") end
	end

	if target:isTalentActive(target.T_INTUITIVE_SHOTS) and rng.percent(target:callTalent(target.T_INTUITIVE_SHOTS, "getChance")) then
		local ret = target:callTalent(target.T_INTUITIVE_SHOTS, "proc", self)
		if ret then return false end
	end

	if not target.turn_procs.warding_weapon and target:knowTalent(target.T_WARDING_WEAPON) and target:getTalentLevelRaw(target.T_WARDING_WEAPON) >= 5
		and rng.percent(target:callTalent(target.T_WARDING_WEAPON, "getChance")) and target:getPsi() >= 15 then
		target:setEffect(target.EFF_WEAPON_WARDING, 1, {})
		target.turn_procs.warding_weapon = true
		target:incPsi(-15)
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
	elseif not damtype and self:attr("force_melee_damage_type") then
		damtype = self:attr("force_melee_damage_type")
	end

	local break_stealth = false

	local hd = {"Combat:attackTarget", target=target, damtype=damtype, mult=mult, noenergy=noenergy}
	if self:triggerHook(hd) then
		speed, hit, damtype, mult = hd.speed, hd.hit, hd.damtype, hd.mult
		if hd.stop then return hit end
	end

	if not speed and self:isTalentActive(self.T_GESTURE_OF_PAIN) then
		print("[ATTACK] attacking with Gesture of Pain")
		local t = self:getTalentFromId(self.T_GESTURE_OF_PAIN)
		if not t.preAttack(self, t, target) then return false end
		speed, hit = t.attack(self, t, target)
		break_stealth = true
	end

	local mean
	if not speed and not self:attr("disarmed") and not self:isUnarmed() and not force_unharmed then
		-- All weapons in main hands
		if self:getInven(self.INVEN_MAINHAND) then
			for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
				local combat = self:getObjectCombat(o, "mainhand")
				if combat and not o.archery then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, combat, damtype, mult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = combat.sound
					elseif not hit and not sound_miss then sound_miss = combat.sound_miss end
					if not combat.no_stealth_break then break_stealth = true end
				end
			end
		end
		-- All weapons in off hands
		-- Offhand attacks are with a damage penalty, that can be reduced by talents
		if self:getInven(self.INVEN_OFFHAND) then
			for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
				local offmult = self:getOffHandMult(o.combat, mult)
				local combat = self:getObjectCombat(o, "offhand")
				if o.special_combat and o.subtype == "shield" and self:knowTalent(self.T_STONESHIELD) then combat = o.special_combat end
				if combat and not o.archery then
					print("[ATTACK] attacking with", o.name)
					local s, h = self:attackTargetWith(target, combat, damtype, offmult)
					speed = math.max(speed or 0, s)
					hit = hit or h
					if hit and not sound then sound = combat.sound
					elseif not hit and not sound_miss then sound_miss = combat.sound_miss end
					if not combat.no_stealth_break then break_stealth = true end
				end
			end
		end
		mean = "weapon"
	end

	-- Barehanded ?
	if not speed and self.combat then
		print("[ATTACK] attacking with innate combat")
		local combat = self:getObjectCombat(nil, "barehand")
		local s, h = self:attackTargetWith(target, combat, damtype, mult)
		speed = math.max(speed or 0, s)
		hit = hit or h
		if hit and not sound then sound = combat.sound
		elseif not hit and not sound_miss then sound_miss = combat.sound_miss end
		if not combat.no_stealth_break then break_stealth = true end
		mean = "unharmed"
	end

	-- We use up our own energy
	if speed and not noenergy then
		self:useEnergy(game.energy_to_act * speed)
		self.did_energy = true
	end

	if sound then game:playSoundNear(self, sound)
	elseif sound_miss then game:playSoundNear(self, sound_miss) end

	game:playSoundNear(self, self.on_hit_sound or "actions/melee_hit_squish")
	if self.sound_moam and rng.chance(7) then game:playSoundNear(self, self.sound_moam) end

	-- cleave second attack
	if self:isTalentActive(self.T_CLEAVE) then
		local t = self:getTalentFromId(self.T_CLEAVE)
		t.on_attackTarget(self, t, target)
	end

	if self:attr("unharmed_attack_on_hit") then
		local v = self:attr("unharmed_attack_on_hit")
		self:attr("unharmed_attack_on_hit", -v)
		if rng.percent(60) then self:attackTarget(target, nil, 1, true, true) end
		self:attr("unharmed_attack_on_hit", v)
	end

	-- Cancel stealth!
	if break_stealth then self:breakStealth() end
	self:breakLightningSpeed()
	return hit
end

--- Determines the combat field to use for this item
function _M:getObjectCombat(o, kind)
	if kind == "barehand" then return self.combat end
	if not o then return nil end
	if kind == "mainhand" then return o.combat end
	if kind == "offhand" then return o.combat end
	return nil
end

--- Computes a logarithmic chance to hit, opposing chance to hit to chance to miss
-- This will be used for melee attacks, physical and spell resistance

function _M:checkHitOld(atk, def, min, max, factor)
	if atk < 0 then atk = 0 end
	if def < 0 then def = 0 end
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

--Tells the tier difference between two values
function _M:crossTierEffect(eff_id, apply_power, apply_save, use_given_e)
	local q = game.player:hasQuest("tutorial-combat-stats")
	if q and not q:isCompleted("final-lesson")then
		return
	end
	local ct_effect
	local save_for_effects = {
		physical = "combatPhysicalResist",
		magical = "combatSpellResist",
		mental = "combatMentalResist",
	}
	local cross_tier_effects = {
		combatPhysicalResist = self.EFF_OFFBALANCE,
		combatSpellResist = self.EFF_SPELLSHOCKED,
		combatMentalResist = self.EFF_BRAINLOCKED,
	}
	local e = self.tempeffect_def[eff_id]
	if not apply_power or not save_for_effects[e.type] then return end
	local save = self[apply_save or save_for_effects[e.type]](self, true)

	if use_given_e then
		ct_effect = self["EFF_"..e.name]
	else
		ct_effect = cross_tier_effects[save_for_effects[e.type]]
	end
	local dur = self:getTierDiff(apply_power, save)
	self:setEffect(ct_effect, dur, {})
end

function _M:getTierDiff(atk, def)
	atk = math.floor(atk)
	def = math.floor(def)
	return math.max(0, math.max(math.ceil(atk/20), 1) - math.max(math.ceil(def/20), 1))
end

--New, simpler checkHit that relies on rescaleCombatStats() being used elsewhere
function _M:checkHit(atk, def, min, max, factor, p)
	if atk < 0 then atk = 0 end
	if def < 0 then def = 0 end
	local min = min or 0
	local max = max or 100
	if game.player:hasQuest("tutorial-combat-stats") then
		min = 0
		max = 100
	end --ensures predictable combat for the tutorial
	print("checkHit", atk, def)
	local hit = math.ceil(50 + 2.5 * (atk - def))
	hit = util.bound(hit, min, max)
	print("=> chance to hit", hit)
	return rng.percent(hit), hit
end

--- Try to totally evade an attack
function _M:checkEvasion(target)
	if not target:attr("evasion") or self == target then return end
	if target:attr("no_evasion") then return end

	local evasion = target:attr("evasion")
	print("checkEvasion", evasion, target.level, self.level)
	print("=> evasion chance", evasion)
	return rng.percent(evasion)
end

function _M:getAccuracyEffect(weapon, atk, def, scale, max)
	max = max or 10000000
	scale = scale or 1
	return math.min(max, math.max(0, atk - def) * scale * (weapon.accuracy_effect_scale or 1))
end

function _M:isAccuracyEffect(weapon, kind)
	if not weapon then return false, "none" end
	local eff = weapon.accuracy_effect or weapon.talented
	return eff == kind, eff
end

--- Attacks with one weapon
function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
	damtype = damtype or (weapon and weapon.damtype) or DamageType.PHYSICAL
	mult = mult or 1

	if self:attr("force_melee_damtype") then
		damtype = self.force_melee_damtype
	end

	--Life Steal
	if weapon and weapon.lifesteal then
		self:attr("lifesteal", weapon.lifesteal)
		self:attr("silent_heal", 1)
	end

	local mode = "other"
	if self:hasShield() then mode = "shield"
	elseif self:hasTwoHandedWeapon() then mode = "twohanded"
	elseif self:hasDualWeapon() then mode = "dualwield"
	end
	self.turn_procs.weapon_type = {kind=weapon and weapon.talented or "unknown", mode=mode}

	-- Does the blow connect? yes .. complex :/
	local atk, def = self:combatAttack(weapon), target:combatDefense()

	-- add stalker damage and attack bonus
	local effStalker = self:hasEffect(self.EFF_STALKER)
	if effStalker and effStalker.target == target then
		local t = self:getTalentFromId(self.T_STALK)
		atk = atk + t.getAttackChange(self, t, effStalker.bonus)
		mult = mult * t.getStalkedDamageMultiplier(self, t, effStalker.bonus)
	end

	-- add marked prey damage and attack bonus
	local effPredator = self:hasEffect(self.EFF_PREDATOR)
	if effPredator and effPredator.type == target.type then
		if effPredator.subtype == target.subtype then
			mult = mult + effPredator.subtypeDamageChange
			atk = atk + effPredator.subtypeAttackChange
		else
			mult = mult + effPredator.typeDamageChange
			atk = atk + effPredator.typeAttackChange
		end
	end

	-- track weakness for hate bonus before the target removes it
	local effGloomWeakness = target:hasEffect(target.EFF_GLOOM_WEAKNESS)

	local dam, apr, armor = force_dam or self:combatDamage(weapon), self:combatAPR(weapon), target:combatArmor()
	print("[ATTACK] to ", target.name, " :: ", dam, apr, armor, def, "::", mult)

	-- check repel
	local repelled = false
	if target:isTalentActive(target.T_REPEL) then
		local t = target:getTalentFromId(target.T_REPEL)
		repelled = t.isRepelled(target, t)
	end

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	local evaded = false
	local old_target_life = target.life

	if target:knowTalent(target.T_SKIRMISHER_BUCKLER_EXPERTISE) then
		local t = target:getTalentFromId(target.T_SKIRMISHER_BUCKLER_EXPERTISE)
		if t.shouldEvade(target, t) then
			game.logSeen(target, "#ORCHID#%s cleverly deflects the attack with %s shield!#LAST#", target.name:capitalize(), string.his_her(target))
			t.onEvade(target, t, self)
			repelled = true
		end
	end

	if target:hasEffect(target.EFF_WEAPON_WARDING) then
		local e = target.tempeffect_def[target.EFF_WEAPON_WARDING]
		if e.do_block(target, target.tmp[target.EFF_WEAPON_WARDING], self) then
			repelled = true
		end
	end

	if repelled then
		self:logCombat(target, "#Target# repels an attack from #Source#.")
	elseif self:checkEvasion(target) then
		evaded = true
		self:logCombat(target, "#Target# evades #Source#.")
	elseif self.turn_procs.auto_melee_hit or (self:checkHit(atk, def) and (self:canSee(target) or self:attr("blind_fight") or target:attr("blind_fighted") or rng.chance(3))) then
		local pres = util.bound(target:combatArmorHardiness() / 100, 0, 1)
		if target.knowTalent and target:hasEffect(target.EFF_DUAL_WEAPON_DEFENSE) then
			local deflect = math.min(dam, target:callTalent(target.T_DUAL_WEAPON_DEFENSE, "doDeflect"))
			if deflect > 0 then
				game:delayedLogDamage(self, target, 0, ("%s(%d parried#LAST#)"):format(DamageType:get(damtype).text_color or "#aaaaaa#", deflect), false)
				dam = math.max(dam - deflect,0)
				print("[ATTACK] after DUAL_WEAPON_DEFENSE", dam)
			end
		end
		if target.knowTalent and target:hasEffect(target.EFF_GESTURE_OF_GUARDING) and not target:attr("encased_in_ice") then
			local deflected = math.min(dam, target:callTalent(target.T_GESTURE_OF_GUARDING, "doGuard")) or 0
			if deflected > 0 then
				game:delayedLogDamage(self, target, 0, ("%s(%d gestured#LAST#)"):format(DamageType:get(damtype).text_color or "#aaaaaa#", deflected), false)
				dam = dam - deflected
			end
			print("[ATTACK] after GESTURE_OF_GUARDING", dam)
		end

		if self:isAccuracyEffect(weapon, "knife") then
			local bonus = 1 + self:getAccuracyEffect(weapon, atk, def, 0.005, 0.25)
			print("[ATTACJ] dagger accuracy bonus", atk, def, "=", bonus, "previous", apr)
			apr = apr * bonus
		end

		print("[ATTACK] raw dam", dam, "versus", armor, pres, "with APR", apr)
		armor = math.max(0, armor - apr)
		dam = math.max(dam * pres - armor, 0) + (dam * (1 - pres))
		print("[ATTACK] after armor", dam)
		local damrange = self:combatDamageRange(weapon)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK] after range", dam)
		dam, crit = self:physicalCrit(dam, weapon, target, atk, def)
		print("[ATTACK] after crit", dam)
		dam = dam * mult
		print("[ATTACK] after mult", dam)

		if self:isAccuracyEffect(weapon, "mace") then
			local bonus = 1 + self:getAccuracyEffect(weapon, atk, def, 0.001, 0.1)
			print("[ATTACK] mace accuracy bonus", atk, def, "=", bonus)
			dam = dam * bonus
		end

		if target:hasEffect(target.EFF_COUNTERSTRIKE) then
			dam = target:callEffect(target.EFF_COUNTERSTRIKE, "onStrike", dam, self)
			print("[ATTACK] after counterstrike", dam)
		end

		if weapon and weapon.inc_damage_type then
			local inc = 0

			for k, v in pairs(weapon.inc_damage_type) do
				if target:checkClassification(tostring(k)) then inc = math.max(inc, v) end
			end
			dam = dam + dam * inc / 100

			--for t, idt in pairs(weapon.inc_damage_type) do
				--if target.type.."/"..target.subtype == t or target.type == t then dam = dam + dam * idt / 100 break end
			--end
			print("[ATTACK] after inc by type", dam)
		end

		if crit then self:logCombat(target, "#{bold}##Source# performs a melee critical strike against #Target#!#{normal}#") end

		-- Phasing, percent of weapon damage bypasses shields
		-- It's done like this because onTakeHit has no knowledge of the weapon
		if weapon and weapon.phasing then
			self:attr("damage_shield_penetrate", weapon.phasing)
		end

		local oldproj = DamageType:getProjectingFor(self)
		if self.__talent_running then DamageType:projectingFor(self, {project_type={talent=self.__talent_running}}) end

		if weapon and weapon.crushing_blow then self:attr("crushing_blow", 1) end

		-- Damage conversion?
		-- Reduces base damage but converts it into another damage type
		local conv_dam
		local conv_damtype
		local total_conversion = 0
		if weapon and weapon.convert_damage then
			for typ, conv in pairs(weapon.convert_damage) do
				if dam > 0 then
					conv_dam = math.min(dam, dam * (conv / 100))
					total_conversion = total_conversion + conv_dam
					conv_damtype = typ
					dam = dam - conv_dam
					if conv_dam > 0 then
						DamageType:get(conv_damtype).projector(self, target.x, target.y, conv_damtype, math.max(0, conv_dam))
					end
				end
			end
		end

		if dam > 0 then
			DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam))
		end

		if weapon and weapon.crushing_blow then self:attr("crushing_blow", -1) end

		if self.__talent_running then DamageType:projectingFor(self, oldproj) end

		-- remove phasing
		if weapon and weapon.phasing then
			self:attr("damage_shield_penetrate", -weapon.phasing)
		end

		-- add damage conversion back in so the total damage still gets passed
		if total_conversion > 0 then
			dam = dam + total_conversion
		end

		target:fireTalentCheck("callbackOnMeleeHit", self, dam)

		hitted = true
	else
		self:logCombat(target, "#Source# misses #Target#.")
		target:fireTalentCheck("callbackOnMeleeMiss", self, dam)
	end

	-- cross-tier effect for accuracy vs. defense
--[[
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
]]

	if self:isAccuracyEffect(weapon, "staff") then
		local bonus = 1 + self:getAccuracyEffect(weapon, atk, def, 0.025, 2)
		print("[ATTACK] staff accuracy bonus", atk, def, "=", bonus)
		self.__global_accuracy_damage_bonus = bonus
	end

	-- handle stalk targeting for hits (also handled in Actor for turn end effects)
	if hitted and target ~= self then
		if effStalker then
			-- mark if stalkee was hit
			effStalker.hit = effStalker.hit or effStalker.target == target
		elseif self:isTalentActive(self.T_STALK) then
			local stalk = self:isTalentActive(self.T_STALK)

			if not stalk.hit then
				-- mark a new target
				stalk.hit = true
				stalk.hit_target = target
			elseif stalk.hit_target ~= target then
				-- more than one target; clear it
				stalk.hit_target = nil
			end
		end
	end

	-- Spread diseases
	if hitted and self:knowTalent(self.T_CARRIER) and rng.percent(self:callTalent(self.T_CARRIER, "getDiseaseSpread")) then
		-- Use epidemic talent spreading
		self:callTalent(self.T_EPIDEMIC, "do_spread", target, dam)
	end

	-- Melee project
	if hitted and not target.dead and weapon and weapon.melee_project then for typ, dam in pairs(weapon.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end
	if hitted and not target.dead then for typ, dam in pairs(self.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end

	-- Shadow cast
	if hitted and not target.dead and self:knowTalent(self.T_SHADOW_COMBAT) and self:isTalentActive(self.T_SHADOW_COMBAT) and self:getMana() > 0 then
		local dam = 2 + self:combatTalentSpellDamage(self.T_SHADOW_COMBAT, 2, 50)
		local mana = 2
		if self:getMana() > mana then
			DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
			self:incMana(-mana)
		end
	end

	-- Temporal cast
	if hitted and self:knowTalent(self.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) then
		local dam = self:callTalent(self.T_WEAPON_FOLDING, "getDamage")
		local burst_damage = 0
		local burst_radius = 0
		if self:knowTalent(self.T_FRAYED_THREADS) then
			burst_damage = dam * self:callTalent(self.T_FRAYED_THREADS, "getPercent")
			burst_radius = self:callTalent(self.T_FRAYED_THREADS, "getRadius")
			dam = dam - burst_damage
			self:project({type="ball", radius=burst_radius, friendlyfire=false}, target.x, target.y, DamageType.TEMPORAL, burst_damage)
		end
		if dam > 0 and not target.dead then
			DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam, tmp)
		end
	end
	if hitted and self:knowTalent(self.T_IMPACT) and self:isTalentActive(self.T_IMPACT) then
		local dam = self:callTalent(self.T_IMPACT, "getDamage")
		local power = self:callTalent(self.T_IMPACT, "getApplyPower")
		local burst_damage = 0
		local burst_radius = 0
		if self:knowTalent(self.T_FRAYED_THREADS) then
			burst_damage = dam * self:callTalent(self.T_FRAYED_THREADS, "getPercent")
			burst_radius = self:callTalent(self.T_FRAYED_THREADS, "getRadius")
			dam = dam - burst_damage
			self:project({type="ball", radius=burst_radius, friendlyfire=false}, target.x, target.y, DamageType.IMPACT, {dam=burst_damage, daze=dam/2, power_check=power})
		end
		if dam > 0 and not target.dead then
			DamageType:get(DamageType.IMPACT).projector(self, target.x, target.y, DamageType.IMPACT, {dam=dam, daze=dam/2, power_check=power}, tmp)
		end
	end

	-- Ruin
	if hitted and not target.dead and self:knowTalent(self.T_RUIN) and self:isTalentActive(self.T_RUIN) then
		local t = self:getTalentFromId(self.T_RUIN)
		local dam = t.getDamage(self, t)
		DamageType:get(DamageType.DRAINLIFE).projector(self, target.x, target.y, DamageType.DRAINLIFE, dam)
	end

	-- Autospell cast
	if hitted and not target.dead and self:knowTalent(self.T_ARCANE_COMBAT) and self:isTalentActive(self.T_ARCANE_COMBAT) then
		local t = self:getTalentFromId(self.T_ARCANE_COMBAT)
		t.do_trigger(self, t, target)
	end

	-- On hit talent
	if hitted and not target.dead and weapon and weapon.talent_on_hit and next(weapon.talent_on_hit) and not self.turn_procs.melee_talent then
		for tid, data in pairs(weapon.talent_on_hit) do
			if rng.percent(data.chance) then
				self.turn_procs.melee_talent = true
				self:forceUseTalent(tid, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=data.level, ignore_ressources=true})
			end
		end
	end
	-- On crit talent
	if hitted and crit and not target.dead and weapon and weapon.talent_on_crit and next(weapon.talent_on_crit) and not self.turn_procs.melee_talent then
		for tid, data in pairs(weapon.talent_on_crit) do
			if rng.percent(data.chance) then
				self.turn_procs.melee_talent = true
				self:forceUseTalent(tid, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=data.level, ignore_ressources=true})
			end
		end
	end

	-- Shattering Impact
	if hitted and self:attr("shattering_impact") and (not self.shattering_impact_last_turn or self.shattering_impact_last_turn < game.turn) then
		local dam = dam * self.shattering_impact
		game.logSeen(target, "The shattering blow creates a shockwave!")
		self:project({type="ball", radius=1, selffire=false, act_exclude={[target.uid]=true}}, target.x, target.y, DamageType.PHYSICAL, dam)  -- don't hit target with the AOE
		self:incStamina(-8)
		self.shattering_impact_last_turn = game.turn
	end

	-- Damage Backlash
	if dam > 0 and self:attr("damage_backfire") then
		local hurt = math.min(dam, old_target_life) * self.damage_backfire / 100
		if hurt > 0 then
			self:takeHit(hurt, self)
		end
	end

	-- Burst on Hit
	if hitted and weapon and weapon.burst_on_hit then
		for typ, dam in pairs(weapon.burst_on_hit) do
			if dam > 0 then
				self:project({type="ball", radius=1, friendlyfire=false}, target.x, target.y, typ, dam)
			end
		end
	end

	-- Critical Burst (generally more damage then burst on hit and larger radius)
	if hitted and crit and weapon and weapon.burst_on_crit then
		for typ, dam in pairs(weapon.burst_on_crit) do
			if dam > 0 then
				self:project({type="ball", radius=2, friendlyfire=false}, target.x, target.y, typ, dam)
			end
		end
	end

	-- Arcane Destruction
	if hitted and crit and weapon and self:knowTalent(self.T_ARCANE_DESTRUCTION) then
		local chance = 100
		if self:hasShield() then chance = 75
		elseif self:hasDualWeapon() then chance = 50
		end
		if rng.percent(chance) then
			local typ = rng.table{{DamageType.FIRE,"ball_fire"}, {DamageType.LIGHTNING,"ball_lightning_beam"}, {DamageType.ARCANE,"ball_arcane"}}
			self:project({type="ball", radius=2, friendlyfire=false}, target.x, target.y, typ[1], self:combatSpellpower() * 2)
			game.level.map:particleEmitter(target.x, target.y, 2, typ[2], {radius=2, tx=target.x, ty=target.y})
		end
	end

	-- Onslaught
	if hitted and self:attr("onslaught") then
		local dir = util.getDir(target.x, target.y, self.x, self.y) or 6
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if target:checkHit(self:combatAttack(weapon), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("knockback") then
			target:knockback(self.x, self.y, self:attr("onslaught"))
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
		end
		if lt and lt:checkHit(self:combatAttack(weapon), lt:combatPhysicalResist(), 0, 95, 10) and lt:canBe("knockback") then
			lt:knockback(self.x, self.y, self:attr("onslaught"))
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
		end
		if rt and rt:checkHit(self:combatAttack(weapon), rt:combatPhysicalResist(), 0, 95, 10) and rt:canBe("knockback") then
			rt:knockback(self.x, self.y, self:attr("onslaught"))
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
		end
	end

	-- Reactive target on hit damage
	if hitted then for typ, dam in pairs(target.on_melee_hit) do
		if type(dam) == "number" then if dam > 0 then DamageType:get(typ).projector(target, self.x, self.y, typ, dam) end
		elseif dam.dam and dam.dam > 0 then DamageType:get(typ).projector(target, self.x, self.y, typ, dam)
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

	-- Dwarves stoneskin
	if hitted and not target.dead and target:attr("auto_stoneskin") and rng.percent(15) then
		target:setEffect(target.EFF_STONE_SKIN, 5, {power=target:attr("auto_stoneskin")})
	end

	-- Psi Auras
	local psiweapon = self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1]
	if psiweapon and psiweapon.combat and psiweapon.subtype ~= "mindstar"  then
		if hitted and not target.dead and self:knowTalent(self.T_KINETIC_AURA) and self:isTalentActive(self.T_KINETIC_AURA) and (self.use_psi_combat or self:hasEffect(EFF_TRANSCENDENT_TELEKINESIS)) then
			local t = self:getTalentFromId(self.T_KINETIC_AURA)
			t.do_combat(self, t, target)
		end
		if hitted and not target.dead and self:knowTalent(self.T_THERMAL_AURA) and self:isTalentActive(self.T_THERMAL_AURA) and (self.use_psi_combat or self:hasEffect(EFF_TRANSCENDENT_TELEKINESIS)) then
			local t = self:getTalentFromId(self.T_THERMAL_AURA)
			t.do_combat(self, t, target)
		end
		if hitted and not target.dead and self:knowTalent(self.T_CHARGED_AURA) and self:isTalentActive(self.T_CHARGED_AURA) and (self.use_psi_combat or self:hasEffect(EFF_TRANSCENDENT_TELEKINESIS)) then
			local t = self:getTalentFromId(self.T_CHARGED_AURA)
			t.do_combat(self, t, target)
		end
	end

	-- Static dis-Charge
	if hitted and not target.dead and self:hasEffect(self.EFF_STATIC_CHARGE) then
		local eff = self:hasEffect(self.EFF_STATIC_CHARGE)
		DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, eff.power)
		self:removeEffect(self.EFF_STATIC_CHARGE)
	end

	-- Exploit Weakness
	if hitted and not target.dead and self:knowTalent(self.T_EXPLOIT_WEAKNESS) and self:isTalentActive(self.T_EXPLOIT_WEAKNESS) then
		local t = self:getTalentFromId(self.T_EXPLOIT_WEAKNESS)
		t.do_weakness(self, t, target)
	end

	-- Lacerating Strikes
	if hitted and not target.dead and self:isTalentActive(self.T_LACERATING_STRIKES) then
		local t = self:getTalentFromId(self.T_LACERATING_STRIKES)
		t.do_cut(self, t, target, dam)
	end

	-- Scoundrel's Strategies
	if hitted and not target.dead and self:knowTalent(self.T_SCOUNDREL) and target:hasEffect(target.EFF_CUT) then
		local t = self:getTalentFromId(self.T_SCOUNDREL)
		t.do_scoundrel(self, t, target)
	end

	-- Special effect
	if hitted and weapon and weapon.special_on_hit then
		local specials = weapon.special_on_hit
		if specials.fct then specials = {specials} end
		for _, special in ipairs(specials) do
			if special.fct and (not target.dead or special.on_kill) then
				special.fct(weapon, self, target, dam)
			end
		end
	end

	if hitted and crit and weapon and weapon.special_on_crit then
		local specials = weapon.special_on_crit
		if specials.fct then specials = {specials} end
		for _, special in ipairs(specials) do
			if special.fct and (not target.dead or special.on_kill) then
				special.fct(weapon, self, target, dam)
			end
		end
	end

	if hitted and weapon and weapon.special_on_kill and target.dead then
		local specials = weapon.special_on_kill
		if specials.fct then specials = {specials} end
		for _, special in ipairs(specials) do
			if special.fct then
				special.fct(weapon, self, target, dam)
			end
		end
	end

	if hitted and weapon and weapon.special_on_kill and weapon.special_on_kill.fct and target.dead then
		weapon.special_on_kill.fct(weapon, self, target, dam)
	end

	if hitted and crit and not target.dead and self:knowTalent(self.T_BACKSTAB) and not target:attr("stunned") and rng.percent(self:callTalent(self.T_BACKSTAB, "getStunChance")) then
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 3, {apply_power=self:combatAttack()})
		end
	end

	-- Poison coating
	if hitted and not target.dead and self.vile_poisons and next(self.vile_poisons) and target:canBe("poison") then
		local tid = rng.table(table.keys(self.vile_poisons))
		if tid then
			local t = self:getTalentFromId(tid)
			t.proc(self, t, target, weapon)
		end
	end

	-- Regen on being hit
	if hitted and not target.dead and target:attr("stamina_regen_when_hit") then target:incStamina(target.stamina_regen_when_hit) end
	if hitted and not target.dead and target:attr("mana_regen_when_hit") then target:incMana(target.mana_regen_when_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_when_hit") then target:incEquilibrium(-target.equilibrium_regen_when_hit) end
	if hitted and not target.dead and target:attr("psi_regen_when_hit") then target:incPsi(target.psi_regen_when_hit) end
	if hitted and not target.dead and target:attr("hate_regen_when_hit") then target:incHate(target.hate_regen_when_hit) end
	if hitted and not target.dead and target:attr("vim_regen_when_hit") then target:incVim(target.vim_regen_when_hit) end

	-- Resource regen on hit
	if hitted and self:attr("stamina_regen_on_hit") then self:incStamina(self.stamina_regen_on_hit) end
	if hitted and self:attr("mana_regen_on_hit") then self:incMana(self.mana_regen_on_hit) end
	if hitted and self:attr("psi_regen_on_hit") then self:incPsi(self.psi_regen_on_hit) end

	if hitted and not target.dead and target:knowTalent(target.T_STONESHIELD) then
		local t = target:getTalentFromId(target.T_STONESHIELD)
		local m, mm, e, em = t.getValues(self, t)
		target:incMana(math.min(dam * m, mm))
		target:incEquilibrium(-math.min(dam * e, em))
	end

	-- Ablative Armor
	if hitted and not target.dead and target:attr("carbon_spikes") then
		local t = target:getTalentFromId(target.T_CARBON_SPIKES)
		t.do_carbonLoss(target, t)
	end

	-- Set Up
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:hasEffect(target.EFF_DEFENSIVE_MANEUVER) then
		local t = target:getTalentFromId(target.T_SET_UP)
		local power = t.getPower(target, t)
		self:setEffect(self.EFF_SET_UP, 2, {src = target, power=power})
	end

	-- Counter Attack!
	if not hitted and not target.dead and target:knowTalent(target.T_COUNTER_ATTACK) and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_COUNTER_ATTACK) and self:isNear(target.x,target.y, 1) then --Adjacency check
		local cadam = target:callTalent(target.T_COUNTER_ATTACK,"checkCounterAttack")
		if cadam then
			game.logSeen(self, "%s counters the attack!", target.name:capitalize())
			target:attackTarget(self, nil, cadam, true)
		end
	end

	-- Gesture of Guarding counterattack
	if hitted and not target.dead and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:hasEffect(target.EFF_GESTURE_OF_GUARDING) then
		local t = target:getTalentFromId(target.T_GESTURE_OF_GUARDING)
		t.on_hit(target, t, self)
	end

	-- Defensive Throw!
	if not hitted and not target.dead and target:knowTalent(target.T_DEFENSIVE_THROW) and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:isNear(self.x,self.y,1) then
		local t = target:getTalentFromId(target.T_DEFENSIVE_THROW)
		t.do_throw(target, self, t)
	end

	-- Greater Weapon Focus
	local gwf = self:hasEffect(self.EFF_GREATER_WEAPON_FOCUS)
	if hitted and not target.dead and weapon and gwf and not gwf.inside and rng.percent(gwf.chance) then
		gwf.inside = true
		game.logSeen(self, "%s focuses and gains an extra blow!", self.name:capitalize())
		self:attackTargetWith(target, weapon, damtype, mult)
		gwf.inside = nil
	end

	-- Zero gravity
	if hitted and game.level.data.zero_gravity and rng.percent(util.bound(dam, 0, 100)) then
		target:knockback(self.x, self.y, math.ceil(math.log(dam)))
	end

	-- Roll with it
	if hitted and target:attr("knockback_on_hit") and not target.turn_procs.roll_with_it and rng.percent(util.bound(dam, 0, 100)) then
		local ox, oy = self.x, self.y
		game:onTickEnd(function()
			target:knockback(ox, oy, 1)
			if not target:hasEffect(target.EFF_WILD_SPEED) then target:setEffect(target.EFF_WILD_SPEED, 1, {power=200}) end
		end)
		target.turn_procs.roll_with_it = true
	end

	-- Weakness hate bonus
	if hitted and effGloomWeakness and effGloomWeakness.hateBonus or 0 > 0 then
		self:incHate(effGloomWeakness.hateBonus)
		game.logPlayer(self, "#F53CBE#You revel in attacking a weakened foe! (+%d hate)", effGloomWeakness.hateBonus)
		effGloomWeakness.hateBonus = nil
	end

	-- Rampage
	if hitted and crit then
		local eff = self:hasEffect(self.EFF_RAMPAGE)
		if eff and not eff.critHit and eff.actualDuration < eff.maxDuration and self:knowTalent(self.T_BRUTALITY) then
			game.logPlayer(self, "#F53CBE#Your rampage is invigorated by your fierce attack! (+1 duration)")
			eff.critHit = true
			eff.actualDuration = eff.actualDuration + 1
			eff.dur = eff.dur + 1
		end
	end

	-- Marked Prey
	if hitted and not target.dead and effPredator and effPredator.type == target.type then
		if effPredator.subtype == target.subtype then
			-- Anatomy stun
			if effPredator.subtypeStunChance > 0 and rng.percent(effPredator.subtypeStunChance) then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, 3, {})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
			end

			-- Outmaneuver
			if effPredator.subtypeOutmaneuverChance > 0 and rng.percent(effPredator.subtypeOutmaneuverChance) then
				local t = self:getTalentFromId(self.T_OUTMANEUVER)
				target:setEffect(target.EFF_OUTMANEUVERED, t.getDuration(self, t), { physicalResistChange=t.getPhysicalResistChange(self, t), statReduction=t.getStatReduction(self, t) })
			end
		else
			-- Outmaneuver
			if effPredator.typeOutmaneuverChance > 0 and rng.percent(effPredator.typeOutmaneuverChance) then
				local t = self:getTalentFromId(self.T_OUTMANEUVER)
				target:setEffect(target.EFF_OUTMANEUVERED, t.getDuration(self, t), { physicalResistChange=t.getPhysicalResistChange(self, t), statReduction=t.getStatReduction(self, t) })
			end
		end
	end

	if hitted and crit and target:hasEffect(target.EFF_DISMAYED) then
		target:removeEffect(target.EFF_DISMAYED)
	end

	if hitted and not target.dead then
		-- Curse of Madness: Twisted Mind
		if self.hasEffect and self:hasEffect(self.EFF_CURSE_OF_MADNESS) then
			local eff = self:hasEffect(self.EFF_CURSE_OF_MADNESS)
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS]
			def.doConspirator(self, eff, target)
		end
		if target.hasEffect and target:hasEffect(target.EFF_CURSE_OF_MADNESS) then
			local eff = target:hasEffect(target.EFF_CURSE_OF_MADNESS)
			local def = target.tempeffect_def[target.EFF_CURSE_OF_MADNESS]
			def.doConspirator(target, eff, self)
		end

		-- Curse of Nightmares: Suffocate
		if self.hasEffect and self:hasEffect(self.EFF_CURSE_OF_NIGHTMARES) then
			local eff = self:hasEffect(self.EFF_CURSE_OF_NIGHTMARES)
			local def = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES]
			def.doSuffocate(self, eff, target)
		end
		if target.hasEffect and target:hasEffect(target.EFF_CURSE_OF_NIGHTMARES) then
			local eff = target:hasEffect(target.EFF_CURSE_OF_NIGHTMARES)
			local def = target.tempeffect_def[target.EFF_CURSE_OF_NIGHTMARES]
			def.doSuffocate(target, eff, self)
		end
	end

	self:fireTalentCheck("callbackOnMeleeAttack", target, hitted, crit, weapon, damtype, mult, dam)

	local hd = {"Combat:attackTargetWith", hitted=hitted, crit=crit, target=target, weapon=weapon, damtype=damtype, mult=mult, dam=dam}
	if self:triggerHook(hd) then hitted = hd.hitted end

	-- Visual feedback
	if hitted then game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=target.blood_color}) end

	self.turn_procs.weapon_type = nil
	self.__global_accuracy_damage_bonus = nil

	--Life Steal
	if weapon and weapon.lifesteal then
		self:attr("lifesteal", -weapon.lifesteal)
		self:attr("silent_heal", -1)
	end

	return self:combatSpeed(weapon), hitted
end

_M.weapon_talents = {
	sword =   {"T_WEAPONS_MASTERY", "T_STRENGTH_OF_PURPOSE"},
	axe =     {"T_WEAPONS_MASTERY", "T_STRENGTH_OF_PURPOSE"},
	mace =    {"T_WEAPONS_MASTERY", "T_STRENGTH_OF_PURPOSE"},
	knife =   {"T_KNIFE_MASTERY", "T_STRENGTH_OF_PURPOSE"},
	whip  =   "T_EXOTIC_WEAPONS_MASTERY",
	trident = "T_EXOTIC_WEAPONS_MASTERY",
	bow =     {"T_BOW_MASTERY", "T_STRENGTH_OF_PURPOSE"},
	sling =   {"T_SLING_MASTERY", "T_SKIRMISHER_SLING_SUPREMACY"},
	staff =   "T_STAFF_MASTERY",
	mindstar ="T_PSIBLADES",
	dream =   "T_DREAM_CRUSHER",
	unarmed = "T_UNARMED_MASTERY",
}

--- Static!
-- Training Talents can have the following fields:
-- getMasteryPriority(self, t, kind) - Only the talent with the highest is used. Defaults to the talent level.
-- getDamage(self, t, kind) - Extra physical power granted. Defaults to level * 10.
-- getPercentInc(self, t, kind) - Percentage increase to damage overall. Defaults to sqrt(level / 5) / 2.
function _M:addCombatTraining(kind, tid)
	local wt = _M.weapon_talents
	if not wt[kind] then wt[kind] = tid return end

	if type(wt[kind]) == "table" then
		wt[kind][#wt[kind]+1] = tid
	else
		wt[kind] = { wt[kind] }
		wt[kind][#wt[kind]+1] = tid
	end
end

--- Checks weapon training
function _M:combatGetTraining(weapon)
	if not weapon then return nil end
	if not weapon.talented then return nil end
	if not _M.weapon_talents[weapon.talented] then return nil end
	if type(_M.weapon_talents[weapon.talented]) == "table" then
		local get_priority = function(tid)
			local t = self:getTalentFromId(tid)
			if t.getMasteryPriority then return util.getval(t.getMasteryPriority, self, t, weapon.talented) end
			return self:getTalentLevel(t)
		end
		local max_tid -- = _M.weapon_talents[weapon.talented][1]
		local max_priority = -math.huge -- get_priority(max_tid)
		for _, tid in ipairs(_M.weapon_talents[weapon.talented]) do
			if self:knowTalent(tid) then
				local priority = get_priority(tid)
				if priority > max_priority then
					max_tid = tid
					max_priority = priority
				end
			end
		end
		return self:getTalentFromId(max_tid)
	else
		return self:getTalentFromId(_M.weapon_talents[weapon.talented])
	end
end

-- Gets the added damage for a weapon based on training.
function _M:combatTrainingDamage(weapon)
	local t = self:combatGetTraining(weapon)
	if not t then return 0 end
	if t.getDamage then return util.getval(t.getDamage, self, t, weapon.talented) end
	return self:getTalentLevel(t) * 10
end

-- Gets the percent increase for a weapon based on training.
function _M:combatTrainingPercentInc(weapon)
	local t = self:combatGetTraining(weapon)
	if not t then return 0 end
	if t.getPercentInc then return util.getval(t.getPercentInc, self, t, weapon.talented) end
	return math.sqrt(self:getTalentLevel(t) / 5) / 2
end

--- Gets the defense
--- Fake denotes a check not actually being made, used by character sheets etc.
function _M:combatDefenseBase(fake)
	local add = 0
	if not self:attr("encased_in_ice") then
		if self:hasDualWeapon() and self:knowTalent(self.T_DUAL_WEAPON_DEFENSE) then
			add = add + self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDefense")
		end
		if not fake then
			add = add + (self:checkOnDefenseCall("defense") or 0)
		end
		if self:knowTalent(self.T_TACTICAL_EXPERT) then
			local t = self:getTalentFromId(self.T_TACTICAL_EXPERT)
			add = add + t.do_tact_update(self, t)
		end
		if self:knowTalent(self.T_CORRUPTED_SHELL) then
			add = add + self:getCon() / 3
		end
		if self:knowTalent(self.T_STEADY_MIND) then
			local t = self:getTalentFromId(self.T_STEADY_MIND)
			add = add + t.getDefense(self, t)
		end
		if self:isTalentActive(Talents.T_SURGE) then
			local t = self:getTalentFromId(self.T_SURGE)
			add = add + t.getDefenseChange(self, t)
		end
	end
	local d = math.max(0, self.combat_def + (self:getDex() - 10) * 0.35 + (self:getLck() - 50) * 0.4)
	local mult = 1

	if self:hasLightArmor() and self:knowTalent(self.T_MOBILE_DEFENCE) then
		mult = mult + self:callTalent(self.T_MOBILE_DEFENCE,"getDef")
	end

	if self:knowTalent(self.T_MISDIRECTION) then
		mult = mult + self:callTalent(self.T_MISDIRECTION,"getDefense")/100
	end
	return math.max(0, d * mult + add) -- Add bonuses last to avoid compounding defense multipliers from talents
end

--- Gets the defense ranged
function _M:combatDefense(fake, add)
	local base_defense = self:combatDefenseBase(true)
	if not fake then base_defense = self:combatDefenseBase() end
	local d = math.max(0, base_defense + (add or 0))
	if self:attr("dazed") then d = d / 2 end
	return self:rescaleCombatStats(d)
end

--- Gets the defense ranged
function _M:combatDefenseRanged(fake, add)
	local base_defense = self:combatDefenseBase(true)
	if not fake then base_defense = self:combatDefenseBase() end
	local d = math.max(0, base_defense + (self.combat_def_ranged or 0) + (add or 0))
	if self:attr("dazed") then d = d / 2 end
	return self:rescaleCombatStats(d)
end

--- Gets the armor
function _M:combatArmor()
	local add = 0
	if self:hasHeavyArmor() and self:knowTalent(self.T_ARMOUR_TRAINING) then
		local at = Talents:getTalentFromId(Talents.T_ARMOUR_TRAINING)
		add = add + at.getArmor(self, at)
		if self:knowTalent(self.T_GOLEM_ARMOUR) then
			local ga = Talents:getTalentFromId(Talents.T_GOLEM_ARMOUR)
			add = add + ga.getArmor(self, ga)
		end
	end
	if self:knowTalent(self.T_CARBON_SPIKES) and self:isTalentActive(self.T_CARBON_SPIKES) then
		add = add + self.carbon_armor
	end
	if self:knowTalent(self.T_ARMOUR_OF_SHADOWS) and not game.level.map.lites(self.x, self.y) then
		add = add + self:callTalent(self.T_ARMOUR_OF_SHADOWS,"ArmourBonus")
	end
	return self.combat_armor + add
end

--- Gets armor hardiness
-- This is how much % of a blow we can reduce with armor
function _M:combatArmorHardiness()
	local add = 0
	local multi = 1
	if self:knowTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE) then
		add = add + self:callTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE, "getHardiness")
	end
	if self:hasHeavyArmor() and self:knowTalent(self.T_ARMOUR_TRAINING) then
		local at = Talents:getTalentFromId(Talents.T_ARMOUR_TRAINING)
		add = add + at.getArmorHardiness(self, at)
		if self:knowTalent(self.T_GOLEM_ARMOUR) then
			local ga = Talents:getTalentFromId(Talents.T_GOLEM_ARMOUR)
			add = add + ga.getArmorHardiness(self, ga)
		end
	end
	if self:hasLightArmor() and self:knowTalent(self.T_MOBILE_DEFENCE) then
		add = add + self:callTalent(self.T_MOBILE_DEFENCE, "getHardiness")
	end
	if self:knowTalent(self.T_ARMOUR_OF_SHADOWS) and not game.level.map.lites(self.x, self.y) then
		add = add + 50
	end
	if self:hasEffect(self.EFF_BREACH) then
		multi = 0.5
	end
	return util.bound(30 + self.combat_armor_hardiness + add, 0, 100) * multi
end

--- Gets the attack
function _M:combatAttackBase(weapon, ammo)
	weapon = weapon or self.combat or {}
	return 4 + self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 10 + (weapon.atk or 0) + (ammo and ammo.atk or 0) + (self:getLck() - 50) * 0.4
end
function _M:combatAttack(weapon, ammo)
	local stats
	if self:attr("use_psi_combat") then stats = self:getCun(100, true) - 10
	elseif weapon and weapon.wil_attack then stats = self:getWil(100, true) - 10
	else stats = self:getDex(100, true) - 10
	end
	local d = self:combatAttackBase(weapon, ammo) + stats
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end
	return self:rescaleCombatStats(d)
end

function _M:combatAttackRanged(weapon, ammo)
	local stats
	if self:attr("use_psi_combat") then stats = self:getCun(100, true) - 10
	elseif weapon and weapon.wil_attack then stats = self:getWil(100, true) - 10
	else stats = self:getDex(100, true) - 10
	end
	local d = self:combatAttackBase(weapon, ammo) + stats + (self.combat_atk_ranged or 0)
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	return self:rescaleCombatStats(d)
end

--- Gets the attack using only strength
function _M:combatAttackStr(weapon, ammo)
	local d = self:combatAttackBase(weapon, ammo) + (self:getStr(100, true) - 10)
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end
	return self:rescaleCombatStats(d)
end

--- Gets the attack using only dexterity
function _M:combatAttackDex(weapon, ammo)
	local d = self:combatAttackBase(weapon, ammo) + (self:getDex(100, true) - 10)
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end
	return self:rescaleCombatStats(d)
end

--- Gets the attack using only magic
function _M:combatAttackMag(weapon, ammo)
	local d = self:combatAttackBase(weapon, ammo) + (self:getMag(100, true) - 10)
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	return self:rescaleCombatStats(d)
end

--- Gets the armor penetration
function _M:combatAPR(weapon)
	weapon = weapon or self.combat or {}
	local addapr = 0
	if self:knowTalent(self.T_WEAPON_FOLDING) and self:isTalentActive(self.T_WEAPON_FOLDING) then
		addapr = addapr + (self:callTalent(self.T_WEAPON_FOLDING, "getDamage")/2)
	end
	return self.combat_apr + (weapon.apr or 0) + addapr
end

--- Gets the weapon speed
function _M:combatSpeed(weapon)
	weapon = weapon or self.combat or {}
	return (weapon.physspeed or 1) / math.max(self.combat_physspeed, 0.1)
end

--- Gets the crit rate
function _M:combatCrit(weapon)
	weapon = weapon or self.combat or {}
	local addcrit = 0
	if weapon.talented and self:knowTalent(Talents.T_LETHALITY) then
		addcrit = 1 + self:callTalent(Talents.T_LETHALITY, "getCriticalChance")
	end
	local crit = self.combat_physcrit + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + (weapon.physcrit or 1) + addcrit

	return math.max(crit, 0) -- note: crit > 100% may be offset by crit reduction elsewhere
end

--- Gets the damage range
function _M:combatDamageRange(weapon)
	weapon = weapon or self.combat or {}
	return (self.combat_damrange or 0) + (weapon.damrange or 1.1)
end

--- Scale damage values
-- This currently beefs up high-end damage values to make up for the combat stat rescale nerf.
function _M:rescaleDamage(dam)
	if dam <= 0 then return dam end
--	return dam * (1 - math.log10(dam * 2) / 7) --this is the old version, pre-combat-stat-rescale
	return dam ^ 1.04
end

--Diminishing-returns method of scaling combat stats, observing this rule: the first twenty ranks cost 1 point each, the second twenty cost two each, and so on. This is much, much better for players than some logarithmic mess, since they always know exactly what's going on, and there are nice breakpoints to strive for.
function _M:rescaleCombatStats(raw_combat_stat_value)
	local x = raw_combat_stat_value
	local tiers = 50 -- Just increase this if you want to add high-level content that allows for combat stat scores over 100.
	--return math.floor(math.min(x, 20) + math.min(math.max((x-20), 0)/2, 20) + math.min(math.max((x-60), 0)/3, 20) + math.min(math.max((x-120), 0)/4, 20) + math.min(math.max((x-200), 0)/5, 20)) --Five terms of the summation below.
	local total = 0
	for i = 1, tiers do
		local sub = 20*(i*(i-1)/2)
		total = total + math.min(math.max(x-sub, 0)/i, 20)
	end
	return total
end

-- Scale a value up or down by a power
-- x = a numeric value
-- y_low = value to match at x_low
-- y_high = value to match at x_high
-- power = scaling factor (default 0.5)
-- add = amount to add the result (default 0)
-- shift = amount to add to the input value before computation (default 0)
function _M:combatScale(x, y_low, x_low, y_high, x_high, power, add, shift)
	power, add, shift = power or 0.5, add or 0, shift or 0
	local x_low_adj, x_high_adj = (x_low+shift)^power, (x_high+shift)^power
	local m = (y_high - y_low)/(x_high_adj - x_low_adj)
	local b = y_low - m*x_low_adj
	return m * (x + shift)^power + b + add
end

-- Scale a value up or down subject to a limit
-- x = a numeric value
-- limit = value approached as x increases
-- y_high = value to match at when x = x_high
-- y_low (optional) = value to match when x = x_low
--	returns (limit - add)*x/(x + halfpoint) + add (= add when x = 0 and limit when x = infinity)
-- halfpoint and add are internally computed to match the desired high/low values
-- note that the progression low->high->limit must be monotone, consistently increasing or decreasing
function _M:combatLimit(x, limit, y_low, x_low, y_high, x_high)
--	local x_low, x_high = 1,5 -- Implied talent levels for low and high values respectively
--	local tl = type(t) == "table" and (raw and self:getTalentLevelRaw(t) or self:getTalentLevel(t)) or t
	if y_low and x_low then
		local p = limit*(x_high-x_low)
		local m = x_high*y_high - x_low*y_low
--		local halfpoint = (p-m)/(y_high - y_low)
--		local add = (limit*(x_high*y_low-x_low*y_high) + y_high*y_low*(x_low-x_high))/(p-m)
--		return (limit-add)*x/(x + halfpoint) + add
		local ah = (limit*(x_high*y_low-x_low*y_high)+ y_high*y_low*(x_low-x_high))/(y_high - y_low) -- add*halfpoint product calculated at once to avoid possible divide by zero
		return (limit*x + ah)/(x + (p-m)/(y_high - y_low)) --factored version of above formula
--		return (limit-add)*x/(x + halfpoint) + add, halfpoint, add
	else
		local add = 0
		local halfpoint = limit*x_high/(y_high-add)-x_high
		return (limit-add)*x/(x + halfpoint) + add
--		return (limit-add)*x/(x + halfpoint) + add, halfpoint, add
	end
end

-- Compute a diminishing returns value based on talent level that scales with a power
-- t = talent def table or a numeric value
-- low = value to match at talent level 1
-- high = value to match at talent level 5
-- power = scaling factor (default 0.5) or "log" for log10
-- add = amount to add the result (default 0)
-- shift = amount to add to the talent level before computation (default 0)
-- raw if true specifies use of raw talent level
function _M:combatTalentScale(t, low, high, power, add, shift, raw)
	local tl = type(t) == "table" and (raw and self:getTalentLevelRaw(t) or self:getTalentLevel(t)) or t
	power, add, shift = power or 0.5, add or 0, shift or 0
	local x_low, x_high = 1, 5 -- Implied talent levels to fit
	local x_low_adj, x_high_adj
	if power == "log" then
		x_low_adj, x_high_adj = math.log10(x_low+shift), math.log10(x_high+shift)
		tl = math.max(1, tl)
	else
		x_low_adj, x_high_adj = (x_low+shift)^power, (x_high+shift)^power
	end
	local m = (high - low)/(x_high_adj - x_low_adj)
	local b = low - m*x_low_adj
	if power == "log" then -- always >= 0
		return math.max(0, m * math.log10(tl + shift) + b + add)
--		return math.max(0, m * math.log10(tl + shift) + b + add), m, b
	else
		return math.max(0, m * (tl + shift)^power + b + add)
--		return math.max(0, m * (tl + shift)^power + b + add), m, b
	end
end

-- Compute a diminishing returns value based on a stat value that scales with a power
-- stat == "str", "con",.... or a numeric value
-- low = value to match when stat = 10
-- high = value to match when stat = 100
-- power = scaling factor (default 0.5) or "log" for log10
-- add = amount to add the result (default 0)
-- shift = amount to add to the stat value before computation (default 0)
function _M:combatStatScale(stat, low, high, power, add, shift)
	stat = type(stat) == "string" and self:getStat(stat,nil,true) or stat
	power, add, shift = power or 0.5, add or 0, shift or 0
	local x_low, x_high = 10, 100 -- Implied stat values to match
	local x_low_adj, x_high_adj
	if power == "log" then
		x_low_adj, x_high_adj = math.log10(x_low+shift), math.log10(x_high+shift)
		stat = math.max(1, stat)
	else
		x_low_adj, x_high_adj = (x_low+shift)^power, (x_high+shift)^power
	end
	local m = (high - low)/(x_high_adj - x_low_adj)
	local b = low -m*x_low_adj
	if power == "log" then -- always >= 0
		return math.max(0, m * math.log10(stat + shift) + b + add)
--		return math.max(0, m * math.log10(stat + shift) + b + add), m, b
	else
		return math.max(0, m * (stat + shift)^power + b + add)
--		return math.max(0, m * (stat + shift)^power + b + add), m, b
	end
end

-- Compute a diminishing returns value based on talent level that cannot go beyond a limit
-- t = talent def table or a numeric value
-- limit = value approached as talent levels increase
-- high = value at talent level 5
-- low = value at talent level 1 (optional)
-- raw if true specifies use of raw talent level
--	returns (limit - add)*TL/(TL + halfpoint) + add == add when TL = 0 and limit when TL = infinity
-- TL = talent level, halfpoint and add are internally computed to match the desired high/low values
-- note that the progression low->high->limit must be monotone, consistently increasing or decreasing
function _M:combatTalentLimit(t, limit, low, high, raw)
	local x_low, x_high = 1,5 -- Implied talent levels for low and high values respectively
	local tl = type(t) == "table" and (raw and self:getTalentLevelRaw(t) or self:getTalentLevel(t)) or t
	if low then
		local p = limit*(x_high-x_low)
		local m = x_high*high - x_low*low
--		local halfpoint = (p-m)/(high - low) -- point at which half progress towards the limit is reached
--		local add = (limit*(x_high*low-x_low*high) + high*low*(x_low-x_high))/(p-m)
		local ah = (limit*(x_high*low-x_low*high)+ high*low*(x_low-x_high))/(high - low) -- add*halfpoint product calculated at once to avoid possible divide by zero
		return (limit*tl + ah)/(tl + (p-m)/(high - low)) --factored version of above formula
--		return (limit-add)*tl/(tl + halfpoint) + add, halfpoint, add
	else -- assume low and x_low are both 0
		local halfpoint = limit*x_high/high-x_high
		return limit*tl/(tl + halfpoint)
--		return (limit-add)*tl/(tl + halfpoint) + add, halfpoint, add
	end
end

-- Compute a diminishing returns value based on a stat value that cannot go beyond a limit
-- stat == "str", "con",.... or a numeric value
-- limit = value approached as talent levels increase
-- high = value to match when stat = 100
-- low = value to match when stat = 10 (optional)
--	returns (limit - add)*stat/(stat + halfpoint) + add == add when STAT = 0 and limit when stat = infinity
-- halfpoint and add are internally computed to match the desired high/low values
-- note that the progression low->high->limit must be monotone, consistently increasing or decreasing
function _M:combatStatLimit(stat, limit, low, high)
	local x_low, x_high = 10,100 -- Implied stat levels for low and high values respectively
	stat = type(stat) == "string" and self:getStat(stat,nil,true) or stat
	if low then
		local p = limit*(x_high-x_low)
		local m = x_high*high - x_low*low
--		local halfpoint = (p-m)/(high - low) -- point at which half progress towards the limit is reached
--		local add = (limit*(x_high*low-x_low*high) + high*low*(x_low-x_high))/(p-m)
		local ah = (limit*(x_high*low-x_low*high)+ high*low*(x_low-x_high))/(high - low) -- add*halfpoint product calculated at once to avoid possible divide by zero
		return (limit*stat + ah)/(stat + (p-m)/(high - low)) --factored version of above formula
--		return (limit-add)*stat/(stat + halfpoint) + add, halfpoint, add
	else -- assume low and x_low are both 0
		local halfpoint = limit*x_high/high-x_high
		return limit*stat/(stat + halfpoint)
--		return (limit-add)*stat/(stat + halfpoint) + add, halfpoint, add
	end
end

--- Gets the dammod table for a given weapon.
function _M:getDammod(combat)
	combat = combat or self.combat or {}

	local dammod = table.clone(combat.dammod or {str = 0.6}, true)

	local sub = function(from, to)
		dammod[to] = (dammod[from] or 0) + (dammod[to] or 0)
		dammod[from] = nil
	end

	if combat.talented == 'knife' and self:knowTalent('T_LETHALITY') then sub('str', 'cun') end
	if combat.talented and self:knowTalent('T_STRENGTH_OF_PURPOSE') then sub('str', 'mag') end
	if self:attr 'use_psi_combat' then
		sub('str', 'wil')
		sub('dex', 'cun')
	end

	-- Add stuff like lethality here.
	local hd = {"Combat:getDammod:subs", combat=combat, dammod=dammod, sub=sub}
	if self:triggerHook(hd) then dammod = hd.dammod end

	local add = function(stat, val)
		dammod[stat] = (dammod[stat] or 0) + val
	end

	if self:knowTalent(self.T_SUPERPOWER) then add('wil', 0.3) end
	if self:knowTalent(self.T_ARCANE_MIGHT) then add('mag', 0.5) end

	return dammod
end

--- Gets the damage
function _M:combatDamage(weapon, adddammod)
	weapon = weapon or self.combat or {}

	local dammod = self:getDammod(weapon)

	local totstat = 0
	for stat, mod in pairs(dammod) do
		totstat = totstat + self:getStat(stat) * mod
	end
	if adddammod then
		for stat, mod in pairs(adddammod) do
			totstat = totstat + self:getStat(stat) * mod
		end
	end

	if self:attr("use_psi_combat") then
		totstat = totstat * (0.8 + self:callTalent(self.T_RESONANT_FOCUS, "bonus")/100)
	end

	local talented_mod = 1 + self:combatTrainingPercentInc(weapon)

	local power = math.max((weapon.dam or 1), 1)
	power = (math.sqrt(power / 10) - 1) * 0.5 + 1
--	print(("[COMBAT DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
	return self:rescaleDamage(0.3*(self:combatPhysicalpower(nil, weapon) + totstat) * power * talented_mod)
end

function _M:combatPhysicalpower(mod, weapon, add)
	mod = mod or 1
	add = add or 0
	if self:knowTalent(Talents.T_ARCANE_DESTRUCTION) then
		add = add + self:combatSpellpower() * self:callTalent(Talents.T_ARCANE_DESTRUCTION, "getSPMult")
	end
	if self:isTalentActive(Talents.T_BLOOD_FRENZY) then
		add = add + self.blood_frenzy
	end
	if self:knowTalent(self.T_BLOODY_BUTCHER) then
		add = add + self:callTalent(Talents.T_BLOODY_BUTCHER, "getDam")
	end
	if self:knowTalent(self.T_EMPTY_HAND) and self:isUnarmed() then
		local t = self:getTalentFromId(self.T_EMPTY_HAND)
		add = add + t.getDamage(self, t)
	end
	if self:attr("psychometry_power") then
		add = add + self:attr("psychometry_power")
	end

	if not weapon then
		local inven = self:getInven(self.INVEN_MAINHAND)
		if inven and inven[1] then weapon = self:getObjectCombat(inven[1], "mainhand") else weapon = self.combat end
	end

	add = add + self:combatTrainingDamage(weapon)

	local str = self:getStr()
	if self:knowTalent(Talents.T_STRENGTH_OF_PURPOSE) then
		str = self:getMag()
	end

	local d = math.max(0, (self.combat_dam or 0) + add + str) -- allows strong debuffs to offset strength
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	return self:rescaleCombatStats(d) * mod
end

--- Gets damage based on talent
function _M:combatTalentPhysicalDamage(t, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (self:combatPhysicalpower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod)
end

--- Gets spellpower
function _M:combatSpellpower(mod, add)
	mod = mod or 1
	add = add or 0
	if self:knowTalent(self.T_ARCANE_CUNNING) then
		add = add + self:callTalent(self.T_ARCANE_CUNNING,"getSpellpower") * self:getCun() / 100
	end
	if self:knowTalent(self.T_SHADOW_CUNNING) then
		add = add + self:callTalent(self.T_SHADOW_CUNNING,"getSpellpower") * self:getCun() / 100
	end
	if self:hasEffect(self.EFF_BLOODLUST) then
		add = add + self:hasEffect(self.EFF_BLOODLUST).power
	end

	local am = 1
	if self:attr("spellpower_reduction") then am = 1 / (1 + self:attr("spellpower_reduction")) end

	local d = math.max(0, (self.combat_spellpower or 0) + add + self:getMag())
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	return self:rescaleCombatStats(d) * mod * am
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
--	print("[TALENT WEAPON MULT]", self:getTalentLevel(t), base, max, t2, mult)
	return mult
end

--- Gets the off hand multiplier
function _M:getOffHandMult(combat, mult)
	local offmult = 1/2
	-- Take the bigger multiplier from Dual weapon training and Corrupted Strength
	if self:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
		offmult = math.max(offmult,self:callTalent(Talents.T_DUAL_WEAPON_TRAINING,"getoffmult"))
	end
	if self:knowTalent(Talents.T_CORRUPTED_STRENGTH) then
		offmult = math.max(offmult,self:callTalent(Talents.T_CORRUPTED_STRENGTH,"getoffmult"))
	end
	offmult = (mult or 1)*offmult
	if self:hasEffect(self.EFF_CURSE_OF_MADNESS) then
		local eff = self:hasEffect(self.EFF_CURSE_OF_MADNESS)
		if eff.level >= 1 and eff.unlockLevel >= 1 then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS]
			offmult = offmult + ((mult or 1) * def.getOffHandMultChange(eff.level) / 100)
		end
	end

	if combat and combat.no_offhand_penalty then
		return math.max(1, offmult)
	else
		return offmult
	end
end

--- Gets fatigue
function _M:combatFatigue()
	local min = self.min_fatigue or 0
	if self.fatigue < min then return min end
	if self:knowTalent(self.T_NO_FATIGUE) then return min end
	return self.fatigue
end

--- Gets spellcrit
function _M:combatSpellCrit()
	local crit = self.combat_spellcrit + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + 1

	return util.bound(crit, 0, 100)
end

--- Gets mindcrit
function _M:combatMindCrit(add)
	local add = add or 0
	if self:knowTalent(self.T_GESTURE_OF_POWER) then
		local t = self:getTalentFromId(self.T_GESTURE_OF_POWER)
		add = t.getMindCritChange(self, t)
	end

	local crit = self.combat_mindcrit + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + 1 + add

	return util.bound(crit, 0, 100)
end

--- Gets spellspeed
function _M:combatSpellSpeed()
	return 1 / math.max(self.combat_spellspeed, 0.1)
end

-- Gets mental speed
function _M:combatMindSpeed()
	return 1 / math.max(self.combat_mindspeed, 0.1)
end

--- Gets summon speed
function _M:combatSummonSpeed()
	return math.max(1 - ((self:attr("fast_summons") or 0) / 100), 0.1)
end

--- Computes physical crit chance reduction
function _M:combatCritReduction()
	local crit_reduction = 0
	if self:hasHeavyArmor() and self:knowTalent(self.T_ARMOUR_TRAINING) then
		local at = Talents:getTalentFromId(Talents.T_ARMOUR_TRAINING)
		crit_reduction = crit_reduction + at.getCriticalChanceReduction(self, at)
		if self:knowTalent(self.T_GOLEM_ARMOUR) then
			local ga = Talents:getTalentFromId(Talents.T_GOLEM_ARMOUR)
			crit_reduction = crit_reduction + ga.getCriticalChanceReduction(self, ga)
		end
	end
	if self:attr("combat_crit_reduction") then
		crit_reduction = crit_reduction + self:attr("combat_crit_reduction")
	end
	return crit_reduction
end

--- Computes physical crit for a damage
function _M:physicalCrit(dam, weapon, target, atk, def, add_chance, crit_power_add)
	self.turn_procs.is_crit = nil

	local tier_diff = self:getTierDiff(atk, def)

	local chance = self:combatCrit(weapon) + (add_chance or 0)
	crit_power_add = crit_power_add or 0

	if target:hasEffect(target.EFF_DISMAYED) then
		chance = 100
	end

	local crit = false
	if self:knowTalent(self.T_BACKSTAB) and target:attr("stunned") then chance = chance + self:callTalent(self.T_BACKSTAB,"getCriticalChance") end

	if target:attr("combat_crit_vulnerable") then
		chance = chance + target:attr("combat_crit_vulnerable")
	end
	if target:hasEffect(target.EFF_SET_UP) then
		local p = target:hasEffect(target.EFF_SET_UP)
		if p and p.src == self then
			chance = chance + p.power
		end
	end

	chance = chance - target:combatCritReduction()

	-- Scoundrel's Strategies
	if self:attr("cut") and target:knowTalent(self.T_SCOUNDREL) then
		chance = chance - target:callTalent(target.T_SCOUNDREL,"getCritPenalty")
	end

	if self:attr("stealth") and self:knowTalent(self.T_SHADOWSTRIKE) and not target:canSee(self) then -- bug fix
		chance = 100
		self.turn_procs.shadowstrike_crit = self:callTalent(self.T_SHADOWSTRIKE,"getMultiplier")
		crit_power_add = crit_power_add + self.turn_procs.shadowstrike_crit
	end

	if self:isAccuracyEffect(weapon, "axe") then
		local bonus = self:getAccuracyEffect(weapon, atk, def, 0.2, 10)
		print("[PHYS CRIT %] axe accuracy bonus", atk, def, "=", bonus)
		chance = chance + bonus
	end

	chance = util.bound(chance, 0, 100)

	print("[PHYS CRIT %]", self.turn_procs.auto_phys_crit and 100 or chance)
	if self.turn_procs.auto_phys_crit or rng.percent(chance) then
		if target:hasEffect(target.EFF_OFFGUARD) then
			crit_power_add = crit_power_add + 0.1
		end

		if self:isAccuracyEffect(weapon, "sword") then
			local bonus = self:getAccuracyEffect(weapon, atk, def, 0.004, 0.25)
			print("[PHYS CRIT %] sword accuracy bonus", atk, def, "=", bonus)
			crit_power_add = crit_power_add + bonus
		end

		self.turn_procs.is_crit = "physical"
		self.turn_procs.crit_power = (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		dam = dam * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		crit = true

		if self:knowTalent(self.T_EYE_OF_THE_TIGER) then self:triggerTalent(self.T_EYE_OF_THE_TIGER, nil, "physical") end

		self:fireTalentCheck("callbackOnCrit", "physical", dam, chance, target)
	end
	return dam, crit
end

--- Computes spell crit for a damage
function _M:spellCrit(dam, add_chance, crit_power_add)
	self.turn_procs.is_crit = nil

	crit_power_add = crit_power_add or 0
	local chance = self:combatSpellCrit() + (add_chance or 0)
	local crit = false

	-- Unlike physical crits we can't know anything about our target here so we can't check if they can see us
	if self:attr("stealth") and self:knowTalent(self.T_SHADOWSTRIKE) then
		chance = 100
		crit_power_add = crit_power_add + self:callTalent(self.T_SHADOWSTRIKE,"getMultiplier")
		self.turn_procs.shadowstrike_crit = self:callTalent(self.T_SHADOWSTRIKE,"getMultiplier")
	end

	print("[SPELL CRIT %]", self.turn_procs.auto_spell_crit and 100 or chance)
	if self.turn_procs.auto_spell_crit or rng.percent(chance) then
		self.turn_procs.is_crit = "spell"
		self.turn_procs.crit_power = (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		dam = dam * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		crit = true
		game.logSeen(self, "#{bold}#%s's spell attains critical power!#{normal}#", self.name:capitalize())

		if self:attr("mana_on_crit") then self:incMana(self:attr("mana_on_crit")) end
		if self:attr("vim_on_crit") then self:incVim(self:attr("vim_on_crit")) end
		if self:attr("paradox_on_crit") then self:incParadox(self:attr("paradox_on_crit")) end
		if self:attr("positive_on_crit") then self:incPositive(self:attr("positive_on_crit")) end
		if self:attr("negative_on_crit") then self:incNegative(self:attr("negative_on_crit")) end

		if self:attr("spellsurge_on_crit") then
			local power = self:attr("spellsurge_on_crit")
			self:setEffect(self.EFF_SPELLSURGE, 10, {power=power, max=power*3})
		end

		if self:isTalentActive(self.T_BLOOD_FURY) then
			local t = self:getTalentFromId(self.T_BLOOD_FURY)
			t.on_crit(self, t)
		end

		if self:isTalentActive(self.T_CORONA) then
			local t = self:getTalentFromId(self.T_CORONA)
			t.on_crit(self, t)
		end

		if self:knowTalent(self.T_EYE_OF_THE_TIGER) then self:triggerTalent(self.T_EYE_OF_THE_TIGER, nil, "spell") end

		self:fireTalentCheck("callbackOnCrit", "spell", dam, chance)
	end
	return dam, crit
end

--- Computes mind crit for a damage
function _M:mindCrit(dam, add_chance, crit_power_add)
	self.turn_procs.is_crit = nil

	crit_power_add = crit_power_add or 0
	local chance = self:combatMindCrit() + (add_chance or 0)
	local crit = false

	if self:attr("stealth") and self:knowTalent(self.T_SHADOWSTRIKE) then
		chance = 100
		crit_power_add = crit_power_add + self:callTalent(self.T_SHADOWSTRIKE,"getMultiplier")
		self.turn_procs.shadowstrike_crit = self:callTalent(self.T_SHADOWSTRIKE,"getMultiplier")
	end

	print("[MIND CRIT %]", self.turn_procs.auto_mind_crit and 100 or chance)
	if self.turn_procs.auto_mind_crit or rng.percent(chance) then
		self.turn_procs.is_crit = "mind"
		self.turn_procs.crit_power = (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		dam = dam * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		crit = true
		game.logSeen(self, "#{bold}#%s's mind surges with critical power!#{normal}#", self.name:capitalize())

		if self:attr("hate_on_crit") then self:incHate(self:attr("hate_on_crit")) end
		if self:attr("psi_on_crit") then self:incPsi(self:attr("psi_on_crit")) end
		if self:attr("equilibrium_on_crit") then self:incEquilibrium(self:attr("equilibrium_on_crit")) end

		if self:knowTalent(self.T_EYE_OF_THE_TIGER) then self:triggerTalent(self.T_EYE_OF_THE_TIGER, nil, "mind") end
		if self:knowTalent(self.T_LIVING_MUCUS) then self:callTalent(self.T_LIVING_MUCUS, "on_crit") end

		self:fireTalentCheck("callbackOnCrit", "mind", dam, chance)
	end
	return dam, crit
end

--- Do we get hit by our own AOE ?
function _M:spellFriendlyFire()
	local chance = (self:getLck() - 50) * 0.2
	if self:isTalentActive(self.T_SPELLCRAFT) then chance = chance + self:getTalentLevelRaw(self.T_SPELLCRAFT) * 20 end
	chance = chance + (self.combat_spell_friendlyfire or 0)

	chance = 100 - chance
	print("[SPELL] friendly fire chance", chance)
	return util.bound(chance, 0, 100)
end

--- Gets mindpower
function _M:combatMindpower(mod, add)
	mod = mod or 1
	add = add or 0

	if self:knowTalent(self.T_SUPERPOWER) then
		add = add + 50 * self:getStr() / 100
	end

	if self:knowTalent(self.T_GESTURE_OF_POWER) then
		local t = self:getTalentFromId(self.T_GESTURE_OF_POWER)
		add = add + t.getMindpowerChange(self, t)
	end
	if self:attr("psychometry_power") then
		add = add + self:attr("psychometry_power")
	end

	local d = math.max(0, (self.combat_mindpower or 0) + add + self:getWil() * 0.7 + self:getCun() * 0.4)

	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	return self:rescaleCombatStats(d) * mod
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
	local dam = (base + (self:getStat(stat))) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod
	dam =  dam * (1 - math.log10(dam * 2) / 7)
	dam = dam ^ (1 / 1.04)
	return self:rescaleDamage(dam)
end

--- Gets damage based on talent, basic stat, and interval
function _M:combatTalentIntervalDamage(t, stat, min, max, stat_weight)
	local stat_weight = stat_weight or 0.5
	local dam = min + (max - min)*((stat_weight * self:getStat(stat)/100) + (1 - stat_weight) * self:getTalentLevel(t)/6.5)
	dam =  dam * (1 - math.log10(dam * 2) / 7)
	dam = dam ^ (1 / 1.04)
	return self:rescaleDamage(dam)
end

--- Gets damage based on talent, stat, and interval
function _M:combatStatTalentIntervalDamage(t, stat, min, max, stat_weight)
	local stat_weight = stat_weight or 0.5
	return self:rescaleDamage(min + (max - min)*((stat_weight * self[stat](self)/100) + (1 - stat_weight) * self:getTalentLevel(t)/6.5))
end

--- Computes physical resistance
--- Fake denotes a check not actually being made, used by character sheets etc.
function _M:combatPhysicalResist(fake)
	local add = 0
	if not fake then
		add = add + (self:checkOnDefenseCall("physical") or 0)
	end
	if self:knowTalent(self.T_CORRUPTED_SHELL) then
		add = add + self:getCon() / 3
	end
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + self:callTalent(self.T_POWER_IS_MONEY, "getSaves")
	end

	-- To return later
	local d = self.combat_physresist + (self:getCon() + self:getStr() + (self:getLck() - 50) * 0.5) * 0.35 + add
	if self:attr("dazed") then d = d / 2 end


	local total = self:rescaleCombatStats(d)

	-- Psionic Balance
	if self:knowTalent(self.T_BALANCE) then
		local t = self:getTalentFromId(self.T_BALANCE)
		local ratio = t.getBalanceRatio(self, t)
		total = (1 - ratio)*total + self:combatMentalResist(fake)*ratio
	end
	return total
end

--- Computes spell resistance
--- Fake denotes a check not actually being made, used by character sheets etc.
function _M:combatSpellResist(fake)
	local add = 0
	if not fake then
		add = add + (self:checkOnDefenseCall("spell") or 0)
	end
	if self:knowTalent(self.T_CORRUPTED_SHELL) then
		add = add + self:getCon() / 3
	end
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + self:callTalent(self.T_POWER_IS_MONEY, "getSaves")
	end

	-- To return later
	local d = self.combat_spellresist + (self:getMag() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.35 + add
	if self:attr("dazed") then d = d / 2 end
	local total = self:rescaleCombatStats(d)

	-- Psionic Balance
	if self:knowTalent(self.T_BALANCE) then
		local t = self:getTalentFromId(self.T_BALANCE)
		local ratio = t.getBalanceRatio(self, t)
		total = (1 - ratio)*total + self:combatMentalResist(fake)*ratio
	end
	return total
end

--- Computes mental resistance
--- Fake denotes a check not actually being made, used by character sheets etc.
function _M:combatMentalResist(fake)
	local add = 0
	if not fake then
		add = add + (self:checkOnDefenseCall("mental") or 0)
	end
	if self:knowTalent(self.T_CORRUPTED_SHELL) then
		add = add + self:getCon() / 3
	end
	if self:knowTalent(self.T_STEADY_MIND) then
		local t = self:getTalentFromId(self.T_STEADY_MIND)
		add = add + t.getMental(self, t)
	end
	if self:knowTalent(self.T_POWER_IS_MONEY) then
		add = add + self:callTalent(self.T_POWER_IS_MONEY, "getSaves")
	end

	local d = self.combat_mentalresist + (self:getCun() + self:getWil() + (self:getLck() - 50) * 0.5) * 0.35 + add
	if self:attr("dazed") then d = d / 2 end

	local nm = self:hasEffect(self.EFF_CURSE_OF_NIGHTMARES)
	if nm and rng.percent(20) and not fake then
		d = d * (1-self.tempeffect_def.EFF_CURSE_OF_NIGHTMARES.getVisionsReduction(nm, nm.level)/100)
	end
	return self:rescaleCombatStats(d)
end

-- Called when a Save or Defense is checked
function _M:checkOnDefenseCall(type)
	local add = 0
	return add
end

--- Returns the resistance
function _M:combatGetResist(type)
	local power = 100
	if self.force_use_resist and self.force_use_resist ~= type then
		type = self.force_use_resist
		power = self.force_use_resist_percent or 100
	end

	local a = math.min((self.resists.all or 0) / 100,1) -- Prevent large numbers from inverting the resist formulas
	local b = math.min((self.resists[type] or 0) / 100,1)
	local r = math.min(100 * (1 - (1 - a) * (1 - b)), (self.resists_cap.all or 0) + (self.resists_cap[type] or 0))
	return r * power / 100
end

--- Returns the damage increase
function _M:combatHasDamageIncrease(type)
	if self.inc_damage[type] and self.inc_damage[type] ~= 0 then return true else return false end
end

--- Returns the damage increase
function _M:combatGetDamageIncrease(type, straight)
	local a = self.inc_damage.all or 0
	local b = self.inc_damage[type] or 0
	local inc = a + b
	if straight then return inc end

	if self.auto_highest_inc_damage and self.auto_highest_inc_damage[type] then
		local highest = self.inc_damage.all or 0
		for kind, v in pairs(self.inc_damage) do
			if kind ~= "all" then
				local inc = self:combatGetDamageIncrease(kind, true)
				highest = math.max(highest, inc)
			end
		end
		return highest + self.auto_highest_inc_damage[type]
	end

	return inc
end

--- Computes movement speed
function _M:combatMovementSpeed(x, y)
	local mult = 1
	if game.level and game.level.data.zero_gravity then
		mult = 3
	end

	local movement_speed = self.movement_speed
	if x and y and game.level.map:checkAllEntities(x, y, "creepingDark") and self:knowTalent(self.T_DARK_VISION) then
		local t = self:getTalentFromId(self.T_DARK_VISION)
		movement_speed = movement_speed + t.getMovementSpeedChange(self, t)
	end
	movement_speed = math.max(movement_speed, 0.1)
	return mult * (self.base_movement_speed or 1) / movement_speed
end

--- Computes see stealth
function _M:combatSeeStealth()
	local bonus = 0
	if self:knowTalent(self.T_PIERCING_SIGHT) then bonus = bonus + self:callTalent(self.T_PIERCING_SIGHT,"seePower") end
	if self:knowTalent(self.T_PRETERNATURAL_SENSES) then bonus = bonus + self:callTalent(self.T_PRETERNATURAL_SENSES, "sensePower") end
	-- level 50 with 100 cun ==> 50
	return self:combatScale(self.level/2 + self:getCun()/4 + (self:attr("see_stealth") or 0), 0, 0, 50, 50) + bonus -- Note bonus scaled separately from talents
end

--- Computes see invisible
function _M:combatSeeInvisible()
	local bonus = 0
	if self:knowTalent(self.T_PIERCING_SIGHT) then bonus = bonus + self:callTalent(self.T_PIERCING_SIGHT,"seePower") end
	if self:knowTalent(self.T_PRETERNATURAL_SENSES) then bonus = bonus + self:callTalent(self.T_PRETERNATURAL_SENSES, "sensePower") end
	return (self:attr("see_invisible") or 0) + bonus
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

--- Check if the actor has a weapon
function _M:hasWeaponType(type)
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon then return nil end
	if type and weapon.combat.talented ~= type then return nil end
	return weapon
end

--- Check if the actor has a cursed weapon
function _M:hasCursedWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon or not weapon.curse then
		return nil
	end
	local t = self:getTalentFromId(self.T_DEFILING_TOUCH)
	if not t.canCurseItem(self, t, weapon) then return nil end

	return weapon
end

--- Check if the actor has a cursed weapon
function _M:hasCursedOffhandWeapon()
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("OFFHAND") then return end
	local weapon = self:getInven("OFFHAND")[1]
	if not weapon or not weapon.combat or not weapon.curse then
		return nil
	end
	local t = self:getTalentFromId(self.T_DEFILING_TOUCH)
	if not t.canCurseItem(self, t, weapon) then return nil end

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

-- Get the number of free hands the actor has
function _M:getFreeHands()
	if not self:getInven("MAINHAND") or not self:getInven("OFFHAND") then return 0 end
	local weapon = self:getInven("MAINHAND")[1]
	local offweapon = self:getInven("OFFHAND")[1]
	if weapon and offweapon then return 0 end
	if weapon and weapon.twohanded then return 0 end
	if weapon or offweapon then return 1 end
	return 2
end

--- Check if the actor dual wields
function _M:hasDualWeapon(type)
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("MAINHAND") or not self:getInven("OFFHAND") then return end
	local weapon = self:getInven("MAINHAND")[1]
	local offweapon = self:getInven("OFFHAND")[1]
	if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
		return nil
	end
	if type and weapon.combat.talented ~= type then return nil end
	if type and offweapon.combat.talented ~= type then return nil end
	return weapon, offweapon
end

-- Get the weapons in the quick slot
function _M:hasDualWeaponQS(type)
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	if not self:getInven("QS_MAINHAND") or not self:getInven("QS_OFFHAND") then return end
	local weapon = self:getInven("QS_MAINHAND")[1]
	local offweapon = self:getInven("QS_OFFHAND")[1]
	if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
		return nil
	end
	if type and weapon.combat.talented ~= type then return nil end
	if type and offweapon.combat.talented ~= type then return nil end
	return weapon, offweapon
end

--- Check if the actor uses psiblades
function _M:hasPsiblades(main, off)
	if self:attr("disarmed") then
		return nil, "disarmed"
	end

	local weapon, offweapon = nil, nil
	if main then
		if not self:getInven("MAINHAND") then return end
		weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.combat or not weapon.psiblade_active then return nil, "unactivated psiblade" end
	end
	if off then
		if not self:getInven("OFFHAND") then return end
		offweapon = self:getInven("OFFHAND")[1]
		if not offweapon or not offweapon.combat or not offweapon.psiblade_active then return nil, "unactivated psiblade" end
	end
	return weapon, offweapon
end

--- Check if the actor has a light armor
function _M:hasLightArmor()
	if not self:getInven("BODY") then return end
	local armor = self:getInven("BODY")[1]
	if not armor or (armor.subtype ~= "cloth" and armor.subtype ~= "light" and armor.subtype ~= "mummy") then
		return nil
	end
	return armor
end

--- Check if the actor has a heavy armor
function _M:hasHeavyArmor()
	if not self:getInven("BODY") then return end
	local armor = self:getInven("BODY")[1]
	if not armor or (armor.subtype ~= "heavy" and armor.subtype ~= "massive") then
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

--- Check if the actor has a cloak
function _M:hasCloak()
	if not self:getInven("CLOAK") then return end
	local cloak = self:getInven("CLOAK")[1]
	if not cloak then
		return nil
	end
	return cloak
end

-- Unarmed Combat; this handles grapple checks and building combo points
-- Builds Comob; reduces the cooldown on all unarmed abilities on cooldown by one
function _M:buildCombo()
	local duration = 5
	local power = 1
	-- Combo String bonuses
	if self:knowTalent(self.T_COMBO_STRING) then
		local t = self:getTalentFromId(self.T_COMBO_STRING)
		if rng.percent(t.getChance(self, t)) then
			power = 2
		end
		duration = 5 + t.getDuration(self, t)
	end

	if self:knowTalent(self.T_RELENTLESS_STRIKES) then
		local t = self:getTalentFromId(self.T_RELENTLESS_STRIKES)
		self:incStamina(t.getStamina(self, t))
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
		local p = self:hasEffect(self.EFF_GRAPPLING)
		if p.trgt then
			p.trgt:removeEffect(p.trgt.EFF_GRAPPLED)
		end
		self:removeEffect(self.EFF_GRAPPLING)
	end
end

-- grapple size check; compares attackers size and targets size
function _M:grappleSizeCheck(target)
	local size = target.size_category - self.size_category
	if size > 1 then
		self:logCombat(target, "#Source#'s grapple fails because #Target# is too big!")
		return true
	else
		return false
	end
end

-- Starts the grapple
function _M:startGrapple(target)
	-- pulls boosted grapple effect from the clinch talent if known
	local grappledParam = {src = self, apply_power = 1, silence = 0, power = 1, slow = 0, reduction = 0}
	local grappleParam = {sharePct = 0, drain = 0, trgt = target }
	local duration = 5
	if self:knowTalent(self.T_CLINCH) then
		local t = self:getTalentFromId(self.T_CLINCH)
		if self:knowTalent(self.T_CRUSHING_HOLD) then
			local t2 = self:getTalentFromId(self.T_CRUSHING_HOLD)
			grappledParam = t2.getBonusEffects(self, t2) -- get the 4 bonus parameters first
		end
		local power = self:physicalCrit(t.getPower(self, t), nil, target, self:combatAttack(), target:combatDefense())
		grappledParam["power"] = power -- damage/turn set by Clinch
		duration = t.getDuration(self, t)

		grappleParam["drain"] = t.getDrain(self, t) -- stamina/turn set by Clinch
		grappleParam["sharePct"] = t.getSharePct(self, t) -- damage shared with grappled set by Clinch

	end
	-- oh for the love of god why didn't I rewrite this entire structure
	grappledParam["src"] = self
	grappledParam["apply_power"] = self:combatPhysicalpower()
	-- Breaks the grapple before reapplying
	if self:hasEffect(self.EFF_GRAPPLING) then
		self:removeEffect(self.EFF_GRAPPLING, true)
		target:setEffect(target.EFF_GRAPPLED, duration, grappledParam, true)
		self:setEffect(self.EFF_GRAPPLING, duration, grappleParam, true)
		return true
	elseif target:canBe("pin") then
		target:setEffect(target.EFF_GRAPPLED, duration, grappledParam)
		target:crossTierEffect(target.EFF_GRAPPLED, self:combatPhysicalpower())
		self:setEffect(self.EFF_GRAPPLING, duration, grappleParam)
		return true
	else
		game.logSeen(target, "%s resists the grapple!", target.name:capitalize())
		return false
	end
end

-- Display Combat log messages, highlighting the player and taking LOS and visibility into account
-- #source#|#Source# -> <displayString> self.name|self.name:capitalize()
-- #target#|#Target# -> target.name|target.name:capitalize()
function _M:logCombat(target, style, ...)
	if not game.uiset or not game.uiset.logdisplay then return end
	local visible, srcSeen, tgtSeen = game:logVisible(self, target)  -- should a message be displayed?
	if visible then game.uiset.logdisplay(game:logMessage(self, srcSeen, target, tgtSeen, style, ...)) end
end
