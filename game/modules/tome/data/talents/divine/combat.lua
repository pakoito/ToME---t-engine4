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
	name = "Weapon of Light",
	type = {"divine/combat", 1},
	require = divi_req1,
	points = 5,
	cooldown = 30,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		local dam = 7 + self:getTalentLevel(t) * self:combatSpellpower(0.092)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("melee_project", {[DamageType.LIGHT]=dam}),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Infuse your weapon of the power of the Sun, doing %0.2f light damage with each hit.
		The damage will increase with the Magic stat]]):format(8 + self:combatSpellpower(0.092) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Martyrdom",
	type = {"divine/combat", 2},
	require = divi_req2,
	points = 5,
	cooldown = 22,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	reflectable = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_MARTYRDOM, 10, {power=8 * self:getTalentLevelRaw(t)})
		end
		return true
	end,
	info = function(self, t)
		return ([[
		The damage percent will increase with the Magic stat]]):
		format(
			4 + self:combatSpellpower(0.1) * self:getTalentLevel(t)
		)
	end,
}

newTalent{
	name = "Wave of Power",
	type = {"divine/combat",3},
	require = divi_req3,
	points = 5,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "light_beam", {tx=x-self.x, ty=y-self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Fire a beam of sun flames at your foes, burning all those in line for %0.2f light damage.
		The damage will increase with the Magic stat]]):
		format(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Rune of Peace",
	type = {"divine/combat", 4},
	require = divi_req4,
	points = 5,
	cooldown = 35,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 3,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=3, friendlyfire=false, talent=t}
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(10 + self:combatSpellpower(0.17) * self:getTalentLevel(t)))

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious burst of sunlight, dealing %0.2f light damage to all those around you in a radius of 3.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), 10 + self:combatSpellpower(0.17) * self:getTalentLevel(t))
	end,
}
