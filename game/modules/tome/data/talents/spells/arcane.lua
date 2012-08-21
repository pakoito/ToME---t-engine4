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
	name = "Arcane Power",
	type = {"spell/arcane", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 50,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	spellpower_increase = { 5, 9, 14, 17, 20 },
	getSpellpowerIncrease = function(self, t)
		local v = t.spellpower_increase[self:getTalentLevelRaw(t)]
		if v then return v else return 20 + (self:getTalentLevelRaw(t) - 5) * 2 end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			power = self:addTemporaryValue("combat_spellpower", t.getSpellpowerIncrease(self, t)),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_spellpower", p.power)
		return true
	end,
	info = function(self, t)
		local spellpowerinc = t.getSpellpowerIncrease(self, t)
		return ([[Your mastery of magic allows you to enter a deep concentration state, increasing your spellpower by %d.]]):
		format(spellpowerinc)
	end,
}

newTalent{
	name = "Manathrust",
	type = {"spell/arcane", 2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 10,
	cooldown = 3,
	tactical = { ATTACK = { ARCANE = 2 } },
	range = 10,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ARCANE, self:spellCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		if tg.type == "beam" then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		else
			game.level.map:particleEmitter(x, y, 1, "manathrust")
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage.
		At level 3 it becomes a beam.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Arcane Vortex",
	type = {"spell/arcane", 3},
	require = spells_req3,
	points = 5,
	mana = 35,
	cooldown = 12,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = { ARCANE = 2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 340) / 6 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return nil end

		target:setEffect(target.EFF_ARCANE_VORTEX, 6, {src=self, dam=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Creates a vortex of arcane energies on the target for 6 turns. Each turn the vortex will look for an other foe in sight and fire a manathrust doing %0.2f arcane damage to all foes in line.
		If no foes are found the target will take 150%% more arcane damage.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.ARCANE, dam))
	end,
}

newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",4},
	require = spells_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_mana = 10,
	no_energy = true,
	tactical = { MANA = 3, DEFEND = 2, },
	getManaRatio = function(self, t) return math.max(3 - self:combatTalentSpellDamage(t, 10, 200) / 100, 0.5) * (100 - util.bound(self:attr("shield_factor") or 0, 0, 70)) / 100 end,
	getArcaneResist = function(self, t) return 50 + self:combatTalentSpellDamage(t, 10, 500) / 10 end,
	on_pre_use = function(self, t) return (self:getMana() / self:getMaxMana() <= 0.25) or self:hasEffect(self.EFF_AETHER_AVATAR) or self:attr("disruption_shield") end,
	explode = function(self, t, dam)
		game.logSeen(self, "#VIOLET#%s's disruption shield collapses and then explodes in a powerful manastorm!", self.name:capitalize())

		-- Add a lasting map effect
		self:setEffect(self.EFF_ARCANE_STORM, 10, {power=t.getArcaneResist(self, t)})
		game.level.map:addEffect(self,
			self.x, self.y, 10,
			DamageType.ARCANE, dam / 10,
			3,
			5, nil,
			{type="arcanestorm", only_one=true},
			function(e) e.x = e.src.x e.y = e.src.y return true end,
			true
		)
	end,
	damage_feedback = function(self, t, p, src)
		if p.particle and p.particle._shader and p.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			p.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			p.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, t)
		local power = t.getManaRatio(self, t)
		self.disruption_shield_absorb = 0
		game:playSoundNear(self, "talents/arcane")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3}, {type="shield", time_factor=-2500, color={0.8, 0.1, 1.0}, impact_color = {0, 1, 0}, impact_time=800}))
		else
			particle = self:addParticles(Particles.new("disruption_shield", 1))
		end

		return {
			shield = self:addTemporaryValue("disruption_shield", power),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with arcane forces, disrupting any attemps to harm you and instead generating mana.
		Generates %0.2f mana per damage point taken (Aegis Shielding talent affects the ratio).
		If your mana is brought too high by the shield, it will de-activate and the chain reaction will release a deadly arcane storm with radius 3 for 10 turns, dealing 10%% of the damage absorbed each turn.
		While the arcane storm rages you also get a %d%% arcane resistance.
		Only usable when below 25%% mana.
		The damage to mana ratio increases with your Spellpower.]]):
		format(t.getManaRatio(self, t), t.getArcaneResist(self, t))
	end,
}
