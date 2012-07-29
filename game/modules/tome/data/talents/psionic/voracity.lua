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
	name = "Kinetic Leech",
	type = {"psionic/voracity", 1},
	require = psi_wil_req1,
	points = 5,
	psi = 0,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	tactical = { DEFEND = 1, DISABLE = 2 },
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local r = 2
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 4, 20)
	end,
	getSlow = function(self, t)
		return math.min(5 * self:getTalentLevel(t) + 15, 50)
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = t.getSlow(self, t)/100
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(en)
			end
			DamageType:get(DamageType.MINDSLOW).projector(self, tx, ty, DamageType.MINDSLOW, dam)
		end)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local en = t.getLeech(self, t)
		return ([[You suck the kinetic energy out of your surroundings, slowing all targets in a radius of %d by %d%% for four turns.
		For each target drained, you gain %d energy.]]):format(range, slow, en)
	end,
}

newTalent{
	name = "Thermal Leech",
	type = {"psionic/voracity", 2},
	require = psi_wil_req2,
	points = 5,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	psi = 0,
	tactical = { DEFEND = 2, DISABLE = { stun = 2 } },
	range = 0,
	radius = function(self, t)
		local r = 1
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 5, 25)
	end,
	getDam = function(self, t)
		return math.ceil(1 + 0.5*self:getTalentLevel(t))
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = t.getDam(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(en)
			end
			DamageType:get(DamageType.MINDFREEZE).projector(self, tx, ty, DamageType.MINDFREEZE, dam)
		end)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local dam = t.getDam(self, t)
		local en = t.getLeech(self, t)
		--local duration = self:getTalentLevel(t) + 2
		return ([[You leech the heat out of all targets in a radius of %d, freezing them for up to %d turns and gaining %d energy for each target frozen.]]):
		format(range, dam, en)
	end,
}

newTalent{
	name = "Charge Leech",
	type = {"psionic/voracity", 3},
	require = psi_wil_req3,
	points = 5,
	psi = 0,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	tactical = { DEFEND = 2, ATTACKAREA = { LIGHTNING = 2 }, DISABLE = { stun = 1 } },
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local r = 2
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 6, 30)
	end,
	getDam = function(self, t)
		return self:combatTalentMindDamage(t, 28, 270)
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = self:mindCrit(t.getDam(self, t))
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(en)
			end
			DamageType:get(DamageType.LIGHTNING_DAZE).projector(self, tx, ty, DamageType.LIGHTNING_DAZE, rng.avg(dam/3, dam, 3))
		end)
		-- Lightning ball gets a special treatment to make it look neat
		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 16
		local angle_diff = 360 / nb_forks
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
			local tx = self.x + math.floor(math.cos(a) * tg.radius)
			local ty = self.y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local en = t.getLeech(self, t)
		local dam = damDesc(self, DamageType.LIGHTNING, t.getDam(self, t))
		return ([[You pull electric potential from all targets around you in a radius of %d, gaining %d energy for each one affected and giving them a nasty shock in the process. Deals between %d and %d damage nad has a chance to daze.]]):format(range, en, dam / 3, dam)
	end,
}
newTalent{
	name = "Insatiable",
	type = {"psionic/voracity", 4},
	mode = "passive",
	points = 5,
	require = psi_wil_req4,
	on_learn = function(self, t)
		self.max_psi = self.max_psi + 10
	end,
	on_unlearn = function(self, t)
		self.max_psi = self.max_psi - 10
	end,
	info = function(self, t)
		return ([[Increases your maximum energy by %d]]):format(10 * self:getTalentLevelRaw(t))
	end,
}

