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

uberTalent{
	name = "Draconic Body",
	mode = "passive",
	cooldown = 40,
	require = { special={desc="Be close to the draconic world", fct=function(self) return self:attr("drake_touched") and self:attr("drake_touched") >= 2 end} },
	trigger = function(self, t, value)
		if self.life - value < self.max_life * 0.3 and not self:isTalentCoolingDown(t) then
			self:heal(self.max_life * 0.4)
			self:startTalentCooldown(t)
		end
	end,
	info = function(self, t)
		return ([[Your body hardens, when pushed below 30%% life you are healed for 40%% of your total life.]])
		:format()
	end,
}
