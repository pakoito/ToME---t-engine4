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

newTalent{
	name = "Telekinetic Shove",
	type = {"psionic/force", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	psi = 10,
	cooldown = 12,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { pin = 1 }, ESCAPE = 1 },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	pushRange = function(self, t) return math.floor(self:combatTalentScale(t, 4, 10)) end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		self:project(tg, x, y, DamageType.TK_PUSHPIN, {dam=self:mindCrit(self:combatTalentMindDamage(t, 6, 120)), push=t.pushRange(self,t), dur=t.duration(self,t)})
		
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_cold", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		return ([[Shove all targets within a radius %d cone, knocking them back %d tiles. 
		Targets pushed into a wall take %0.2f physical damage and are pinned for %d turns.]]):format(self:getTalentRadius(t), t.pushRange(self,t), damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 6, 120)), t.duration(self,t))
	end,
}

newTalent{
	name = "Iron Will", short_name = "FORCE_IRON_WILL", image = "talents/iron_will.png",
	type = {"psionic/force", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "passive",
	stunImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.50) end,
	cureChance = function(self, t) return self:combatTalentLimit(t, 1, 0.10, 0.35) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "stun_immune", t.stunImmune(self, t))
	end,
	callbackOnActBase = function(self, t)
		if not rng.chance(t.stunImmune(self, t)*100) then return end
	
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "mental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			self:removeEffect(eff[2])
			game.logSeen(self, "%s has recovered!", self.name:capitalize())
		end
	end,
	info = function(self, t)
		return ([[Your Iron Will improves stun immunity by %d%% and gives you a %d%% chance of recovering from a random mental effect each turn.]]):
		format(t.stunImmune(self, t)*100, t.cureChance(self, t)*100)
	end,
}

newTalent{
	name = "Deflect Projectiles",
	type = {"psionic/force", 3},
	require = psi_wil_req3, 
	points = 5,
	mode = "sustained",
	sustain_psi = 25,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 100, 17, 45), self:getTalentLevel(t) >= 4 and 2 or 1 end, -- Limit chance <100%
	activate = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return {
			chance = self:addTemporaryValue("projectile_evasion", chance),
			spread = self:addTemporaryValue("projectile_evasion_spread", spread),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("projectile_evasion", p.chance)
		self:removeTemporaryValue("projectile_evasion_spread", p.spread)
		return true
	end,
	info = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return ([[You learn to devote a portion of your attention to mentally swatting, grabbing, or otherwise deflecting incoming projectiles.
		All projectiles targeting you have a %d%% chance to instead target a spot up to %d grids nearby.]]):
		format(chance, spread)
	end,
}

newTalent{
	name = "Forcefield",
	type = {"psionic/force", 4},
	require = psi_wil_high4,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	cooldown = 40,
	no_energy = true,
	tactical = { BUFF = 2, HEAL = 4 },
	range = 0,
	radius = 1,
	getResist = function(self, t) return self:combatTalentLimit(t, 80, 30, 65) end,
	getCost = function(self, t) return 1.0 - self:combatTalentLimit(t, 1, 0.5, 0.85) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	activate = function(self, t)
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, blend=true, img="forcefield"}, {type="shield", shieldIntensity=0.15, color={1,1,1}}))
		else
			ret.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, damtype, dam, tmp, no_martyr)
		local ff = self:isTalentActive(t.id)
		if not ff then return dam end
		local total_dam = dam
		local absorbable_dam = t.getResist(self,t) / 100 * total_dam
		local guaranteed_dam = total_dam - absorbable_dam

		local psicost = t.getCost(self,t) * absorbable_dam
		self:incPsi(-psicost)
		return {dam=guaranteed_dam}
	end,
	callbackOnActBase = function(self, t)
		if self.psi < self.max_psi / 10 then self:forceUseTalent(self.T_FORCEFIELD, {ignore_energy=true}) return end
		self:incPsi(self.max_psi / -10)
		
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.MINDKNOCKBACK, 0)
	end,
	info = function(self, t)
		return ([[Surround yourself with a forcefield, reducing all incoming damage by %d%% and knocking back adjacent enemies each turn. 
		This talent drains 10%% of your maximum psi each turn, plus an additional %0.2f psi for every point of damage reduced.]]):
		format(t.getResist(self,t), t.getCost(self,t))
	end,
}

