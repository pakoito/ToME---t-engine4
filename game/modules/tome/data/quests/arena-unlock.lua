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

name = "The agent of the arena"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You were asked to prove your worth as a fighter by a rogue, in order to participate in the arena"
	if self:isCompleted() then
		desc[#desc+1] = "You succesfully defeated your adversaries and gained access to the arena!"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then who:setQuestStatus(self.id, engine.Quest.DONE) end
end
