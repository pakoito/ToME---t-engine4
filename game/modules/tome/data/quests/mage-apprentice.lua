-- ToME - Tales of Middle-Earth
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

name = "An apprentice task"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You met a novice mage who was tasked to collect many staves."
	desc[#desc+1] = "He asked for your help should you collect some that you do not use."
	if self:isCompleted() then
	else
		desc[#desc+1] = "#SLATE#* "..self.nb_collect.."/15#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
	end
end

on_grant = function(self, who)
	self.nb_collect = 0
end

collect_staff = function(self, who, o)
	self.nb_collect = self.nb_collect + 1
	if self.nb_collect > 15 then who:setQuestStatus(self, self.COMPLETED) end
end

can_offer = function(self, who)
	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "weapon" and o.subtype == "staff" then return true end
		end
	end
end
