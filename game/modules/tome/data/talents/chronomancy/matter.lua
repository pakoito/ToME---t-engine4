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
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fires a beam that attempts to turn matter into dust, inflicting %0.2f temporal damage.
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
	cooldown = function(self, t) return 20 - math.ceil(self:getTalentLevel(t) *2) or 0 end,
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
	paradox = 20,
	cooldown = 20,
	tactical = { ATTACKAREA = 2, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	requires_target = true,
	getRadius = function (self, t) return 1 + math.floor(self:getTalentLevel(t) / 4) end,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 10) and target:canBe("stone") and target:canBe("instakill") then
				target:setEffect(target.EFF_STONED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s resists the calcification.", target.name:capitalize())
			end
		end)
		game.level.map:particleEmitter(x, y, tg.radius, "temporal_ball", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		return ([[Attempts to turn all targets in a radius of %d to stone for %d turns.  Stoned creatures are unable to act or regen life and are very brittle.
		If a stoned creature is hit by an attack that deals more than 30%% of its life it will shattered and be destroyed.
		Stoned creatures are highly resistant to fire and lightning and somewhat resistant to physical attacks.
		The duration will scale with your Paradox.]]):format(radius, duration)
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

