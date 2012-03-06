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

name = "The Orbs of Command"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have found an orb of command that seems to be used to open the shield protecting the High Peak."
	desc[#desc+1] = "There seems to be a total of four of them. The more you have the weaker the shield will be."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("ORB_DESTRUCTION") and
		   self:isCompleted("ORB_UNDEATH") and
		   self:isCompleted("ORB_DRAGON") and
		   self:isCompleted("ORB_ELEMENTS") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			self:open_high_peak(who)
		end
	end
end

open_high_peak = function(self, who)
	game:onLevelLoad("wilderness-1", function(zone, wild)
		wild.map:removeParticleEmitter(wild.data.istari_shield)
	end)

	local g = game.zone:makeEntityByName(game.level, "terrain", "PEAK_STAIR")
	for j = 11, 18 do
		game.level.map(249, j, engine.Map.TERRAIN, g)
	end
	game.logPlayer(who, "#LIGHT_BLUE#There is a loud crack. The way is open.")
end
