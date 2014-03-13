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


newTalent{
	name = "Shattering Shout",
	type = {"technique/warcries", 1},
	require = techs_req_high1,
	points = 5,
	cooldown = 7,
	stamina = 20,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	getdamage = function(self,t) return self:combatScale(self:getTalentLevel(t) * self:getStr(), 60, 10, 267, 500)  end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, t.getdamage(self,t))
		if self:getTalentLevel(t) >= 5 then
			self:project(tg, x, y, function(px, py)
				local proj = game.level.map(px, py, Map.PROJECTILE)
				if not proj then return end
				proj:terminate(x, y)
				game.level:removeEntity(proj, true)
				proj.dead = true
				self:logCombat(proj, "#Source# shatters '#Target#'.")
			end)
		end
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=8, size=2, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		return ([[Release a powerful shout, doing %0.2f physical damage in a radius %d cone in front of you.
		At level 5 the shout is so strong it shatters all incomming projectiles caught inside.
		The damage increases with your Strength.]])
		:format(damDesc(self, DamageType.PHYSICAL, t.getdamage(self,t)), t.radius(self,t))
	end,
}

newTalent{
	name = "Second Wind",
	type = {"technique/warcries", 2},
	require = techs_req_high2,
	points = 5,
	cooldown = 50,
	no_energy = true,
	tactical = { STAMINA = 2 },
	getRestore = function(self, t) return self:combatTalentLimit(t, 100, 27, 55) end,
	action = function(self, t)
		self:incStamina(t.getRestore(self, t)*self.max_stamina/ 100)
		return true
	end,
	info = function(self, t)
		return ([[Take a deep breath to recover %d%% of your stamina.]]):
		format(t.getRestore(self, t))
	end,
}

newTalent{
	name = "Battle Shout",
	type = {"technique/warcries", 3},
	require = techs_req_high3,
	points = 5,
	cooldown = 30,
	stamina = 5,
	tactical = { DEFEND = 2, BUFF = 1 },
	getdur = function(self,t) return math.floor(self:combatTalentLimit(t, 30, 7, 15)) end, -- Limit to < 30
	getPower = function(self, t) return self:combatTalentLimit(t, 50, 11, 25) end, -- Limit to < 50%
	action = function(self, t)
		self:setEffect(self.EFF_BATTLE_SHOUT, t.getdur(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Boost your life and stamina by %0.1f%% for %d turns by bellowing your battle shout.
		When the effect ends, the additional life and stamina will be lost.]]):
		format(t.getPower(self, t), t.getdur(self, t))
	end,
}

newTalent{
	name = "Battle Cry",
	type = {"technique/warcries", 4},
	require = techs_req_high4,
	points = 5,
	cooldown = 30,
	stamina = 40,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { DISABLE = 2 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_BATTLE_CRY, 7, {power=7 * self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end)
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=12, size=5, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		return ([[Your battle cry shatters the will of your foes within a radius of %d, lowering their Defense by %d for 7 turns, making them easier to hit.
		All evasion and concealment bonuses are also disabled.
		The chance to hit increases with your Physical Power.]]):
		format(self:getTalentRadius(t), 7 * self:getTalentLevel(t))
	end,
}
