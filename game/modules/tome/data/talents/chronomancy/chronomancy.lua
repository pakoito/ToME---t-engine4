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
	name = "Prescience",
	type = {"chronomancy/chronomancy", 1},
	require = chrono_req1,
	points = 5,
	paradox = 3,
	cooldown = 20,
	tactical = {
		BUFF = 10,
	},
	no_energy = true,
	getDuration = function(self, t) return 1 + math.ceil((self:getTalentLevel(t)/4) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_PRESCIENCE, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[You bring your awareness fully into the present for %d turns, increasing your physical and spell critical strike chance by %d%%.
		The crit increase will improve with the Magic stat.]]):format(duration, power)
	end,
}

newTalent{
	name = "Deja Vu",
	type = {"chronomancy/chronomancy", 2},
	require = chrono_req2,
	points = 5,
	paradox = 5,
	cooldown = 20,
	no_npc_use = true,
	getRadius = function(self, t) return 3 + (self:combatTalentSpellDamage(t, 2, 8) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:magicMap(t.getRadius(self, t))
		if self:getTalentLevel(t) >= 4 then
			self:setEffect(self.EFF_SENSE, 1, {
				range = t.getRadius(self, t),
				actor = 1,
			})
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		return ([[Your powerful intuition gives you a glimpse of your surroundings in a %d radius.  At talent level 4 it also reveals creatures within this radius.
		The radius will improve with the Magic stat.]]):format(radius)
	end,
}

newTalent{
	name = "Foresight",
	type = {"chronomancy/chronomancy", 3},
	require = chrono_req3,
	points = 5,
	paradox = 5,
	cooldown = 20,
	tactical = {
		DEFEND = 10,
	},
	no_energy = true,
	getDuration = function(self, t) return 1 + math.ceil((self:getTalentLevel(t)/4) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_FORESIGHT, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[You glimpse into the future, granting you %d%% resistance to all attacks for the next %d turns.
		The resistance will improve with the Magic stat.]]):format(power, duration)
	end,
}

newTalent{
	name = "Precognition",
	type = {"chronomancy/chronomancy",4},
	require = chrono_req4,
	points = 5,
	paradox = 50,
	cooldown = 100,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_PRECOGNITION, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You peer %d turns into the future.  Note that visions of your own death can still be fatal.]]):format(duration)
	end,
}
