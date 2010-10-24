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
	name = "Flame", image = true,
	type = {"spell/fire",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.FIREBURN, self:spellCrit(self:combatTalentSpellDamage(t, 25, 290)), {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire, setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 25, 290)))
	end,
}

newTalent{
	name = "Flameshock",
	type = {"spell/fire",2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 30,
--	cooldown = 18,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 1,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=3 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FLAMESHOCK, {dur=self:getTalentLevelRaw(t) + 2, dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 120))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a cone of flame. Any target caught in the area will take %0.2f fire damage and be stunned for %d turns.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 10, 120)), self:getTalentLevelRaw(t) + 2)
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), friendlyfire=self:spellFriendlyFire(), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.FIREBURN, self:spellCrit(self:combatTalentSpellDamage(t, 28, 280)), function(self, tg, x, y, grids)
		game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire moving toward the target that explodes into a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 28, 280)), 1 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Inferno",
	type = {"spell/fire",4},
	require = spells_req4,
	points = 5,
	random_ego = "attack",
	mana = 100,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 40,
	},
	range = 20,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local radius = 5
		local dam = self:combatTalentSpellDamage(t, 15, 80)
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
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Raging flames burn foes and allies alike doing %0.2f fire damage in a radius of 5 each turn for %d turns.
		The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 15, 80)), 5 + self:getTalentLevel(t))
	end,
}
