-- ToME -  Tales of Maj'Eyal
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
	name = "Quantum Spike",
	type = {"chronomancy/matter", 1},
	require = chrono_req1,
	points = 5,
	random_ego = "attack",
	paradox = 3,
	cooldown = 3,
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
			self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(self:combatTalentSpellDamage(t, 10, 115)*getParadoxModifier(self, pm)), {type="teleport"})
			self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 10, 115)*getParadoxModifier(self, pm)))
			game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Attempts to pull the target apart at a molecular level, inflicing %d temporal damage and %d physical damage.
		The damage will increase with the Magic stat]]):format (damDesc(self, DamageType.TEMPORAL, (self:combatTalentSpellDamage(t, 10, 115)*getParadoxModifier(self, pm))), damDesc(self, DamageType.PHYSICAL, (self:combatTalentSpellDamage(t, 10, 115)*getParadoxModifier(self, pm))))
	end,
}

newTalent{
	name = "Terraforming",
	type = {"chronomancy/matter",2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	tactical = {
		UTILITY = 10,
	},
	range = 6,
	cooldown = function(self, t) return math.ceil(20 - (self:getTalentLevel(t) *2)) end,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			self:project(tg, x, y, DamageType.DIG, nil)
		else
			self:project(tg, x, y, DamageType.GROW, nil)
		end
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Makes impassable terrain passable and turns passable terrain into walls, trees, etc.
		Additional talent points will lower the cooldown]]):format()
	end,
}

newTalent{
	name = "Calcify",
	type = {"chronomancy/matter",3},
	require = chrono_req3,
	points = 5,
	random_ego = "attack",
	paradox = 5,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, Map.ACTOR, "block_move") then
			local dam = self:spellCrit(self:combatTalentSpellDamage(t, 20, 290))
			self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 6, dam / 2, 3))
			self:project(tg, x, y, DamageType.TEMPORAL, dam/2)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			self:move(x, y, true)
		else
			game.logSeen(self, "You can't move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		return ([[You transform yourself into a powerful bolt of temporal lightning and move between two points dealing %0.2f to %0.2f lightning damage and %0.2f temporal damage to everything in your path.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.LIGHTNING, self:combatTalentSpellDamage(t, 20, 290) / 6), damDesc(self, DamageType.LIGHTNING, self:combatTalentSpellDamage(t, 20, 290)/2), damDesc(self, DamageType.TEMPORAL, self:combatTalentSpellDamage(t, 20, 290)/2))
	end,
}

newTalent{
	name = "Dust to Dust",
	type = {"chronomancy/matter",4},
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
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 240)*getParadoxModifier(self, pm) end,
	getRadius = function (self, t) return 1 + math.floor(self:getTalentLevel(t)/5) end, 
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.DIG, nil)
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[Destroys trees, walls, etc. and inflicts %d temporal damage on everything with in a radius of %d.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.TEMPORAL, damage), radius)
	end,
}

