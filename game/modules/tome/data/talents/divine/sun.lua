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

newTalent{
	name = "Searing Light",
	type = {"divine/sun", 1},
	require = divi_req1,
	points = 5,
	cooldown = 6,
	positive = -16,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(self:combatTalentSpellDamage(t, 6, 160)), {type="light"})

		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, 4,
			DamageType.LIGHT, self:combatTalentSpellDamage(t, 6, 80),
			0,
			5, nil,
			{type="light_zone"},
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Calls the power of the Sun into a searing light doing %0.2f damage and leaving a spot on the ground for 4 turns doing %0.2f damage.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 6, 160), self:combatTalentSpellDamage(t, 6, 80))
	end,
}

newTalent{
	name = "Sun Flare",
	type = {"divine/sun", 2},
	require = divi_req2,
	points = 5,
	cooldown = 22,
	positive = -15,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=true, radius=2 + self:getTalentLevel(t) / 2, talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		tg.friendlyfire = false
		local grids = self:project(tg, self.x, self.y, DamageType.BLIND, 3 + self:getTalentLevel(t))
		if self:getTalentLevel(t) then
			self:project(tg, self.x, self.y, DamageType.LIGHT, self:combatTalentSpellDamage(t, 4, 80))
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Invokes a sun flare, blinding your foes and lighting up your immediate area.
		At level 3 it will start dealing %0.2f light damage.
		The damage will increase with the Magic stat]]):
		format(
			self:combatTalentSpellDamage(t, 4, 80)
		)
	end,
}

newTalent{
	name = "Firebeam",
	type = {"divine/sun",3},
	require = divi_req3,
	points = 5,
	cooldown = 7,
	positive = -20,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(self:combatTalentSpellDamage(t, 10, 200)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "light_beam", {tx=x-self.x, ty=y-self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Fire a beam of sun flames at your foes, burning all those in line for %0.2f fire damage.
		The damage will increase with the Magic stat]]):
		format(self:combatTalentSpellDamage(t, 10, 200))
	end,
}

newTalent{
	name = "Sunburst",
	type = {"divine/sun", 4},
	require = divi_req4,
	points = 5,
	cooldown = 15,
	positive = -20,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 3,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=3, friendlyfire=false, talent=t}
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(self:combatTalentSpellDamage(t, 10, 160)))

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious burst of sunlight, dealing %0.2f light damage to all those around you in a radius of 4.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), self:combatTalentSpellDamage(t, 10, 160))
	end,
}
