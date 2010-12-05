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
	name = "Arcane Power",
	type = {"spell/arcane", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 50,
	points = 5,
	cooldown = 30,
	spellpower_increase = { 5, 9, 13, 16, 18 },
	getSpellpowerIncrease = function(self, t) return t.spellpower_increase[self:getTalentLevelRaw(t)] end,
	activate = function(self, t)
		local power = t.getSpellpowerIncrease(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			power = self:addTemporaryValue("combat_spellpower", power),
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
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
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
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Manaflow",
	type = {"spell/arcane", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 0,
	cooldown = 40,
	tactical = {
		MANA = 20,
	},
	getManaRestoration = function(self, t) return self:combatTalentSpellDamage(t, 10, 20) end,
	action = function(self, t)
		if not self:hasEffect(self.EFF_MANAFLOW) then
			self:setEffect(self.EFF_MANAFLOW, 10, {power=t.getManaRestoration(self, t)})
			game:playSoundNear(self, "talents/arcane")
		end
		return true
	end,
	info = function(self, t)
		local restoration = t.getManaRestoration(self, t)
		return ([[Engulf yourself in a surge of mana, quickly restoring %d mana every turn for 10 turns.
		The mana restored will increase with the Magic stat]]):
		format(restoration)
	end,
}

newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",4},
	require = spells_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_mana = 150,
	tactical = {
		DEFEND = 10,
	},
	getManaRatio = function(self, t) return math.max(0.8, 3 - (self:combatSpellpower(1) * self:getTalentLevel(t)) / 280) end,
	activate = function(self, t)
		local power = t.getManaRatio(self, t)
		self.disruption_shield_absorb = 0
		game:playSoundNear(self, "talents/arcane")
		return {
			shield = self:addTemporaryValue("disruption_shield", power),
			particle = self:addParticles(Particles.new("disruption_shield", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		local power = t.getManaRatio(self, t)
		return ([[Uses mana instead of life to take damage. Uses %0.2f mana per damage point taken.
		If your mana is brought too low by the shield, it will de-activate and the chain reaction will release a deadly arcane explosion of the amount of damage absorbed.
		The damage to mana ratio increases with the Magic stat]]):
		format(power)
	end,
}
