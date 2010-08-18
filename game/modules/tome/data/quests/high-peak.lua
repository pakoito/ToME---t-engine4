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

name = "Falling Toward Apotheosis"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have vanquished the masters of the Orc Pride, now you must venture inside the most dangerous place of this world, the High Peak."
	desc[#desc+1] = "Seek the Blue Wizards and stop them before they bend the world to their will."
	desc[#desc+1] = "To enter you will need the four orbs of command to remove the shield over the peak."
	desc[#desc+1] = "The entrance to the peak passes through a place called 'the slime tunnels', probably located inside or near Grushnak Pride."

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
end
