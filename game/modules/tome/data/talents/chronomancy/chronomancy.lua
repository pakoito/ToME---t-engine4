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
	name = "Spacetime Tuning",
	type = {"chronomancy/other", 1},
	mode = "sustained",
	sustain_paradox = 0,
	--hide = true,
	points = 1,
	--message = "@Source@ retunes the fabric of spacetime.",
	cooldown = 5,
	tactical = { PARADOX = 2 },
	no_npc_use = true,
	no_energy = true,
	no_unlearn_last = true,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		local _, failure = self:paradoxFailChance()
		local _, backfire = self:paradoxBackfireChance()
		local _, anomaly = self:paradoxAnomalyChance()
		game.logPlayer(self, "Your current failure chance is %d%%, your current anomaly chance is %d%%, and your current backfire chance is %d%%.", failure, anomaly, backfire)
		return true
	end,
	info = function(self, t)
		local _, failure = self:paradoxFailChance()
		local _, anomaly = self:paradoxAnomalyChance()
		local _, backfire = self:paradoxBackfireChance()
		return ([[Reduces your paradox by one each turn while sustained.  Casting a spell will cancel this effect.
		
		Current failure chance  : %d%%
		Current anomaly chance  : %d%%
		Current backfire chance : %d%%]]):format(failure, anomaly, backfire)
	end,
}

newTalent{
	name = "Precognition",
	type = {"chronomancy/chronomancy",1},
	require = temporal_req1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.ceil((self:getTalentLevel(t) * 2)) end,
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
		return ([[You peer into the future, allowing you to explore your surroundings for %d turns.  When precognition expires you'll return to the point in time you first cast the spell.  Dying with precognition active will end the spell prematurely.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.]]):format(duration)
	end,
}

newTalent{
	name = "Foresight",
	type = {"chronomancy/chronomancy",2},
	mode = "passive",
	require = temporal_req2,
	points = 5,
	getRadius = function(self, t) return 3 + math.floor(self:getTalentLevel(t) * 2) end,
	do_precog_foresight = function(self, t)
		self:magicMap(t.getRadius(self, t))
		self:setEffect(self.EFF_SENSE, 1, {
			range = t.getRadius(self, t),
			actor = 1,
			object = 1,
			trap = 1,
		})
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		return ([[When the duration of your Precognition expires you'll be given a vision of your surroundings, sensing terrain, enemies, objects, and traps in a %d radius.]]):
		format(radius)
	end,
}

newTalent{
	name = "Moment of Prescience",
	type = {"chronomancy/chronomancy", 3},
	require = temporal_req3,
	points = 5,
	paradox = 10,
	cooldown = 18,
	getDuration = function(self, t) return math.ceil(self:getTalentLevel(t) * 2) end,
	getPower = function(self, t) return math.ceil(self:getTalentLevel(t) * 3) end,
	tactical = { BUFF = 4 },
	no_energy = true,
	no_npc_use = true,
	action = function(self, t)
		local power = t.getPower(self, t)
		-- check for Spin Fate
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if eff then
			local bonus = math.max(0, (eff.cur_save_bonus or eff.save_bonus) / 2)
			power = power + bonus
		end

		self:setEffect(self.EFF_PRESCIENCE, t.getDuration(self, t), {power=power})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[You pull your awareness fully into the moment increasing your stealth detection, see invisibility, defense, and accuracy by %d for %d turns.
		If you have Spin Fate going when you cast this spell you'll gain a bonus to these values equal to 50%% of your spin.
		This spell takes no time to cast.]]):
		format(power, duration)
	end,
}

newTalent{
	name = "Spin Fate",
	type = {"chronomancy/chronomancy", 4},
	require = temporal_req4,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	getSaveBonus = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	do_spin_fate = function(self, t, type)
		local save_bonus = t.getSaveBonus(self, t)
	
		if type ~= "defense" then
			if not self:hasEffect(self.EFF_SPIN_FATE) then
				game:playSoundNear(self, "talents/spell_generic")
			end
			self:setEffect(self.EFF_SPIN_FATE, t.getDuration(self, t), {max_bonus = t.getSaveBonus(self, t) * 5, save_bonus = t.getSaveBonus(self, t)})
		end
		
		return true
	end,
	info = function(self, t)
		local save = t.getSaveBonus(self, t)
		local duration = t.getDuration(self, t)
		return ([[You've learned to make minor corrections in how future events unfold.  Each time you make a saving throw all your saves are increased by %d (stacking up to a maximum increase of %d for each value).
		The effect will last %d turns but the duration will refresh everytime it's reapplied.]]):
		format(save, save * 5, duration)
	end,
}