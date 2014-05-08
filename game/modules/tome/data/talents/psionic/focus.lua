-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

--Mindlash: ranged physical rad-0 ball
--Pyrokinesis: LOS burn attack
--Reach: gem-based range improvements
--Channeling: gem-based shield and improvement

newTalent{
	name = "Mindlash",
	type = {"psionic/focus", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	psi = 10,
	tactical = { ATTACK = function(self, t, target)
		local val = { PHYSICAL = 2}
		local gem_level = getGemLevel(self)
		if gem_level > 0 and not target.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
			local c =  self:getTalentFromId(self.T_CONDUIT)
			local auras = self:isTalentActive(c.id)
			if auras.k_aura_on then
				val.PHYSICAL = val.PHYSICAL + 1
			end
			if auras.t_aura_on then
				val.FIRE = 1
			end
			if auras.c_aura_on then
				val.LIGHTNING = 1
			end
		end
		return val
	end },
	range = function(self, t)
		local r = 5
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDamage = function (self, t)
		return self:combatTalentMindDamage(t, 12, 340)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:mindCrit(rng.avg(0.8*dam, dam)), {type="mindsear"})
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if not tg.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
			local c =  self:getTalentFromId(self.T_CONDUIT)
			--c.do_combat(self, c, tg)
			local mult = 1 + 0.2*(self:getTalentLevel(c))
			local auras = self:isTalentActive(c.id)
			if auras.k_aura_on then
				local k_aura = self:getTalentFromId(self.T_KINETIC_AURA)
				local k_dam = mult * k_aura.getAuraStrength(self, k_aura)
				DamageType:get(DamageType.PHYSICAL).projector(self, x, y, DamageType.PHYSICAL, k_dam)
			end
			if auras.t_aura_on then
				local t_aura = self:getTalentFromId(self.T_THERMAL_AURA)
				local t_dam = mult * t_aura.getAuraStrength(self, t_aura)
				DamageType:get(DamageType.FIRE).projector(self, x, y, DamageType.FIRE, t_dam)
			end
			if auras.c_aura_on then
				local c_aura = self:getTalentFromId(self.T_CHARGED_AURA)
				local c_dam = mult * c_aura.getAuraStrength(self, c_aura)
				DamageType:get(DamageType.LIGHTNING).projector(self, x, y, DamageType.LIGHTNING, c_dam)
			end

		end
		--game:onTickEnd(function() self:setEffect(self.EFF_MINDLASH, 2, {}) end)
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Focus energies on a distant target to lash it with physical force, doing %d damage in addition to any Conduit damage.
		The damage will scale with your Mindpower.]]):
		format(damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

newTalent{
	name = "Pyrokinesis",
	type = {"psionic/focus", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 20,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 0,
	radius = function(self, t)
		local r = 5
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDamage = function (self, t)
		return self:combatTalentMindDamage(t, 50, 480)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	action = function(self, t)
		local dam = self:mindCrit(t.getDamage(self, t))
		local tg = self:getTalentTarget(t)
--		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=10, initial=0, dam=dam}, {type="ball_fire", args={radius=1}})
		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=10, initial=0, dam=dam})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[Kinetically vibrate the essence of all foes within %d squares, setting them ablaze. Does %d damage over ten turns.]]):
		format(radius, damDesc(self, DamageType.FIREBURN, dam))
	end,
}

newTalent{
	name = "Brain Storm",
	type = {"psionic/focus", 3},
	points = 5, 
	require = psi_wil_req3,
	psi = 15,
	cooldown = 10,
	range = function(self, t)
		local r = 2
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	radius = 2,
	tactical = { DISABLE = 2, ATTACKAREA = { LIGHTNING = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 300) end,
	action = function(self, t)		
		local tg = {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam=t.getDamage(self, t)
		
		self:project(tg, x, y, DamageType.BRAINSTORM, self:mindCrit(dam))
		
		-- Lightning ball gets a special treatment to make it look neat
		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 16
		local angle_diff = 360 / nb_forks
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
			local tx = x + math.floor(math.cos(a) * tg.radius)
			local ty = y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(x, y, tg.radius, "temporal_lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Focus mental electricity into a ball of plasma and hurl it (mentally) at the target.
		It will explode on impact doing %0.2f lightning damage in a radius of 2.
		This talent will apply cross tier Brainlock.
		The damage will increase with your Mindpower.]]):
		format(damDesc(self, DamageType.LIGHTNING, dam))
	end,
}

newTalent{
	name = "Reach",
	type = {"psionic/focus", 4},
	require = psi_wil_req4,
	mode = "passive",
	points = 5,
	rangebonus = function(self,t) return math.max(0, self:combatTalentScale(t, 20, 80)) end,
	info = function(self, t)
		local inc = t.rangebonus(self,t)
		return ([[You can extend your mental reach beyond your natural limits. Increases the range of various abilities by %0.1f%%.]]):
		format(inc)
	end,
}

