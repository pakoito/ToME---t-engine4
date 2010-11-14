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
	name = "Quantum Feed",
	type = {"chronomancy/temporal-combat", 1},
	mode = "sustained",
	points = 5,
	require = temporal_req1,
	sustain_stamina = 20,
	cooldown = 10,
	activate = function(self, t)
		local percentage =  (15 + (self:getTalentLevel(t) * 5))/100
		local power = self:getWil()*percentage
		game:playSoundNear(self, "talents/arcane")
		return {
			power = self:addTemporaryValue("combat_spellpower", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_spellpower", p.power)
		return true
	end,
	info = function(self, t)
		return ([[You've learned to use some of your physical reserves to improve your control over the spacetime continuum.  You gain a bonus to spellpower equal to %d%% of your willpower.]]):
		format(15 + self:getTalentLevel(t) * 5)
	end
	}


   newTalent{
	name = "Kinetic Folding",
	type = {"chronomancy/temporal-combat", 2},
	require = temporal_req2,
	points = 5,
	random_ego = "attack",
	stamina = 8,
	paradox = 4,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.1, 1.9)*getParadoxModifier(self, pm), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		return ([[You momentarily fold the space between yourself and your target, attacking it at range for %d%% weapon damage.
		]]):
		format (100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9)*getParadoxModifier(self, pm)))
	end,
}

newTalent{
	name = "Prescient Strike",
	type = {"chronomancy/temporal-combat", 3},
	require = temporal_req3,
	points = 5,
	random_ego = "attack",
	stamina = 16,
	paradox = 6,
	cooldown = 6,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		if target then
			self.combat_physcrit = self.combat_physcrit + 1000
			self.combat_atk = self.combat_atk + 1000
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.1, 1.9)*getParadoxModifier(self, pm), true)
			self.combat_physcrit = self.combat_physcrit - 1000
			self.combat_atk = self.combat_atk - 1000
		else
			return
		end
		return true
	end,
	info = function(self, t)
		return ([[You gain a moment of clarity, perfoming a near perfect strike for %d%% weapon damage that rarely misses and is an automcatic critical hit if it lands.
		]]):format(100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9)*getParadoxModifier(self, pm)))
	end,
}

newTalent{
	name = "Metabolic Control",
	type = {"chronomancy/temporal-combat", 4},
	require = temporal_req4,
	points = 5,
	mode = "activated",
	stamina = 25,
	paradox = 10,
	cooldown = 30,
	tactical = {
		Buff= 10,
		Heal = 10,
	},
	action = function(self, t)
			self:setEffect(self.EFF_SPEED, 10, {power=1 - ((1 / (1 + self:getTalentLevel(t) * 0.03))*getParadoxModifier(self, pm))})
			self:setEffect(self.EFF_REGENERATION, 10, {power=self:combatTalentSpellDamage(t, 5, 25)*getParadoxModifier(self, pm)})
		return true
	end,
	info = function(self, t)
		return ([[Increases your speed by %d%% and regenerates your body for %d life every turn for 10 turns.
		The life healed will increase with your Magic Stat.]]):format((self:getTalentLevel(t) * 3) *getParadoxModifier(self, pm), (self:combatTalentSpellDamage(t, 5, 25)*getParadoxModifier(self, pm)))
	end,
}

