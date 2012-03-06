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

name = "From bellow, it devours"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Your escape from Reknor got your heart pounding and your desire for wealth and power increased tenfold."
	desc[#desc+1] = "Maybe it is time for you to start an adventurer's career. Deep below the Iron Throne mountains lies the Deep Bellow."
	desc[#desc+1] = "It has been long sealed away but still, from time to time adventurers go there looking for wealth."
	desc[#desc+1] = "None that you know of has come back yet, but you did survive Reknor. You are great."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
