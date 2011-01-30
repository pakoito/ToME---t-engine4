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
	name = "Kinetic Folding",
	type = {"chronomancy/spacetime-folding", 1},
	require = temporal_req1,
	points = 5,
	stamina = 8,
	paradox = 4,
	cooldown = 6,
	tactical = { ATTACK = 2 },
	range = 6,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You momentarily fold the space between yourself and your target, attacking it at range for %d%% weapon damage.
		]]):
		format (damage*100)
	end,
}

newTalent{
	name = "Swap",
	type = {"chronomancy/spacetime-folding", 2},
	require = chrono_req2,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = { ESCAPE = 2, CLOSEIN = 2 },
	requires_target = true,
	direct_hit = true,
	getRange = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="hit", range=t.getRange(self, t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if math.floor(core.fov.distance(self.x, self.y, tx, ty)) > t.getRange(self, t) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(tx, ty, "no_teleport") or game.level.map.attrs(self.x, self.y, "no_teleport") then
			game.logSeen(self, "The spell fizzles!")
			return true
		end
		if tx then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
			end
		end
		if target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "The spell fizzles!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")


		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[You manipulate the spacetime continuum in such a way that you switch places with another creature with in a range of %d.
		]]):format (range)
	end,
}



newTalent{
	name = "Temporal Wake",
	type = {"chronomancy/spacetime-folding", 4},
	require = chrono_req4,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 10,
	tactical = { ATTACK = 1, CLOSEIN = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 6, dam / 2, 3))
			self:project(tg, x, y, DamageType.TEMPORAL, dam/2)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				self:move(tx, ty, true)
			end
		else
			game.logSeen(self, "You can't move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You transform yourself into a powerful bolt of temporal lightning and move between two points dealing %0.2f to %0.2f lightning damage and %0.2f temporal damage to everything in your path.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 6),
		damDesc(self, DamageType.LIGHTNING, damage / 2),
		damDesc(self, DamageType.TEMPORAL, damage / 2))
	end,
}