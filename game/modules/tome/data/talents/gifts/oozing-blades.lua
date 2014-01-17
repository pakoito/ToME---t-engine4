-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Oozebeam",
	type = {"wild-gift/oozing-blades", 1},
	require = gifts_req_high1,
	points = 5,
	equilibrium = 4,
	cooldown = 3,
	tactical = { ATTACKAREA = {NATURE=2} },
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 290) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.SLIME, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Channel slime through your psiblades, extending their reach to create a beam doing %0.2f slime damage.
		Damage increase with Mindpower.]]):
		format(damDesc(self, DamageType.NATURE, dam))
	end,
}

newTalent{
	name = "Natural Acid",
	type = {"wild-gift/oozing-blades", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 14)) end,
	getResist = function(self, t) return 10 + self:combatTalentMindDamage(t, 10, 70) end,
	info = function(self, t)
		local res = t.getResist(self, t)
		return ([[Each time you deal acid damage to a creature its nature resistance is decreased by %d%% for 2 turns.
		Resistance will decrease with Mindpower.
		This effect can only happen at most once every %d turns.]]):
		format(res, self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Mind Parasite",
	type = {"wild-gift/oozing-blades", 3},
	require = gifts_req_high3,
	points = 5,
	equilibrium = 12,
	cooldown = 15,
	range = 6,
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}} end,
	tactical = { DISABLE = 2 },
	requires_target = true,
	getChance = function(self, t) return math.min(100, 30 + self:combatTalentMindDamage(t, 10, 70)) end,
	getNb = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 1, 2)) end,
	getTurns = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 2, 12)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				target:setEffect(target.EFF_MIND_PARASITE, 6, {chance=t.getChance(self, t), nb=t.getNb(self, t), turns=t.getTurns(self, t)})
			end
		end, {type="slime"})

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[You use your psiblades to fire a small worm at a foe.
		When it hits, it will burrow into the target's brain and stay there for 6 turns, interfering with its ability to use talents.
		Each time a talent is used there is %d%% chance that %d talent(s) are placed on a %d turn(s) cooldown.
		The chance will increase with your Mindpower.]]):
		format(t.getChance(self, t), t.getNb(self, t), t.getTurns(self, t))
	end,
}

newTalent{
	name = "Unstoppable Nature",
	type = {"wild-gift/oozing-blades", 4},
	require = gifts_req_high4,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 20,
	cooldown = 30,
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	tactical = { BUFF = 2 },
	getNatureDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 100, 10, 50, true) end, -- Limit < 100%
	getChance = function(self, t) return math.max(0,self:combatTalentLimit(t, 100, 14, 70)) end, -- Limit < 100%
	freespit = function(self, t, target)
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
					break
				end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
					break
				end
			end
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=0.5, npow=4, time_factor=2000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("master_summoner", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.NATURE] = t.getNatureDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.NATURE] = t.getResistPenalty(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getNatureDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		local chance = t.getChance(self, t)
		return ([[Surround yourself with nature forces, increasing all your nature damage by %d%% and ignoring %d%% nature resistance of your targets.
		In addition any time you deal damage with a wild gift there is a %d%% chance that one of you mucus ooze will spit at the target as a free action.]])
		:format(damageinc, ressistpen, chance)
	end,
}
