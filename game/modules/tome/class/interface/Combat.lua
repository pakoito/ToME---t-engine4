require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Target = require "engine.Target"

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
			-- TODO: implement !
		elseif target.player and self.can_talk then
			-- TODO: implement! request the player to talk
		elseif self.move_others then
			-- Displace
			game.level.map:remove(self.x, self.y, Map.ACTOR)
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			game.level.map(self.x, self.y, Map.ACTOR, target)
			game.level.map(target.x, target.y, Map.ACTOR, self)
			self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		end
	end
end

--- Makes the death happen!
--[[
The ToME combat system has the following attributes:
- attack: increases chances to hit against high defence
- defence: increases chances to miss against high attack power
- armor: direct reduction of damage done
- armor penetration: reduction of target's armor
- damage: raw damage done
]]
function _M:attackTarget(target, damtype, mult, noenergy)
	damtype = damtype or DamageType.PHYSICAL
	mult = mult or 1
	local speed = nil

	-- All weaponsin main hands
	if self:getInven(self.INVEN_MAINHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
			if o.combat then
				local s = self:attackTargetWith(target, o.combat, damtype, mult)
				speed = math.max(speed or 0, s)
			end
		end
	end
	-- All wpeaons in off hands
	if self:getInven(self.INVEN_OFFHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
			if o.combat then
				local s = self:attackTargetWith(target, o.combat, damtype, mult)
				speed = math.max(speed or 0, s)
			end
		end
	end

	-- Barehanded ?
	if not speed then
		speed = self:attackTargetWith(target, self.combat, damtype, mult)
	end

	-- We use up our own energy
	if speed and not noenergy then
		self:useEnergy(game.energy_to_act * speed)
		self.did_energy = true
	end
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

--- Attacks with one weapon
function _M:attackTargetWith(target, weapon, damtype, mult)
	-- Does the blow connect? yes .. complex :/
	local atk, def = self:combatAttack(weapon), target:combatDefense()
	local dam, apr, armor = self:combatDamage(weapon), self:combatAPR(weapon), target:combatArmor()

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	if self:checkHit(atk, def) then
		local dam = dam - math.max(0, armor - apr)
		dam = dam * mult
		dam = self:physicalCrit(dam, weapon)
		DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam))
	else
		game.logSeen(target, "%s misses %s.", self.name:capitalize(), target.name)
	end

	return self:combatSpeed(weapon)
end

--- Gets the defense
function _M:combatDefense()
	return self.combat_def + self:getDex() - 10
end

--- Gets the armor
function _M:combatArmor()
	return self.combat_armor
end

--- Gets the attack
function _M:combatAttack(weapon)
	weapon = weapon or self.combat
	return self.combat_atk + (weapon.atk or 0) + (self:getStr(50) - 5) + (self:getDex(50) - 5)
end

--- Gets the armor penetration
function _M:combatAPR(weapon)
	weapon = weapon or self.combat
	return self.combat_apr + (weapon.apr or 0)
end

--- Gets the weapon speed
function _M:combatSpeed(weapon)
	weapon = weapon or self.combat
	return self.combat_physspeed + (weapon.physspeed or 1)
end

--- Gets the crit rate
function _M:combatCrit(weapon)
	weapon = weapon or self.combat
	return self.combat_physcrit + (self:getCun() - 10) * 0.3 + (weapon.physcrit or 1)
end

--- Gets the damage
function _M:combatDamage(weapon)
	weapon = weapon or self.combat
	local add = 0
	if weapon.dammod then
		for stat, mod in pairs(weapon.dammod) do
			add = add + (self:getStat(stat) - 10) * mod
		end
	end
	return self.combat_armor + (weapon.dam or 1) + add
end

--- Gets spellpower
function _M:combatSpellpower(mod)
	mod = mod or 1
	return (self.combat_spellpower + self:getMag()) * mod
end

--- Gets spellcrit
function _M:combatSpellCrit()
	return self.combat_spellcrit + 1
end

--- Gets spellspeed
function _M:combatSpellSpeed()
	return self.combat_spellspeed + (self:getCun() - 10) * 0.3 + 1
end

--- Computes physical crit for a damage
function _M:physicalCrit(dam, weapon)
	local chance = self:combatCrit(weapon)
	if rng.percent(chance) then
		dam = dam * 2
	end
	return dam
end

--- Computes spell crit for a damage
function _M:spellCrit(dam)
	local chance = self:combatSpellCrit()
	if rng.percent(chance) then
		dam = dam * 2
	end
	return dam
end

--- Computes physical resistance
function _M:combatPhysicalResist()
	return self.combat_physresist + (self:getCon() + self:getStr()) * 0.5
end

--- Computes spell resistance
function _M:combatSpellResist()
	return self.combat_spellresist + (self:getMag() + self:getWil()) * 0.5
end
