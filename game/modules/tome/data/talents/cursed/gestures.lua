-- ToME - Tales of Middle-Earth
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

local function canUseGestures(self)
	local nb = 0
	if self:getInven("MAINHAND") then
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then nb = nb + 1 end
	end
		
	if self:getInven("OFFHAND") then
		local weapon = self:getInven("OFFHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then nb = nb + 1 end
	end
	
	return nb == 2 and true or false
end

newTalent{
	name = "Gesture of Pain",
	type = {"cursed/gestures", 1},
	mode = "sustained",
	no_energy = true,
	require = cursed_cun_req1,
	points = 5,
	random_ego = "attack",
	tactical = { ATTACK = 2 },
	getBaseDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 130)
	end,
	getBonusDamage = function(self, t)
		local bonus = 0
		if self:getInven("MAINHAND") then
			local weapon = self:getInven("MAINHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.dam or 1) end
		end
		if self:getInven("OFFHAND") then
			local weapon = self:getInven("OFFHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.dam or 1) end
		end
		return bonus
	end,
	getBonusCritical = function(self, t)
		local bonus = 0
		if self:getInven("MAINHAND") then
			local weapon = self:getInven("MAINHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.physcrit or 1) end
		end
		if self:getInven("OFFHAND") then
			local weapon = self:getInven("OFFHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.physcrit or 1) end
		end
	
		return bonus
	end,
	getStunChance = function(self, t)
		return math.max(10, self:getTalentLevelRaw(t) * 2)
	end,
	preAttack = function(self, t, target)
		if not canUseGestures(self) then
			game.logPlayer(self, "You do not have a free or mindstar-equipped hand to use Gesture of Pain.")
			return false
		end

		return true
	end,
	attack = function(self, t, target)
		local hit = false

		local mindpower = self:combatMindpower()
		local baseDamage = t.getBaseDamage(self, t)
		local bonusDamage = t.getBonusDamage(self, t)
		local bonusCritical = t.getBonusCritical(self, t)
		if self:checkHit(mindpower, target:combatMentalResist()) then
			local damage = self:mindCrit(baseDamage * rng.float(0.5, 1) + bonusDamage, bonusCritical)
			self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, DamageType.MIND, { dam=damage,alwaysHit=true,crossTierChance=25 })
			game:playSoundNear(self, "actions/melee_hit_squish")
			hit = true
		else
			game.logSeen(self, "%s resists the Gesture of Pain.", target.name:capitalize())
			game:playSoundNear(self, "actions/melee_miss")
		end

		if hit then
			local stunChance = t.getStunChance(self, t)
			if rng.percent(stunChance) then
				target:setEffect(target.EFF_STUNNED, 3, {apply_power=self:combatMindpower()})
			end
			
			if self:knowTalent(self.T_GESTURE_OF_MALICE) then
				local tGestureOfMalice = self:getTalentFromId(self.T_GESTURE_OF_MALICE)
				local resistAllChange = tGestureOfMalice.getResistAllChange(self, tGestureOfMalice)
				target:setEffect(target.EFF_MALIGNED, tGestureOfMalice.getDuration(self, tGestureOfMalice), { resistAllChange=resistAllChange })
			end
		
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=colors.VIOLET})
		end

		return self:combatSpeed(), hit
	end,
	activate = function(self, t)
		return {  }
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local baseDamage = t.getBaseDamage(self, t)
		local stunChance = t.getStunChance(self, t)
		local bonusDamage = t.getBonusDamage(self, t)
		local bonusCritical = t.getBonusCritical(self, t)
		return ([[Use a gesture of pain in place of an normal attack to strike into the minds of your enemies, inflicting between %0.1f and %0.1f mind damage. If you strike your target, there is a %d%% chance to stun your opponent for 3 turns.
		25%% chance of cross tier effects. Requires at least one free or mindstar-equipped hand. Can cause critical hits with cross tier effects. The damage will increase with your Mindpower. Mindstars bonuses from damage and physical criticals (+%d damage, +%d critical chance)]]):format(damDesc(self, DamageType.MIND, baseDamage * 0.5), damDesc(self, DamageType.MIND, baseDamage), stunChance, bonusDamage, bonusCritical)
	end,
}

newTalent{
	name = "Gesture of Malice",
	type = {"cursed/gestures", 2},
	require = cursed_cun_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t)
		return 5
	end,
	getResistAllChange = function(self, t)
		return -math.min(30, (math.sqrt(self:getTalentLevel(t)) - 0.5) * 12)
	end,
	info = function(self, t)
		local resistAllChange = t.getResistAllChange(self, t)
		local duration = t.getDuration(self, t)
		return ([[Enhance your Gesture of Pain with a malicious curse that causes any victim that is struck to have all resistances lowered by %d%% for %d turns.
		]]):format(-resistAllChange, duration)
	end,
}

newTalent{
	name = "Gesture of Power",
	type = {"cursed/gestures", 3},
	require = cursed_cun_req3,
	mode = "passive",
	points = 5,
	getMindpowerChange = function(self, t)
		if not canUseGestures(self) then return 0 end

		return math.floor(math.min(20, self:getTalentLevel(t) * 2))
	end,
	getMindCritChange = function(self, t)
		if not canUseGestures(self) then return 0 end

		return math.floor(math.min(14, self:getTalentLevel(t) * 1.2))
	end,
	info = function(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t, 2)
		local mindCritChange = t.getMindCritChange(self, t)
		return ([[Enhance your mental attacks with a single gesture. You gain +%d mindpower and +%d%% chance to inflict critical damage with mind-based attacks (current chance is %d%%).
		Requires at least one free or mindstar-equipped hand.]]):format(mindpowerChange, mindCritChange, self:combatMindCrit())
	end,
}

newTalent{
	name = "Gesture of Guarding",
	type = {"cursed/gestures", 4},
	require = cursed_cun_req4,
	mode = "passive",
	cooldown = 10,
	points = 5,
	getDamageChange = function(self, t)
		if not canUseGestures(self) then return 0 end
		
		return -math.pow(self:getTalentLevel(t), 0.5) * 14
	end,
	getCounterAttackChance = function(self, t)
		if not canUseGestures(self) then return 0 end
		return math.sqrt(self:getTalentLevel(t)) * 4
	end,
	on_hit = function(self, t, who)
		if rng.percent(t.getCounterAttackChance(self, t)) and self:isTalentActive(self.T_GESTURE_OF_PAIN) and canUseGestures(self) then
			game.logSeen(self, "#F53CBE#%s lashes back at %s!", self.name:capitalize(), who.name)
			local tGestureOfPain = self:getTalentFromId(self.T_GESTURE_OF_PAIN)
			tGestureOfPain.attack(self, tGestureOfPain, who)
		end
	end,
	info = function(self, t)
		local damageChange = t.getDamageChange(self, t)
		local counterAttackChance = t.getCounterAttackChance(self, t)
		return ([[You guard against melee damage with a sweep of you hand. All damage from melee attacks is reduced by %d%%. There is also a %d%% chance of counterattacking when Gesture of Pain is active.
		Requires at least one free or mindstar-equipped hand.]]):format(-damageChange, counterAttackChance)
	end,
}
