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
	cooldown = 40,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:heal(self:spellCrit(20 + self:combatSpellpower(0.5) * self:getTalentLevel(t)), self)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[An invigorating ray of sun shines on you, healing your body for %d life.
		The life healed will increase with the Magic stat]]):format(20 + self:combatSpellpower(0.5) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Bathe in Light",
	type = {"divine/light", 2},
	require = spells_req2,
	points = 5,
--	mana = 60,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 3
		local dam = 5 + self:combatSpellpower(0.20) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.HEAL, dam,
			radius,
			5, nil,
			{type="healing_vapour"},
			nil, false
		)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[A magical zone of sunlight appears around you, healing all that stand within.
		The life healed will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.20) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Barrier",
	type = {"divine/light", 3},
	require = spells_req3,
	points = 5,
--	mana = 30,
	cooldown = 60,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {power=(10 + self:getMag(30)) * self:getTalentLevel(t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[A protective shield forms around you, negating %d damage.]]):format((10 + self:getMag(30)) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Second Life",
	type = {"divine/light", 4},
	require = spells_req4,
	points = 5,
--	mana = 60,
	cooldown = 100,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke the guardian!")
			return
		end
		print("Invoking guardian on", x, y)

		local NPC = require "mod.class.NPC"
		local bear = NPC.new{
			type = "animal", subtype = "bear",
			display = "q", color=colors.LIGHT_GREEN,
			name = "guardian bear", faction = self.faction,
			desc = [[A bear summoned by the powers of nature to help you.]],
			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=3, },
			energy = { mod=1 },
			stats = { str=18, dex=13, mag=5, con=15 },
			resolvers.tmasteries{ ["technique/other"]=0.25 },

			resolvers.talents{ [Talents.T_STUN]=2 },
			max_stamina = 100,

			resists = { [DamageType.COLD] = 20, [DamageType.NATURE] = 20 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100,150),
			life_rating = 10,

			combat_armor = 7, combat_def = 3,
			combat = { dam=resolvers.rngavg(12,25), atk=10, apr=10, physspeed=2 },

			summoner = self,
			summon_time = util.bound(self:getTalentLevel(t) * self:combatSpellpower(0.10), 5, 90),
		}

		bear:resolve()
		game.zone:addEntity(game.level, bear, "actor", x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to summon a bear ally for %d turns.
		The power of the ally will increase with the Magic stat]]):format(util.bound(self:getTalentLevel(t) * self:combatSpellpower(0.10), 5, 90))
	end,
}
