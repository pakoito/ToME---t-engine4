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
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatTalentScale(t, 10, 27)
	end,
	getDam = function(self, t)
		return self:combatTalentMindDamage(t, 20, 200)
	end,
	getSlow = function(self, t)
		return math.min(5 * self:getTalentLevel(t) + 15, 50)
	end,
	action = function(self, t)
		local en = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local dam = t.getDam(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local slow = t.getSlow(self, t)/100 * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local psi = en
		local tg = self:getTalentTarget(t)
		local trans = self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(psi)
				psi = psi * .8
				act:incStamina(-dam)
				if trans then
					if act:canBe("sleep") then
						act:setEffect(act.EFF_SLEEP, 4, {src=self, power=en, insomnia=en, no_ct_effect=true, apply_power=self:combatMindpower()})
						game.level.map:particleEmitter(act.x, act.y, 1, "generic_charge", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
					else
						game.logSeen(self, "%s resists the sleep!", act.name:capitalize())
					end
				end
			end
			DamageType:get(DamageType.MINDSLOW).projector(self, tx, ty, DamageType.MINDSLOW, slow)
			
		end)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local dam = t.getDam(self, t)
		local en = t.getLeech(self, t)
		local cen = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local cdam = t.getDam(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local cslow = t.getSlow(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		return ([[You suck the kinetic energy out of your surroundings, slowing all targets in a radius of %d by %d%% (now %d%%) for four turns and draining %0.2f (now %0.2f) stamina from them.
		For each target drained, you gain psi. The first target gives %d (now %d) psi and each additional one reduces the gain by 20%%.
		The slow effect will improve with your Mindpower.
		The strength of these effects also scales with your current psi. Ranging from -50%% at full psi to +50%% at 0 psi.]])
		:format(range, slow, cslow, dam, cdam, en, cen)
	end,
}


newTalent{
	name = "Thermal Leech",
	type = {"psionic/voracity", 1},
	require = psi_wil_req2,
	points = 5,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	psi = 0,
	tactical = { DEFEND = 2, DISABLE = { stun = 2 } },
	range = 0,
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatTalentScale(t, 10, 27)
	end,
	getDam = function(self, t)
		return self:combatTalentMindDamage(t, 20, 200)
	end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 1.3, 3.2)) end, -- Duration
	action = function(self, t)
		local en = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local dam = self:mindCrit(t.getDam(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()))
		local dur = t.getDur(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local psi = en
		local tg = self:getTalentTarget(t)
		local trans = self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(psi)
				psi = psi * 0.8
				if trans then
					act:setEffect(act.EFF_WEAKENED, 4, {power=en, apply_power=self:combatMindpower()})
				end
			end
			DamageType:get(DamageType.COLD).projector(self, tx, ty, DamageType.COLD, dam)
			DamageType:get(DamageType.MINDFREEZE).projector(self, tx, ty, DamageType.MINDFREEZE, dur)
			
		end)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local dam = damDesc(self, DamageType.COLD, t.getDam(self, t))
		local dur = t.getDur(self, t)
		local en = t.getLeech(self, t)
		local cen = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local cdam = damDesc(self, DamageType.COLD, t.getDam(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()))
		local cdur = t.getDur(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		return ([[You leech the heat out of all targets in a radius of %d, freezing them for up to %d (now %d) turns and doing %0.2f (now %0.2f) cold damage. 
		For each target drained, you gain psi. The first target gives %d (now %d) psi and each additional one reduces the gain by 20%%.
		The damage will improve with your Mindpower.
		The strength of these effects also scales with your current psi. Ranging from -50%% at full psi to +50%% at 0 psi.]]):
		format(range, dur, cdur, dam, cdam, en, cen)
	end,
}

newTalent{
	name = "Charge Leech",
	type = {"psionic/voracity", 1},
	require = psi_wil_req3,
	points = 5,
	psi = 0,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	tactical = { DEFEND = 2, ATTACKAREA = { LIGHTNING = 2 }, DISABLE = { stun = 1 } },
	direct_hit = true,
	range = 0,
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		return self:combatTalentScale(t, 10, 27)
	end,
	getDam = function(self, t)
		return self:combatTalentMindDamage(t, 20, 200)
	end,
	action = function(self, t)
		local en = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local dam = self:mindCrit(t.getDam(self, t)) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local tg = self:getTalentTarget(t)
		local psi = en
		local trans = self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(psi)
				psi = psi * 0.8
				if trans then
					DamageType:get(DamageType.CONFUSION).projector(self, tx, ty, DamageType.CONFUSION, {power_check=self.combatMindpower, dam=en, dur=4})
				end
			end
			DamageType:get(DamageType.LIGHTNING_DAZE).projector(self, tx, ty, DamageType.LIGHTNING_DAZE, {power_check=self:combatMindpower(), dam=dam})
			
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
		local cen = t.getLeech(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi())
		local cdam = damDesc(self, DamageType.LIGHTNING, t.getDam(self, t) * (0.5 + (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()))
		return ([[You pull electric potential from all targets around you in a radius of %d, giving them a nasty shock in the process. Deals %0.2f (now %0.2f) damage lightning, and has a 25%% chance to daze. 
		For each target drained, you gain psi. The first target gives %d (now %d) psi and each additional one reduces the gain by 20%%.
		The damage will improve with your Mindpower.
		The strength of these effects also scales with your current psi. Ranging from -50%% at full psi to +50%% at 0 psi.]]):
		format(range, dam, cdam, en, cen)
	end,
}

newTalent{
	name = "Insatiable",
	type = {"psionic/voracity", 4},
	mode = "passive",
	points = 5,
	require = psi_wil_req4,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "max_psi", self:getTalentLevel(t)*10)
		self:talentTemporaryValue(p, "psi_per_kill", self:getTalentLevel(t))
		self:talentTemporaryValue(p, "psi_on_crit", self:getTalentLevel(t) * 0.5)
	end,
	info = function(self, t)
		return ([[Increases your maximum energy by %d. You also gain %d psi on kill and %0.1f psi per mind critical.]]):format(10 * self:getTalentLevel(t), self:getTalentLevel(t), self:getTalentLevel(t)/2)
	end,
}

