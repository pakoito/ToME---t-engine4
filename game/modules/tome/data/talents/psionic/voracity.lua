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
	name = "Kinetic Leech",
	type = {"psionic/voracity", 1},
	require = psi_wil_req1,
	points = 5,
	psi = 0,
	cooldown = function(self, t)
		return math.ceil(40 - self:getTalentLevel(t)*4)
	end,
	tactical = { DEFEND = 1, DISABLE = 2 },
	direct_hit = true,
	range = function(self, t)
		local r = 2
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end
		local en = ( 3 + self:getTalentLevel(t)) * (100 + self:getWil())/100
		self:incPsi(en*#tgts)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local dam = .1 + 0.03*self:getTalentLevel(t)
		self:project(tg, self.x, self.y, DamageType.MINDSLOW, dam)
		local x, y = self.x, self.y
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local slow = 3 * self:getTalentLevel(t) + 10
		local en = ( 3 + self:getTalentLevel(t)) * (100 + self:getWil())/100
		return ([[You suck the kinetic energy out of your surroundings, slowing all enemies in a radius of %d by %d%% for four turns.
		For each enemy drained, you gain %d energy.
		The energy gained scales with Willpower.]]):format(range, slow, en)
	end,
}

newTalent{
	name = "Thermal Leech",
	type = {"psionic/voracity", 2},
	require = psi_wil_req2,
	points = 5,
	cooldown = function(self, t)
		return math.ceil(50 - self:getTalentLevel(t)*4)
	end,
	psi = 0,
	tactical = { DEFEND = 2, DISABLE = 2 },
	range = function(self, t)
		local r = 1
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end
		local en = ( 4 + self:getTalentLevel(t)) * (100 + self:getWil())/85
		self:incPsi(en*#tgts)
		local duration = self:getTalentLevel(t) + 2
		local radius = self:getTalentRange(t)
		local dam = math.ceil(1 + 0.5*self:getTalentLevel(t))
		local tg = {type="ball", range=0, radius=radius, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.MINDFREEZE, dam)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = math.ceil(1 + 0.5*self:getTalentLevel(t))
		local en = ( 4 + self:getTalentLevel(t)) * (100 + self:getWil())/85
		--local duration = self:getTalentLevel(t) + 2
		return ([[You leech the heat out of all foes in a radius of %d, freezing them for up to %d turns and gaining %d energy for each enemy frozen.
		The energy gained scales with Willpower.]]):
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
		return math.ceil(50 - self:getTalentLevel(t)*5)
	end,
	tactical = { DEFEND = 2, DAMAGE = 2, DISABLE = 1 },
	direct_hit = true,
	range = function(self, t)
		local r = 2
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.ceil(r*mult)
	end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end
		local en = ( 5 + self:getTalentLevel(t)) * (100 + self:getWil())/75
		self:incPsi(en*#tgts)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local dam = self:spellCrit(self:combatTalentMindDamage(t, 28, 270))
		self:project(tg, self.x, self.y, DamageType.LIGHTNING_DAZE, rng.avg(dam / 3, dam, 3))
		local x, y = self.x, self.y
		-- Lightning ball gets a special treatment to make it look neat
		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 16
		local angle_diff = 360 / nb_forks
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
			local tx = x + math.floor(math.cos(a) * tg.radius)
			local ty = y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local en = ( 5 + self:getTalentLevel(t)) * (100 + self:getWil())/75
		local dam = damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 28, 270))
		return ([[You pull electric potential from the foes around you in a radius of %d, gaining %d energy for each one affected and giving them a nasty shock in the process. Deals between %d and %d damage.
		The energy gained scales with Willpower.]]):format(range, en, dam / 3, dam)
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

