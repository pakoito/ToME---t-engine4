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

name = "Strange new world"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You arrived through the farportal in a cave, probably in the Far East."
	desc[#desc+1] = "Upon arrival you met an Elf and an orc fighting."

	if self:isCompleted("sided-fillarel") then
		desc[#desc+1] = "You decided to side with the Elven lady."
	elseif self:isCompleted("sided-krogar") then
		desc[#desc+1] = "You decided to side with the orc."
	end

	if self:isCompleted("helped-fillarel") then
		desc[#desc+1] = "Fillarel told you to go to the south east and meet with High Sun Paladin Aeryn."
	elseif self:isCompleted("helped-krogar") then
		desc[#desc+1] = "Krogar told you to go to the west and look for the Kruk Pride."
	end
	return table.concat(desc, "\n")
end

krogar_dies = function(self, npc)
	if self:isCompleted("sided-fillarel") then game.player:setQuestStatus(self.id, self.COMPLETED, "helped-fillarel")
	else
		game.player:setQuestStatus(self.id, self.COMPLETED, "helped-krogar")
		npc:doEmote(game.player.descriptor.race.." go to the east, find Kruk Pride!", 120)
	end
end

fillarel_dies = function(self, npc)
	if self:isCompleted("sided-krogar") then game.player:setQuestStatus(self.id, self.COMPLETED, "helped-krogar")
	else
		game.player:setQuestStatus(self.id, self.COMPLETED, "helped-fillarel")
		npc:doEmote(game.player.descriptor.race.." go to the south east, and tell Aeryn what happened to me!", 120)
	end
end
