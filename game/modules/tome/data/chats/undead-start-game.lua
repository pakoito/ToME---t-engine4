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
	text = [[#LIGHT_GREEN#*Before you stands a Human clothed in black robes. He seems to be ignoring you.*#WHITE#
#LIGHT_GREEN#*You stand inside some kind of summoning circle, which prevents you from moving.*#WHITE#
Oh yes! YES, one more for my collection. My collection, yes. A powerful one indeed!]],
	answers = {
		{"[listen]", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = [[A powerful tool against my enemies. Yes, yes. They all hate me, but I will show them my power!
I will show them! SHOW THEM!]],
	answers = {
		{"I am not a tool! RELEASE ME!", jump="welcome3"},
	}
}

newChat{ id="welcome3",
	text = [[You cannot talk. You cannot talk! You are a slave, a tool!
You are mine! Be quiet!
#LIGHT_GREEN#*As his mind drifts off you notice part of the summoning circle is fading. You can probably escape!*#WHITE#
]],
	answers = {
		{"[attack]", action=function(npc, player)
			local floor = game.zone:makeEntityByName(game.level, "terrain", "SUMMON_CIRCLE_BROKEN")
			game.zone:addEntity(game.level, floor, "terrain", 22, 3)
		end},
	}
}

return "welcome"
