
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
	name = "Regeneration",
	type = {"spell/nature", 1},
	require = spells_req1,
	points = 5,
	random_ego = "defensive",
	mana = 30,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=self:combatTalentSpellDamage(t, 5, 25)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 5, 25))
	end,
}

newTalent{
	name = "Heal",
	type = {"spell/nature", 2},
	require = spells_req2,
	points = 5,
	random_ego = "defensive",
	mana = 60,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:heal(self:spellCrit(self:combatTalentSpellDamage(t, 40, 220)), self)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to heal your body for %d life.
		The life healed will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 40, 220))
	end,
}

newTalent{
	name = "Restoration",
	type = {"spell/nature", 3},
	require = spells_req3,
	points = 5,
	random_ego = "defensive",
	mana = 30,
	cooldown = 15,
	action = function(self, t)
		local target = self
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "poison" or e.type == "disease" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to cure your body of %d poisons and diseases (at level 3).]]):format(math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Nature's Call",
	type = {"spell/nature", 4},
	require = spells_req4,
	points = 5,
	random_ego = "attack",
	mana = 60,
	cooldown = 100,
	tactical = {
		ATTACK = 10,
	},
	requires_target = true,
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
			infravision = 20,

			inc_damage = table.clone(self.inc_damage, true),

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
