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

name = "Melinda, lucky girl"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "After rescuing Melinda from Kryl-Feijan and the cultists you met her again in Last Hope."
	if who.female then
		desc[#desc+1] = "You talked for a while and it seems she has a crush for you, even though you are yourself a woman."
	else
		desc[#desc+1] = "You talked for a while and it seems she has a crush for you."
	end
	return table.concat(desc, "\n")
end

function onWin(self, who)
	if who.dead then return end
	return 10, {
		"After your victory you came back to Last Hope and reunited with Melinda, who showned no signs of demonic corruption for the many years to come.",
		"You lived together and led a happy life, Melinda even learned a few adventurers tricks and you both traveled Eyal, making new legends.",
	}
end
