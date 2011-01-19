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

newTalent{
	name = "Bellowing Roar",
	type = {"wild-gift/fire-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ roars!",
	equilibrium = 3,
	cooldown = 20,
	range = 5,
	tactical = { DEFEND = 1, DISABLE = 3 },
	action = function(self, t)
		local tg = {type="ball", range=0, radius=2 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {dur=3, dam=40 + 6 * self:getTalentLevel(t)}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[You let out a powerful roar that sends your foes into utter confusion for 3 turns in a radius of %d.]]):format(2 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Wing Buffet",
	type = {"wild-gift/fire-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	equilibrium = 7,
	cooldown = 10,
	range = 5,
	direct_hit = true,
	tactical = { DEFEND = 1, DISABLE = 2, ESCAPE = 1 },
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=4 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=self:combatTalentStatDamage(t, "str", 15, 90), dist=4})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You summon a powerful gust of wind, knocking back your foes up to 4 titles away and damaging them for %d.
		The damage will increase with the Strength stat]]):format(self:combatTalentStatDamage(t, "str", 15, 90))
	end,
}

newTalent{
	name = "Devouring Flame",
	type = {"wild-gift/fire-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 35,
	tactical = { ATTACKAREA = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = 2 + self:getTalentLevelRaw(t)
		local radius = 2
		local dam = self:combatTalentStatDamage(t, "wil", 15, 120)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.FIRE, dam,
			radius,
			5, nil,
			{type="inferno"},
			nil, true
		)
		game:playSoundNear(self, "talents/devouringflame")
		return true
	end,
	info = function(self, t)
		return ([[Spit a cloud of flames doing %0.2f fire damage in a radius of 2 each turn for %d turns.
		The damage will increase with the Willpower stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "wil", 15, 120)), 2 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Fire Breath",
	type = {"wild-gift/fire-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes fire!",
	tactical = { ATTACKAREA = 2 },
	range = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, self:combatTalentStatDamage(t, "str", 30, 450))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe fire in a frontal cone. Any target caught in the area will take %0.2f fire damage over 3 turns.
		The damage will increase with the Strength stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 450)))
	end,
}
