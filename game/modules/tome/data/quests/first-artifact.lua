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

name = "Scrying for dummies"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have found an object that seems to be unique. It looks like it has hidden powers within."
	desc[#desc+1] = "Go to the town of Derth, to the south of the Trollshaws, and talk to the local scryer. Maybe she can be of help."
	if self:isCompleted() then
		desc[#desc+1] = "You have talked to the Halfling Elisa the Scryer. She was quite friendly, and gave you an orb of scrying which will identify all normal items automatically and can be used to contact her should you find more special items."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
