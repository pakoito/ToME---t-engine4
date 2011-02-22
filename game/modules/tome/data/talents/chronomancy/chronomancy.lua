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
	name = "Probability Weaving",
	type = {"chronomancy/chronomancy", 1},
	mode = "sustained",
	require = temporal_req1,
	sustain_paradox = 75,
	points = 5,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDefense = function(self, t) return self:combatTalentSpellDamage(t, 4, 20) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		return ([[Bends the laws of probability, increasing your defense by %d and reducing the chance you'll be critically hit by melee or ranged attacks by %d%%.
		The defense increase will scale with the Magic stat.]]):format(defense, self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Deja Vu",
	type = {"chronomancy/chronomancy",2},
	require = temporal_req2,
	points = 5,
	paradox = 10,
	cooldown = 20,
	no_npc_use = true,
	getRadius = function(self, t) return 5 + math.floor(self:combatTalentSpellDamage(t, 2, 12) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:magicMap(t.getRadius(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		return ([[Your keen intuition allows you to form a mental picture of your surroundings in a radius of %d.
		The radius will scale with your Paradox and Magic stat.]]):
		format(radius)
	end,
}

newTalent{
	name = "Precognition",
	type = {"chronomancy/chronomancy",3},
	require = temporal_req3,
	points = 5,
	paradox = 25,
	cooldown = 50,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
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
		return ([[You peer %d turns into the future.  Note that visions of your own death will still be fatal.
		The duration will scale with your Paradox.]]):format(duration)
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
		return ([[You avoid all damage from a single damage source that occurs within the next %d turns.
		Additional talent points will lower the cooldown and the duration will scale with your Paradox.]]):
		format(duration)
	end,
}