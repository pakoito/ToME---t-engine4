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
	name = "Ice Shards",
	type = {"spell/ice",1},
	require = spells_req_high1,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = { ATTACKAREA = { COLD = 1, stun = 1 } },
	range = 10,
	radius = 1,
	proj_speed = 3,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 18, 200) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if actor and actor ~= self then
				local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="ice_shards"}}
				self:projectile(tg2, px, py, DamageType.ICE, self:spellCrit(t.getDamage(self, t)), {type="freeze"})
			end
		end)

		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Hurl ice shards at the targets in the selected area. Each shard travels slowly and does %0.2f ice damage, hitting all adjacent targets on impact.
		This spell will never hit the caster.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.COLD, damage))
	end,
}

newTalent{
	name = "Frozen Ground",
	type = {"spell/ice",2},
	require = spells_req_high2,
	points = 5,
	mana = 25,
	cooldown = 10,
	requires_target = true,
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.COLDNEVERMOVE, {dur=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_ice", {radius=tg.radius})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Blast a wave of cold all around you with radius %d, doing %0.2f cold damage and freezing creatures to the ground for 4 turns.
		Affected creatures can still act but not move.
		The damage will increase with your Spellpower.]]):format(radius, damDesc(self, DamageType.COLD, damage))
	end,
}

newTalent{
	name = "Shatter",
	type = {"spell/ice",3},
	require = spells_req_high3,
	points = 5,
	mana = 25,
	cooldown = 15,
	tactical = { ATTACKAREA = { COLD = function(self, t, target) if target:attr("frozen") then return 2 end return 0 end } },
	range = 10,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 180) end,
	getTargetCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	action = function(self, t)
		local max = t.getTargetCount(self, t)
		for i, act in ipairs(self.fov.actors_dist) do
			if self:reactionToward(act) < 0 then
				if not act:attr("frozen") then break end

				-- Instakill critters
				if act.rank <= 1 then
					if act:canBe("instakill") then
						game.logSeen(act, "%s shatters!", act.name:capitalize())
						act:takeHit(100000, self)
					end
				end

				if not act.dead then
					local add_crit = 0
					if act.rank == 2 then add_crit = 50
					elseif act.rank == 3 then add_crit = 10 end
					local tg = {type="hit", friendlyfire=false, talent=t}
					local grids = self:project(tg, act.x, act.y, DamageType.COLD, self:spellCrit(t.getDamage(self, t), add_crit))
					game.level.map:particleEmitter(act.x, act.y, tg.radius, "ball_ice", {radius=1})
				end

				max = max - 1
				if max <= 0 then break end
			end
		end
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local targetcount = t.getTargetCount(self, t)
		return ([[Shatter all frozen targets in your line of sight, doing %0.2f cold damage.
		Depending on the target's rank, there will also be an additional effect:
		* Critters will be instantly killed
		* +50%% critical chance against Normal rank
		* +10%% critical chance against Elites
		At most it will affect %d foes.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.COLD, damage), targetcount)
	end,
}

newTalent{
	name = "Uttercold",
	type = {"spell/ice",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getColdDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.2, radius=1.1}, {type="sparks", hide_center=0, time_factor=40000, color1={0, 0, 1, 1}, color2={0, 1, 1, 1}, zoom=0.5, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("uttercold", 1))
		end

		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = t.getColdDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.COLD] = t.getResistPenalty(self, t)}),
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
		local damageinc = t.getColdDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[Surround yourself with Uttercold, increasing all your cold damage by %d%% and ignoring %d%% cold resistance of your targets.]])
		:format(damageinc, ressistpen)
	end,
}
