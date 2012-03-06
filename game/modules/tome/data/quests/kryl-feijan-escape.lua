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

name = "The Sect of Kryl-Feijan"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You discovered a sect worshipping a demon named Kryl-Feijan in a crypt."
	desc[#desc+1] = "They were trying to bring it back into the world using a human sacrifice."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = "You defeated the acolytes and saved the woman. She told you she is the daughter of a rich merchant of Last Hope."
	elseif self:isStatus(self.FAILED) then
		if self.not_saved then
			desc[#desc+1] = "You failed to protect her when escorting her out of the crypt."
		else
			desc[#desc+1] = "You failed to defeat the acolytes in time - the woman got torn apart by the demon growing inside her."
		end
	end
	return table.concat(desc, "\n")
end
