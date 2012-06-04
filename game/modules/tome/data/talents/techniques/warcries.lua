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


newTalent{
	name = "Shattering Shout",
	type = {"technique/warcries", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	stamina = 20,
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, (50 + self:getTalentLevel(t) * self:getStr()) / 2.3, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[A powerful shout, doing %0.2f physical damage in a radius %d cone in front of you.
		The damage increases with Strength.]]):format(damDesc(self, DamageType.PHYSICAL, (50 + self:getTalentLevel(t) * self:getStr()) / 2.3), 3 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Second Wind",
	type = {"technique/warcries", 2},
	require = techs_req_high2,
	points = 5,
	random_ego = "utility",
	cooldown = 50,
	tactical = { STAMINA = 2 },
	action = function(self, t)
		self:incStamina((20 + self:getTalentLevel(t) * 7) * self.max_stamina / 100)
		return true
	end,
	info = function(self, t)
		return ([[Take a deep breath to recover %d%% stamina.]]):
		format(20 + self:getTalentLevel(t) * 7)
	end,
}

newTalent{
	name = "Battle Shout",
	type = {"technique/warcries", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "defensive",
	cooldown = 30,
	stamina = 40,
	tactical = { DEFEND = 2, BUFF = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_BATTLE_SHOUT, 5 + self:getTalentLevelRaw(t) * 2, {power=10+self:getTalentLevelRaw(t)})
		return true
	end,
	info = function(self, t)
		return ([[Boost your life and stamina by %d%% for %d turns by uttering your battle shout.]]):format( 10 + self:getTalentLevelRaw(t), 5 + self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Battle Cry",
	type = {"technique/warcries", 4},
	require = techs_req_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	stamina = 40,
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
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
		end, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Your battle cry shatters the will of your foes within a radius of %d, lowering their defense by %d for 7 turns, making them easier to hit.
		Lowering defense chance increase with your Strength stat.]]):
		format(self:getTalentRadius(t), 7 * self:getTalentLevel(t))
	end,
}
