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

name = "Back and Back and Back to the Future"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "After passing through some kind of time anomaly you met a temporal warden who told you to destroy the abominations of this alternate timeline.\n"
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("twin") and self:isCompleted("clone") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			local Chat = require "engine.Chat"
			local chat = Chat.new("temporal-rift-end", {name="Temporal Warden"}, who)
			chat:invoke()
		end
	end
end
