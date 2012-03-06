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
	name = "Moonlight Ray",
	type = {"celestial/star-fury", 1},
	require = divi_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	negative = 10,
	tactical = { ATTACK = {DARKNESS = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 14, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Calls the power of the Moon into a beam of shadows doing %0.2f damage.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Shadow Blast",
	type = {"celestial/star-fury", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	negative = 15,
	tactical = { ATTACKAREA = {DARKNESS = 2} },
	range = 5,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire()}
	end,
	getDamageOnSpot = function(self, t) return self:combatTalentSpellDamage(t, 4, 40) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 110) end,
	getDuration = function(self, t) return math.floor(self:getTalentLevel(t) * 0.8) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local grids = self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), {type="shadow"})
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.DARKNESS, t.getDamageOnSpot(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="shadow_zone"},
			nil, self:spellFriendlyFire()
		)

		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damageonspot = t.getDamageOnSpot(self, t)
		local duration = t.getDuration(self, t)
		return ([[Invokes a blast of shadows dealing %0.2f darkness damage and leaving a field of radius 3 that does %0.2f darkness damage per turn for %d turns.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.DARKNESS, damage),damDesc(self, DamageType.DARKNESS, damageonspot),duration)
	end,
}

newTalent{
	name = "Twilight Surge",
	type = {"celestial/star-fury",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	negative = -20,
	positive = -10,
	tactical = { ATTACKAREA = {LIGHT = 1, DARKNESS = 1} },
	range = 0,
	radius = 2,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=false}
	end,
	getLightDamage = function(self, t) return 10 + self:combatSpellpower(0.2) * self:getTalentLevel(t) end,
	getDarknessDamage = function(self, t) return 10 + self:combatSpellpower(0.2) * self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getLightDamage(self, t)))
		self:project(tg, self.x, self.y, DamageType.DARKNESS, self:spellCrit(t.getDarknessDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local lightdam = t.getLightDamage(self, t)
		local darknessdam = t.getDarknessDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[A surge of twilight pulses from you, doing %0.2f light and %0.2f darkness damage within radius %d.
		It also regenerates both your negative and positive energies.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.LIGHT, lightdam),damDesc(self, DamageType.DARKNESS, darknessdam), radius)
	end,
}

newTalent{
	name = "Starfall",
	type = {"celestial/star-fury", 4},
	require = divi_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	negative = 20,
	tactical = { ATTACKAREA = {DARKNESS = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevelRaw(t) / 3)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 170) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, DamageType.DARKSTUN, self:spellCrit(t.getDamage(self, t)))

		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[A star falls into area of radius %d, stunning all for 4 turns and doing %0.2f darkness damage.
		The damage will increase with the Magic stat.]]):
		format(radius, damDesc(self, DamageType.DARKNESS, damage))
	end,
}
