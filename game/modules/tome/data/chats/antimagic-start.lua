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

local sex = game.player.female and "sister" or "brother"

newChat{ id="welcome",
	text = [[#VIOLET#*The moment you arrive at the map's indicated location, you are grabbed by two olive-clad warriors and thrown into a crude arena!*
#LIGHT_GREEN#*You hear the voice of the fighter you met previously ring above you.*#WHITE#
Welcome, ]]..sex..[[! Your training begins! I want to see you prove your superiority over the works of magic! Fight!]],
	answers = {
		{"But wha.. [you notice your first opponent is already there]"},
	}
}

return "welcome"
