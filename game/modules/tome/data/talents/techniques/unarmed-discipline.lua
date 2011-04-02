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

-- strength, cunning, and dexterity damage combined
local function getTriStat(self, t, low, high)
	low = low / 3
	high = high / 3
	return	self:combatTalentStatDamage(t, "str", low, high) + self:combatTalentStatDamage(t, "cun", low, high) + self:combatTalentStatDamage(t, "dex", low, high)
end

newTalent{
	name = "Push Kick",
	type = {"technique/unarmed-discipline", 1},
	require = techs_dex_req1,
	points = 5,
	cooldown = 6,
	stamina = 12,
	tactical = { ATTACK = 2, ESCAPE = 2 },
	requires_target = true,
	getDamage = function(self, t) return getTriStat(self, t, 30, 300) * (1 + getStrikingStyle(self, dam)) end,
	getPush = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/4) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local hit = target:checkHit(self:combatAttack(), target:combatDefense(), 0, 95, 5 - self:getTalentLevel(t) / 2)
	--	local hit = self:attackTarget(target, nil, nil, true)

		-- Try to knockback !
		if hit then
			local can = function(target)
				if target:checkHit(self:combatAttack(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t))
					return true
				else
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t))
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end

			end

			if can(target) then target:knockback(self.x, self.y, t.getPush(self, t), can) end

			-- move the attacker back
			self:knockback(target.x, target.y, 1)
			self:breakGrapples()
			self:buildCombo()

		else
			game.logSeen(target, "%s misses %s.", self.name:capitalize(), target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local push =t.getPush(self, t)
		return ([[A push kick that knocks the target back %d tiles, moves you back 1 tile, and inflicts %0.2f physical damage.  If another creature is in the way that creature will be affected too.  Targets knocked into other targets may take extra damage.
		This is considered a strike for the purposes of stance damage bonuses, will earn one combo point, and will break any grapples you're maintaining.
		The damage will scale with the strength, dexterity, and cunning stats.]])
		:format(push, damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}

newTalent{
	name = "Defensive Throw",
	type = {"technique/unarmed-discipline", 2},
	require = techs_dex_req2,
	mode = "passive",
	points = 5,
	getDamage = function(self, t) return getTriStat(self, t, 10, 100) * (1 + getGrapplingStyle(self, dam)) end,
	getDamageTwo = function(self, t) return getTriStat(self, t, 10, 100) * (1.5 + getGrapplingStyle(self, dam)) end,
	do_throw = function(self, target, t)

		local hit = self:checkHit(self:combatAttack(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2)

		-- if grappled stun
		if hit and target:canBe("knockback") and target:isGrappled(self) then
			self:project(target, target.x, target.y, DamageType.PHYSICAL, self:physicalCrit(t.getDamageTwo(self, t), nil, target))
			game.logSeen(target, "%s has been slammed into the ground!", target.name:capitalize())
			-- see if the throw stuns the enemy
			if hit and target:canBe("stun")then
				target:setEffect(target.EFF_STUNNED, 2, {})
			end
		-- if not grappled daze
		elseif hit and target:canBe("knockback") then
			self:project(target, target.x, target.y, DamageType.PHYSICAL, self:physicalCrit(t.getDamage(self, t), nil, target))
			game.logSeen(target, "%s has been thrown to the ground!", target.name:capitalize())
			-- see if the throw dazes the enemy
			if hit and target:canBe("stun")then
				target:setEffect(target.EFF_DAZED, 2, {})
			end
		end

	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagetwo = t.getDamageTwo(self, t)
		return ([[When you avoid a melee blow you have a %d%% chance to throw the target to the ground.  If the throw lands the target will take %0.2f damage and be dazed for 2 turns or %0.2f damage and be stunned for 2 turns if grappled.
		The chance of throwing increases with the cunning stat and the damage will scale with the strength stat, dexterity, and cunning stats.
		This is considered a grapple for the purposes of stance damage bonuses.]]):format(self:getTalentLevel(t) * (5 + self:getCun(5)), damDesc(self, DamageType.PHYSICAL, (damage)), damDesc(self, DamageType.PHYSICAL, (damagetwo)))
	end,
}

newTalent{
	name = "Breath Control",
	type = {"technique/unarmed-discipline", 3},
	require = techs_dex_req3,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { BUFF = 1, STAMINA = 2 },
	getSpeed = function(self, t) return 0.1 end,
	getStamina = function(self, t) return self:getTalentLevel(t) * 1.5 end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("global_speed", -t.getSpeed(self, t)),
			stamina = self:addTemporaryValue("stamina_regen", t.getStamina(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("global_speed", p.speed)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t)
		local stamina = t.getStamina(self, t)
		return ([[You focus your breathing, increasing stamina regeneration by %0.2f per turn at the cost of %d%% global speed.]]):
		format(stamina, speed * 100)
	end,
}

newTalent{
	name = "Roundhouse Kick",
	type = {"technique/unarmed-discipline", 4},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 18,
	range = 0,
	radius = function(self, t) return 1 end,
	tactical = { ATTACKAREA = 2, DISABLE = 2 },
	requires_target = true,
	getDamage = function(self, t) return getTriStat(self, t, 20, 600) * (1 + getStrikingStyle(self, dam)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end

		self:breakGrapples()

		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=self:physicalCrit(t.getDamage(self, t), nil, target), dist=4})

		self:buildCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attack your foes in a frontal arc with a roundhouse kick that deals %0.2f physical damage and knocks your foes back.
		This is considered a strike for the purposes of stance damage bonuses, will earn one combo point, and break any grapples you're maintaining.
		The knockback chance will increase with the strength stat and the damage will scale with the strength, dexterity, and cunning stats.]])
		:format(damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}