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
	cooldown = function(self, t)
		local c = 5
		local gem_level = getGemLevel(self)
		return math.max(c - gem_level, 0)
	end,
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
			return val
		end
		return 0
	end },
	range = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = 1 + 0.01*gem_level*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 6, 170)*(1 + 0.3*gem_level)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local gem_level = getGemLevel(self)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:mindCrit(rng.avg(0.8*dam, dam)), {type="flame"})
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if gem_level > 0 and not tg.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
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
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Focus energies on a distant target to lash it with physical force, doing %d damage in addition to any Conduit damage.
		Mindslayers do not do this sort of ranged attack naturally. The use of a telekinetically-wielded gem or mindstar as a focus will improve the effects considerably.]]):
		format(damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

newTalent{
	name = "Pyrokinesis",
	type = {"psionic/focus", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 20
		local gem_level = getGemLevel(self)
		return c - gem_level
	end,
	psi = 20,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 0,
	radius = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = 1 + 0.01*gem_level*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 21, 200)*(1 + 0.3*gem_level)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=10, initial=0, dam=dam}, {type="ball_fire", args={radius=1}})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[Kinetically vibrate the essence of all foes within %d squares, setting them ablaze. Does %d damage over ten turns.
		Mindslayers do not do this sort of ranged attack naturally. The use of a telekinetically-wielded gem or mindstar as a focus will improve the effects considerably.]]):
		format(radius, damDesc(self, DamageType.FIREBURN, dam))
	end,
}

newTalent{
	name = "Reach",
	type = {"psionic/focus", 3},
	require = psi_wil_req3,
	mode = "passive",
	points = 5,
	rangebonus = function(self,t) return math.max(0, self:combatTalentScale(t, 3, 10)) end,
	info = function(self, t)
		local inc = t.rangebonus(self,t)
		local gtg = self:getTalentLevel(self.T_GREATER_TELEKINETIC_GRASP) >=5 and 1 or 0
		local add = getGemLevel(self)*t.rangebonus(self, t)
		return ([[You can extend your mental reach beyond your natural limits using a telekinetically-wielded gemstone or mindstar as a focus. Increases the range of various abilities by %0.1f%% to %0.1f%%, depending on the quality of the gem used as a focus (currently %0.1f%%).]]):
		format(inc*(1+gtg), inc*(5+gtg), add)
	end,
}

newTalent{
	name = "Focused Channeling",
	type = {"psionic/focus", 4},
	require = psi_wil_req4,
	mode = "passive",
	points = 5,
	impfocus = function(self,t) return math.max(1, self:combatTalentScale(t, 1.2, 1.75)) end,
	info = function(self, t)
		local inc = t.impfocus(self,t)
		local gtg = self:getTalentLevel(self.T_GREATER_TELEKINETIC_GRASP) >=5 and 1 or 0
		local add = getGemLevel(self)*t.impfocus(self, t)
		return ([[You can channel more energy with your auras and shields, using a telekinetically-wielded gemstone or mindstar as a focus. Increases the base strength of all auras and shields by %0.2f to %0.2f, depending on the quality of the gem or mindstar used as a focus (currently %0.2f).]]):
		format(inc*(1+gtg), inc*(5+gtg), add)
	end,
}
