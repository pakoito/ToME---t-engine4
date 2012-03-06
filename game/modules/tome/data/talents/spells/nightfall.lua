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

local isFF = function(self)
	if self:getTalentLevel(self.T_INVOKE_DARKNESS) >= 5 then return false
	else return true
	end
end

newTalent{
	name = "Invoke Darkness",
	type = {"spell/nightfall",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 12,
	cooldown = 4,
	tactical = { ATTACK = { DARKNESS = 2 } },
	range = 10,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), friendlyfire=isFF(self), talent=t, display={particle="bolt_dark", trail="darktrail"}}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self:getTalentLevel(t) < 3 then
			self:projectile(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
				game.level.map:particleEmitter(x, y, 1, "dark")
			end)
		else
			self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "shadow_beam", {tx=x-self.x, ty=y-self.y})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up a bolt of darkness, doing %0.2f darkness damage.
		At level 3 it will create a beam of shadows.
		At level 5 none of your Nightfall spells will hurt your minions any more.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Circle of Death",
	type = {"spell/nightfall",2},
	require = spells_req2,
	points = 5,
	mana = 45,
	cooldown = 18,
	tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { confusion = 1.5, blind = 1.5 } },
	range = 6,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CIRCLE_DEATH, {dam=t.getDamage(self, t), dur=4 + math.floor(self:getTalentLevel(t) / 2), ff=isFF(self)},
			self:getTalentRadius(t),
			5, nil,
			{type="circle_of_death"},
			nil, false
		)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Dark fumes erupts from the ground for 5 turns. Any creature entering the circle will receive either a bane of confusion or a bane of blindness.
		Only one bane can affect a creature.
		Banes last for %d turns and also deal %0.2f darkness damage.
		The damage will increase with your Spellpower.]]):
		format(4 + math.floor(self:getTalentLevel(t) / 2), damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Fear the Night",
	type = {"spell/nightfall",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 12,
	direct_hit = true,
	tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	range = 0,
	radius = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=isFF(self), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DARKKNOCKBACK, {dist=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Invoke a cone dealing %0.2f darkness damage in a radius of %d. Any creatures caught inside must make a mental save or be knocked back 4 grids away.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Rigor Mortis",
	type = {"spell/nightfall",4},
	require = spells_req4,
	points = 5,
	mana = 60,
	cooldown = 20,
	tactical = { ATTACKAREA = 3 },
	range = 7,
	radius = 1,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=isFF(self), talent=t, display={particle="bolt_dark", trail="darktrail"}} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	getMinion = function(self, t) return 10 + self:combatTalentSpellDamage(t, 10, 30) end,
	getDur = function(self, t) return math.floor(3 + self:getTalentLevel(t) / 1.5) end,
	getSpeed = function(self, t) return math.min(self:getTalentLevel(t) * 0.065, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.RIGOR_MORTIS, {dam=t.getDamage(self, t), minion=t.getMinion(self, t), speed=t.getSpeed(self, t), dur=t.getDur(self, t)}, {type="dark"})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local speed = t.getSpeed(self, t) * 100
		local dur = t.getDur(self, t)
		local minion = t.getMinion(self, t)
		return ([[Invoke a ball of darkness that deals %0.2f darkness damage in a radius of %d. Every creature hit will start to become closer to death and thus reduce global speed by %d%%.
		Necrotic minions' damage against those creatures is increased by %d%%.
		The effects last for %d turns.
		The damage done and minions' damage increase will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), self:getTalentRadius(t), speed, minion, dur)
	end,
}
