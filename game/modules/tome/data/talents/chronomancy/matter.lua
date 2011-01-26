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
	name = "Dust to Dust",
	type = {"chronomancy/matter",1},
	require = chrono_req1,
	points = 5,
	paradox = 6,
	cooldown = 4,
	tactical = { ATTACKAREA = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 250)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.WASTING, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fires a beam that attempts to turn everything in it's path to dust, inflicting %0.2f temporal damage over three turns.
		The damage will scale with your Paradox and Magic stat.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}
newTalent{
	name = "Terraforming",
	type = {"chronomancy/matter",2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	range = 6,
	no_npc_use = true,
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
	paradox = 20,
	cooldown = 6,
	tactical = { CLOSEIN = 2 },
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
	name = "Quantum Spike",
	type = {"chronomancy/matter", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 12,
	tactical = { ATTACK = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self,t)))
		game:playSoundNear(self, "talents/arcane")
		-- Try to insta-kill
		if target then
			if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s has been pulled apart at a molecular level!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the quantum spike!", target.name:capitalize())
			end
		end
		if target.dead then
			game.level.map:particleEmitter(x, y, 1, "teleport")
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attempts to pull the target apart at a molecular level, inflicing %0.2f temporal damage.  If the target ends up with low enough life(<20%%) it might be instantly killed.
		The damage will scale with your Paradox and the Magic stat.]]):format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

