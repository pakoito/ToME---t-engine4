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

name = "Unstable!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Investigate the Abashed Expanse looking for the source of the recent unstability.\n"
	if self:isCompleted("abashed") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the expanse and destroyed the spacial disturbance.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("abashed") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-allied")
		end
	end
end
