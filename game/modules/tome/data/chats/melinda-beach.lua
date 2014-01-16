-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

newChat{ id="welcome",

	text = [[#LIGHT_GREEN#*The two of you spend some time relaxing on the beach.
The air is fresh, the sand shimmers, and the surf roars softly.*#WHITE#

This was such a lovely idea!
I have had a wonderful time with you today.

#LIGHT_GREEN#*She looks longingly into your eyes.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[Lean closer and kiss her]#WHITE#", action=function() game.zone.start_yaech() end, jump="firstbase"},
	}
}

newChat{ id="firstbase",
	text = [[Just before your lips touch, you sense that something is very wrong.
]],
	answers = {
		{"#LIGHT_GREEN#[Continue...]#WHITE#"},
	}
}

return "welcome"
