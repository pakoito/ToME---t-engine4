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

-- Quest for Tol Falas
name = "The Island of Dread"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have heard that in the bay of Belfalas, near the Charred Scar, to the south, lies the ruined tower of Tol Falas."
	desc[#desc+1] = "There are disturbing rumors of greater undeads and nobody who reached it ever returned."
	desc[#desc+1] = "Perhaps you should explore it and find the truth, and the treasures, for yourself!"
	return table.concat(desc, "\n")
end
