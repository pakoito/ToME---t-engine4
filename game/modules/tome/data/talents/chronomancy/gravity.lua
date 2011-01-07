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
	name = "Crushing Weight",
	type = {"chronomancy/gravity", 1},
	require = chrono_req1,
	points = 5,
	random_ego = "attack",
	paradox = 3,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
			self:project(tg, x, y, DamageType.CRUSHING, self:spellCrit(self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm)), {type="manathrust"})
			game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Amplifies the target's mass, pinning it and inflicting %0.2f physical damage over 3 turns.
		The damage will increase with the Magic stat]]):format (damDesc(self, DamageType.PHYSICAL, (self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm))))
	end,
}

newTalent{
	name = "Gravity Spike",
	type = {"chronomancy/gravity", 2},
	require = chrono_req2,
	points = 5,
	random_ego = "attack",
	paradox = 5,
	cooldown = 10,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentLevel(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("knockback") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is sucked in by the gravity spike!", target.name:capitalize())
			end
		end)
		self:project (tg, x, y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 8, 170)*getParadoxModifier(self, pm)))
		game.level.map:particleEmitter(x, y, tg.radius, "gravityspike", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Creates a gravity spike in a %d radius, moving all targets towards the spells center and inflicting %0.2f physical damage.
		The damage will increase with the Magic Stat.]]):format(self:getTalentLevel (t), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 8, 170)*getParadoxModifier(self, pm)))
	end,
}

newTalent{
	name = "Gravity Pulse",
	type = {"chronomancy/gravity",3},
	require = chrono_req3,
	points = 5,
	random_ego = "attack",
	paradox = 6,
	cooldown = 12,
	tactical = {
		ATTACKAREA = 10,
	},
	range = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="ball", radius=self:getTalentRange(t), friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.PULSE, self:spellCrit(self:combatTalentSpellDamage(t, 8, 170)*getParadoxModifier(self, pm)))
		game:playSoundNear(self, "talents/earth")
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_earth", {radius=tg.radius, grids=grids})
		return true
	end,
	info = function(self, t)
		return ([[Creates an outward pulse of gravity where you stand; inflicting %0.2f physical damage and knocking your enemies back.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 8, 170)*getParadoxModifier(self, pm)))
	end,
}

newTalent{
	name = "Gravity Well",
	type = {"chronomancy/gravity", 4},
	require = chrono_req4,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 6,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 2
		local dam = (self:combatTalentSpellDamage(t, 4, 50)*getParadoxModifier(self, pm))
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.GRAVITY, dam,
			radius,
			5, nil,
			{type="quake"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[Increases local gravity, slowing and doing %0.2f physical damage in a radius of 3 each turn for %d turns.
		The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, (self:combatTalentSpellDamage(t, 4, 50)*getParadoxModifier(self, pm))), self:getTalentLevel(t) + 2)
	end,
}
