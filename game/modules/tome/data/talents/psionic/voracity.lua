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
	radius = function(self,t) return self:combatTalentScale(t, 1, 4) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentScale(t, 10, 27)*math.max(0.5, (1.5-psi/self:getMaxPsi()))
	end,
	getDam = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentMindDamage(t, 20, 200)*math.max(0.5, (1.5-psi/self:getMaxPsi())) --this looks high
	end,
	getSlow = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentLimit(self:getTalentLevel(t)*math.max(0.5, (1.5-psi/self:getMaxPsi())), 0.50, 0.16, 0.20) -- Limit < 50%
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = t.getDam(self, t)
		local slow = t.getSlow(self, t)
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
		return ([[You draw kinetic energy from your surroundings to replenish your Psi.
		This will slow all targets within radius %d by %d%% (max %d%%) for four turns, draining %0.1f (max %0.1f) stamina from each.
		You replenish %d (max %d) Psi from the first target, with each additional target restoring 20%% less than the one before it.
		The strength of these effects increases as your Psi depletes.]])
		:format(range, t.getSlow(self, t)*100, t.getSlow(self, t, 0)*100, t.getDam(self, t), t.getDam(self, t, 0), t.getLeech(self, t), t.getLeech(self, t, 0))
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
	radius = function(self,t) return self:combatTalentScale(t, 1, 4) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentScale(t, 10, 27)*math.max(0.5, (1.5-psi/self:getMaxPsi()))
	end,
	getDam = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentMindDamage(t, 20, 200)*math.max(0.5, (1.5-psi/self:getMaxPsi()))
	end,
	getDur = function(self, t, psi)
		local psi = psi or self:getPsi()
		return math.ceil(self:combatTalentScale(self:getTalentLevel(t)*math.max(0.5, (1.5-psi/self:getMaxPsi())), 1.3, 3.2))
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = self:mindCrit(t.getDam(self, t))
		local dur = t.getDur(self, t)
		local psi = en
		local tg = self:getTalentTarget(t)
		local trans = self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(psi)
				psi = psi * 0.8
				if trans then
					act:setEffect(act.EFF_WEAKENED, 4, {power=trans.weaken, apply_power=self:combatMindpower()})
				end
			end
			DamageType:get(DamageType.COLD).projector(self, tx, ty, DamageType.COLD, dam)
			DamageType:get(DamageType.MINDFREEZE).projector(self, tx, ty, DamageType.MINDFREEZE, dur)
		end)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		return ([[You draw thermal energy from your surroundings to replenish your Psi.
		This will freeze all targets within radius %d for %d (max %d) turns, and deal %0.1f (max %0.1f) Cold damage.
		You replenish %d (max %d) Psi from the first target, with each additional target restoring 20%% less than the one before it.
		The damage and the strength of these effects increases as your Psi depletes.]])
		:format(range, t.getDur(self, t), t.getDur(self, t, 0), damDesc(self, DamageType.COLD, t.getDam(self, t)), damDesc(self, DamageType.COLD, t.getDam(self, t, 0)), t.getLeech(self, t), t.getLeech(self, t, 0))
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
	radius = function(self,t) return self:combatTalentScale(t, 1, 4) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentScale(t, 10, 27)*math.max(0.5, (1.5-psi/self:getMaxPsi()))
	end,
	getDam = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentMindDamage(t, 20, 200)*math.max(0.5, (1.5-psi/self:getMaxPsi()))
	end,
	getDaze = function(self, t, psi)
		local psi = psi or self:getPsi()
		return self:combatTalentLimit(self:getTalentLevel(t)*math.max(0.5, (1.5-psi/self:getMaxPsi())), 100, 25, 50) -- Limit < 100%
	end,
	action = function(self, t)
		local en = t.getLeech(self, t)
		local dam = self:mindCrit(t.getDam(self, t))
		local tg = self:getTalentTarget(t)
		local psi = en
		local trans = self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(psi)
				psi = psi * 0.8
				if trans then
					DamageType:get(DamageType.CONFUSION).projector(self, tx, ty, DamageType.CONFUSION, {power_check=self.combatMindpower, dam=trans.confuse, dur=4})
				end
			end
			DamageType:get(DamageType.LIGHTNING_DAZE).projector(self, tx, ty, DamageType.LIGHTNING_DAZE, {power_check=self:combatMindpower(), dam=dam, daze = t.getDaze(self, t)})
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
	info = function(self, t) -- could this use another effect?
		local range = self:getTalentRadius(t)
		return ([[You draw electical potential energy from your surroundings to replenish your Psi.
		This deals %0.1f (max %0.1f) Lightning damage to all targets around you within radius %d, and has a %d%% (max %d%%) chance to daze them for 3 turns.
		You replenish %d (max %d) Psi from the first target, with each additional target restoring 20%% less than the one before it.
		The strength of these effects increases as your Psi depletes.]])
		:format(t.getDam(self, t), t.getDam(self, t, 0), range, t.getDaze(self, t), t.getDaze(self, t, 0), t.getLeech(self, t), t.getLeech(self, t, 0))
	end,
}

newTalent{
	name = "Insatiable",
	type = {"psionic/voracity", 4},
	mode = "passive",
	points = 5,
	require = psi_wil_req4,
	getPsiRecover = function(self, t) return self:combatTalentScale(t, 1.5, 5, 0.75) end,
	passives = function(self, t, p)
		local recover = t.getPsiRecover(self, t)
		self:talentTemporaryValue(p, "max_psi", self:getTalentLevel(t)*10)
		self:talentTemporaryValue(p, "psi_per_kill", recover)
		self:talentTemporaryValue(p, "psi_on_crit", recover*0.5)
	end,
	info = function(self, t)
		local recover = t.getPsiRecover(self, t)
		return ([[Increases your maximum energy by %d. You also gain %0.1f Psi for each kill and %0.1f Psi for each mind critical.]]):format(10 * self:getTalentLevel(t), recover, 0.5*recover)
	end,
}

