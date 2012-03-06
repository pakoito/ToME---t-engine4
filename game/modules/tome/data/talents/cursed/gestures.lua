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

newTalent{
	name = "Gesture of Pain",
	type = {"cursed/gestures", 1},
	mode = "sustained",
	require = cursed_cun_req1,
	points = 5,
	random_ego = "attack",
	tactical = { ATTACK = 2 },
	getBaseDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 125)
	end,
	getSecondAttackChance = function(self, t)
		return 20
	end,
	preAttack = function(self, t, target)
		if self.hate < 1 then
			game.logPlayer(self, "You do not have enough hate to use Gesture of Pain.")
			return false
		end
		if self:getFreeHands() == 0 then
			game.logPlayer(self, "You do not have a free hand to use Gesture of Pain.")
			return false
		end

		return true
	end,
	attack = function(self, t, target)
		local freeHands = self:getFreeHands()
		local hit = false

		local mindpower = self:combatMindpower()
		local baseDamage = t.getBaseDamage(self, t)
		if self:checkHit(mindpower, target:combatMentalResist()) then
			local damage = baseDamage * rng.float(0.5, 1)
			self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, DamageType.MIND, { dam=damage,alwaysHit=true,criticals=true,crossTierChance=100 })
			self:incHate(-1)
			game:playSoundNear(self, "actions/melee_hit_squish")
			hit = true
		else
			game.logSeen(self, "%s resists the Gesture of Pain.", target.name:capitalize())
			game:playSoundNear(self, "actions/melee_miss")
		end

		if not target.dead and freeHands > 1 and self.hate >= 1 and rng.chance(t.getSecondAttackChance(self, t)) then
			if self:checkHit(mindpower, target:combatMentalResist()) then
				local damage = baseDamage * rng.float(0.5, 1)
				self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, DamageType.MIND, { dam=damage,alwaysHit=true,criticals=true,crossTierChance=100 })
				game:playSoundNear(self, "actions/melee_hit_squish")
				hit = true
				self:incHate(-1)
			else
				game.logSeen(self, "%s resists the Gesture of Pain.", target.name:capitalize())
				game:playSoundNear(self, "actions/melee_miss")
			end
		end

		if hit then
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=colors.VIOLET})
		end

		return self:combatSpeed(), hit
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local baseDamage = t.getBaseDamage(self, t)
		local secondAttackChance = t.getSecondAttackChance(self, t)
		return ([[Use a gesture of pain in place of an normal attack to strike into the minds of your enemies, inflicting between %0.1f and %0.1f mind damage. Requires a single free hand. A second free hand adds a %d%% chance of a second attack. Each hit costs 1 hate.
		Can cause critical hits with cross tier effects. The damage will increase with your Mindpower.]]):format(damDesc(self, DamageType.MIND, baseDamage * 0.5), damDesc(self, DamageType.MIND, baseDamage), secondAttackChance)
	end,
}

newTalent{
	name = "Gesture of Command",
	type = {"cursed/gestures", 2},
	require = cursed_cun_req2,
	mode = "passive",
	points = 5,
	getMindpowerChange = function(self, t, freeHands)
		freeHands = freeHands or self:getFreeHands()
		if freeHands == 0 then return 0 end

		local change = math.pow(self:getTalentLevel(t), 0.7) * 4
		if freeHands > 1 then change = change * 1.4 end
		return math.floor(change)
	end,
	info = function(self, t)
		local mindpowerChange1 = t.getMindpowerChange(self, t, 1)
		local mindpowerChange2 = t.getMindpowerChange(self, t, 2)
		return ([[Command the forces of your mind through your gestures. With 1 free hand, you gain %d mindpower. With 2 free hands, you gain %d mindpower.]]):format(mindpowerChange1, mindpowerChange2)
	end,
}

newTalent{
	name = "Gesture of Power",
	type = {"cursed/gestures", 3},
	require = cursed_cun_req3,
	mode = "passive",
	points = 5,
	getMindCritChange = function(self, t, freeHands)
		freeHands = freeHands or self:getFreeHands()
		if freeHands == 0 then return 0 end

		local change = math.pow(self:getTalentLevel(t), 0.5) * 2
		if freeHands > 1 then change = change * 1.4 end
		return change
	end,
	info = function(self, t)
		local mindCritChange1 = t.getMindCritChange(self, t, 1)
		local mindCritChange2 = t.getMindCritChange(self, t, 2)
		return ([[Enhance your mental attacks with a single gesture, granting a chance to inflict critical damage with certain mind attacks. With 1 free hand, you gain a %0.1f%% chance. With 2 free hands, you gain %0.1f%% chance.]]):format(mindCritChange1, mindCritChange2)
	end,
}

newTalent{
	name = "Gesture of Guarding",
	type = {"cursed/gestures", 4},
	require = cursed_cun_req4,
	mode = "sustained",
	cooldown = 10,
	points = 5,
	getDamageResistChange = function(self, t, distance, freeHands)
		freeHands = freeHands or self:getFreeHands()
		if freeHands == 0 then return 0 end

		local change = math.pow(self:getTalentLevel(t), 0.5) * 1.15
		if freeHands > 1 then change = change * 1.4 end
		return change * math.min(7, distance)
	end,
	getIncDamageChange = function(self, t, distance)
		local change = -(2 + math.pow(self:getTalentLevel(t), 0.5) * 0.8)
		return change * math.min(7, distance)
	end,
	on_damageReceived = function(self, t, type, dam, src)
		if src and src.x and src.y and (self.x ~= src.x or self.y ~= src.y) and self:hasLOS(src.x, src.y) then
			local distance = core.fov.distance(src.x, src.y, self.x, self.y)
		print("===dec by", t.getDamageResistChange(self, t, distance), distance)
			dam = dam * (100 - t.getDamageResistChange(self, t, distance)) / 100
		end
		return dam
	end,
	on_damageInflicted = function(self, t, type, dam, target)
		if target and target.x and target.y and (self.x ~= target.x or self.y ~= target.y) and self:hasLOS(target.x, target.y) then
			local distance = core.fov.distance(target.x, target.y, self.x, self.y)
		print("===inc by", t.getIncDamageChange(self, t, distance), distance)
			dam = dam * (100 + t.getIncDamageChange(self, t, distance)) / 100
		end
		return dam
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damageResistChange1 = t.getDamageResistChange(self, t, 1, 1)
		local damageResistChangeMax1 = t.getDamageResistChange(self, t, 1000, 1)
		local damageResistChange2 = t.getDamageResistChange(self, t, 1, 2)
		local damageResistChangeMax2 = t.getDamageResistChange(self, t, 1000, 2)
		local incDamageChange = t.getIncDamageChange(self, t, 1)
		local incDamageChangeMax = t.getIncDamageChange(self, t, 1000)
		return ([[While active, you guard against incoming damage with a sweep of your hand. The farther the source of damage the more it will be reduced, with a maximum reduction at range 7. With 1 free hand, damage taken is reduced by %0.1f%% per space away (up to a maximum of %0.1f%%). With 2 free hands it is reduced by %0.1f%% (up to a maximum of %0.1f%%). Guarding yourself requires great focus and reduces the damage you inflict at range by %0.1f%% per space away (up to a maximum of %0.1f%%).]]):format(damageResistChange1, damageResistChangeMax1, damageResistChange2, damageResistChangeMax2, -incDamageChange, -incDamageChangeMax)
	end,
}
