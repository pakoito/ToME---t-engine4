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

newAI("summoned", function(self)
	-- Run out of time ?
	if self.summon_time then
		self.summon_time = self.summon_time - 1
		if self.summon_time <= 0 then
			game.logPlayer(self.summoner, "#PINK#Your summoned %s disappears.", self.name)
			self:die()
		end
	end

	-- Do the normal AI, otherwise follows summoner
	if self.ai_target.actor == self.summoner then self.ai_target.actor = nil end
	if self:runAI("target_simple") then
		return self:runAI(self.ai_real)
	else
		self.ai_target.actor = self.summoner
		local ret = self:runAI(self.ai_real)
		self.ai_target.actor = nil
		return ret
	end
end)
