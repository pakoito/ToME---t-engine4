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
	name = "Moonlight Ray",
	type = {"divine/star-fury", 1},
	require = divi_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	negative = 10,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(self:combatTalentSpellDamage(t, 14, 230)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Calls the power of the Moon into a beam of shadows doing %0.2f damage.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 14, 230)))
	end,
}

newTalent{
	name = "Shadow Blast",
	type = {"divine/star-fury", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	negative = 15,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 3
		local dam = self:combatTalentSpellDamage(t, 4, 50)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius, friendlyfire=self:spellFriendlyFire()}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local grids = self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(self:combatTalentSpellDamage(t, 5, 120)), {type="shadow"})
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.DARKNESS, dam,
			radius,
			5, nil,
			{type="shadow_zone"},
			nil, self:spellFriendlyFire()
		)

		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[Invokes a blast of shadows dealing %0.2f darkness damage and leaving a field that does %0.2f darkness damage per turn for %d turns.
		The damage will increase with the Magic stat]]):
		format(
			damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 5, 120)),
			damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 4, 50)),
			self:getTalentLevel(t) + 2
		)
	end,
}

newTalent{
	name = "Twilight Surge",
	type = {"divine/star-fury",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	negative = -20,
	positive = -10,
	tactical = {
		ATTACK = 10,
	},
	range = 2,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), talent=t, friendlyfire=false}
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t)))
		self:project(tg, self.x, self.y, DamageType.DARKNESS, self:spellCrit(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[A surge of twilight pulses from you, doing %0.2f light and %0.2f darkness damage in a radius of %d.
		It also regenerates both your negative and positive energies.
		The damage will increase with the Magic stat]]):
		format(
			damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 10, 100)),
			damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 10, 100)),
			self:getTalentRange(t)
		)
	end,
}

newTalent{
	name = "Starfall",
	type = {"divine/star-fury", 4},
	require = divi_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	negative = 20,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 10,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1 + math.floor(self:getTalentLevelRaw(t) / 3), friendlyfire=self:spellFriendlyFire(), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, DamageType.DARKSTUN, self:spellCrit(self:combatTalentSpellDamage(t, 28, 170)))

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[A star falls onto the target, stunning all and doing %0.2f darkness damage.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 28, 170)))
	end,
}
