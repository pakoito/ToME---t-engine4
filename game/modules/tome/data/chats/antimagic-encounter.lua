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

local sex = game.player.female and "Sister" or "Brother"

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A grim-looking fighter approaches you, clad in mail armour and a large olive cloak. He doesn't appear hostile - his sword is sheathed.*#WHITE#
]]..sex..[[, I see that you trust the work of wizards as much as I. Our guild, the Ziguranth, has been watching you, @playerdescriptor.race@, and we believe that you have potential.
We see that the hermetic arts have always been at the root of each and every trial this land has endured, and we also see that one day it will bring about our destruction, so we have decided to take action, training ourselves to combat those who wield the arcane.
If you'd like to learn our ways, I could tell you where our guild's training camp is located...]],
	answers = {
		{"Seems good. Where is this camp?", jump="ok"},
		{"I'm... not sure I'm interested.", jump="ko"},
	}
}

newChat{ id="ok",
	text = [[#LIGHT_GREEN#*The fighter hands you a map. It shows a location to the north of Mirkwood forest.*#WHITE#
Excellent. When you feel ready, come seek us for your training. I look forward to it!]],
	answers = {
		{"I will, thank you.", action=function(npc, player) player:grantQuest("antimagic") end},
	}
}

newChat{ id="ko",
	text = [[Very well. I will say that this is disappointing, but it is your choice. Farewell.]],
	answers = {
		{"Farewell."},
	}
}

return "welcome"
