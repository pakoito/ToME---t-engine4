-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Spacetime Tuning",
	type = {"chronomancy/other", 1},
	hide = true,
	points = 1,
	message = "@Source@ retunes the fabric of spacetime.",
	cooldown = 50,
	tactical = { PARADOX = 2 },
	no_npc_use = true,
	no_energy = true,
	getAnomaly = function(self, t) return 6 - (self:getTalentLevelRaw(self.T_STATIC_HISTORY) or 0) end,
	getPower = function(self, t) return math.floor(self:getWil()/2) end,
	action = function(self, t)
		-- open dialog to get desired paradox
		local q = engine.dialogs.GetQuantity.new("Retuning the fabric of spacetime...",
		"What's your desired paradox level?", math.floor(self.paradox), nil, function(qty)

			-- get reduction amount and find duration
			local amount = qty - self.paradox
			local dur = math.floor(math.abs(qty-self.paradox)/t.getPower(self, t))

			-- set tuning effect
			if amount >= 0 then
				self:setEffect(self.EFF_SPACETIME_TUNING, dur, {power = t.getPower(self, t)})
			elseif amount < 0 then
				self:setEffect(self.EFF_SPACETIME_TUNING, dur, {power = - t.getPower(self, t)})
			end

		end)
		game:registerDialog(q)
		return true
	end,
	info = function(self, t)
		local chance = t.getAnomaly(self, t)
		return ([[Retunes your Paradox towards the desired level and informs you of failure, anomaly, and backfire chances when you finish tuning.  You will be dazed while tuning and each turn your Paradox will increase or decrease by an amount equal to one half of your Willpower stat.
		Each turn you spend increasing Paradox will have a %d%% chance of triggering a temporal anomaly which will end the tuning process.  Decreasing Paradox has no chance of triggering an anomaly.]]):
		format(chance)
	end,
}

newTalent{
	name = "Static History",
	type = {"chronomancy/chronomancy", 1},
	require = temporal_req1,
	points = 5,
	message = "@Source@ stabilizes the timeline.",
	cooldown = 24,
	tactical = { PARADOX = 2 },
	getDuration = function(self, t) 
		local duration = 1 + math.floor(self:getTalentLevel(t)/2)
		if self:knowTalent(self.T_PARADOX_MASTERY) then
			duration = 1 + math.floor((self:getTalentLevel(t)/2) + (self:getTalentLevel(self.T_PARADOX_MASTERY)/2))
		end
		
		return duration
	end,
	getReduction = function(self, t)
		local reduction = self:combatTalentStatDamage(t, "wil", 20, 400)
		--check for Paradox Mastery
		if self:knowTalent(self.T_PARADOX_MASTERY) then
			reduction = reduction * (1 + (self:getTalentLevel(self.T_PARADOX_MASTERY)/10 or 0))
		end
		
		return reduction
	end,
	action = function(self, t)
		self:incParadox (- t.getReduction(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_SPACETIME_STABILITY, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		local duration = t.getDuration(self, t)
		return ([[Reduces Paradox by %d by stabilizing the spacetime continuum and allows chronomancy to be used without failure checks for %d turns (backfires and anomalies may still occur).
		Talent points invested in Static History will also reduce your chances of triggering an anomaly while using Spacetime Tuning.
		The effect will increase with the Willpower stat.]]):
		format(reduction, duration)
	end,
}

newTalent{
	name = "Precognition",
	type = {"chronomancy/chronomancy",2},
	require = temporal_req2,
	points = 5,
	paradox = 25,
	cooldown = 50,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.ceil((self:getTalentLevel(t) * 2) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		if checkTimeline(self) == true then
			return
		end
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_PRECOGNITION, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You peer into the future, allowing you to explore your surroundings for %d turns.  When precognition expires you'll return to the point in time you first cast the spell.  Note that visions of your own death can still be fatal.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		The duration will scale with your Paradox.]]):format(duration)
	end,
}

newTalent{
	name = "Probability Weaving",
	type = {"chronomancy/chronomancy",3},
	mode = "passive",
	require = temporal_req3,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_LCK] = self.inc_stats[self.STAT_LCK] + 2
		self:onStatChange(self.STAT_LCK, 2)
		self.combat_spellpower = self.combat_spellpower + 2
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_LCK] = self.inc_stats[self.STAT_LCK] - 2
		self:onStatChange(self.STAT_LCK, - 2)
		self.combat_spellpower = self.combat_spellpower - 2
	end,
	info = function(self, t)
		return ([[You've learned to bend the laws of probability, increasing your luck and spellpower by %d.]]):format(2 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Foresight",
	type = {"chronomancy/chronomancy", 4},
	require = temporal_req4,
	points = 5,
	paradox = 20,
	cooldown = function(self, t) return 27 - (self:getTalentLevelRaw(t) * 3) end,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	tactical = { DEFEND = 4 },
	no_energy = true,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_FORESIGHT, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You avoid all damage from a single damage source as long as it occurs within the next %d turns and deals at least 10%% of your maximum life in a single hit.  Once an attack is avoided the spell will end.
		Additional talent points will lower the cooldown and the duration will scale with your Paradox.
		This spell takes no time to cast.]]):
		format(duration)
	end,
}