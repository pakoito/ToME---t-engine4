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
	name = "Mindlash",
	type = {"psionic/focus", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	psi = 10,
	tactical = { ATTACK = { PHYSICAL = 2} },
	range = 4,
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
		if self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS) then
			local act = game.level.map(x, y, engine.Map.ACTOR)
			if act:canBe("stun") then
				act:setEffect(act.EFF_STUNNED, 4, {apply_power=self:combatMindpower()})
			end
		end
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Focus energies on a distant target to lash it with physical force, doing %d physical damage.
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
	radius = 5,
	getDamage = function (self, t)
		return self:combatTalentMindDamage(t, 50, 480)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	action = function(self, t)
		local dam = self:mindCrit(t.getDamage(self, t))
		local tg = self:getTalentTarget(t)
		if self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS) then
			self:project(tg, self.x, self.y, DamageType.FLAMESHOCK, {dur=6, dam=dam})
		else
			self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=6, initial=0, dam=dam})
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "fireflash", {radius=tg.radius})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[Kinetically vibrate the essence of all foes within %d squares, setting them ablaze. Does %d fire damage over six turns.]]):
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
	range = 3,
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
	name = "Iron Will", image = "talents/iron_will.png",
	type = {"psionic/focus", 4},
	require = psi_wil_req4,
	points = 5,
	mode = "passive",
	stunImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.10, 0.50) end,
	cureChance = function(self, t) return self:combatTalentLimit(t, 1, 0.10, 0.35) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "stun_immune", t.stunImmune(self, t))
	end,
	callbackOnActBase = function(self, t)
		if not rng.chance(t.cureChance(self, t)*100) then return end
	
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