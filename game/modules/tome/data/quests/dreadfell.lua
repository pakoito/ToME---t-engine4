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

-- Quest for the Dreadfell
name = "The Island of Dread"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have heard that near the Charred Scar, to the south, lies a ruined tower known as the Dreadfell."
	desc[#desc+1] = "There are disturbing rumors of greater undead, and nobody who reached it ever returned."
	desc[#desc+1] = "Perhaps you should explore it and find the truth, and the treasures, for yourself!"
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game.state:storesRestock()
	end
end
