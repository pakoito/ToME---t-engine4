-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	text = [[#LIGHT_GREEN#*As the monstrous spider falls you see something... moving in her belly until it explodes! A tall black man steps out of the spewed guts, surrounded by a golden light.*#WHITE#
By the Sun! I thought I would never again see a friendly face!
Thank you. I am Rashim, and I am in your debt.
]],
	answers = {
		{"I have been sent by your wife. She was worried for you.", jump="leave"},
	}
}

newChat{ id="leave",
	text = [[Ah, my dear heart!
Well, now that I am free I will create a portal to the Gates of Morning. I think I've seen enough spiders for the rest of my life.]],
	answers = {
		{"Lead the way!", action=function(npc, player) player:hasQuest("spydric-infestation"):portal_back(player) end},
	}
}

return "welcome"
