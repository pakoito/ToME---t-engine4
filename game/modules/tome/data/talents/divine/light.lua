-- ToME - Tales of Middle-Earth
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
	name = "Healing Light",
	type = {"divine/light", 1},
	require = spells_req1,
	points = 5,
	random_ego = "defensive",
	cooldown = 40,
	positive = -10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:heal(self:spellCrit(self:combatTalentSpellDamage(t, 20, 240)), self)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[An invigorating ray of Sunlight shines on you, healing your body for %d life.
		The life healed will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 20, 240))
	end,
}

newTalent{
	name = "Bathe in Light",
	type = {"divine/light", 2},
	require = spells_req2,
	random_ego = "defensive",
	points = 5,
	cooldown = 10,
	positive = -20,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 3
		local dam = self:combatTalentSpellDamage(t, 4, 30)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.HEAL, dam,
			radius,
			5, nil,
			{type="healing_vapour"},
			nil, true
		)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[A magical zone of Sunlight appears around you, healing all that stand within.
		The life healed will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 4, 30))
	end,
}

newTalent{
	name = "Barrier",
	type = {"divine/light", 3},
	require = spells_req3,
	points = 5,
	random_ego = "defensive",
	positive = -20,
	cooldown = 60,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {power=self:combatTalentSpellDamage(t, 30, 170)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[A protective shield forms around you, negating %d damage.]]):format(self:combatTalentSpellDamage(t, 30, 170))
	end,
}

newTalent{
	name = "Second Life",
	type = {"divine/light", 4},
	require = spells_req4,
	points = 5,
	cooldown = 100,
	positive = -30,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[NOT FINISHED]])
	end,
}
