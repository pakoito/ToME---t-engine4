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

newChat{ id="start",
	auto = true, text="",
	answers = {
		{cond=function(npc, player) local q = player:hasQuest("lost-merchant"); return q and q:isStatus(q.COMPLETED, "saved") end, jump="welcome"},
		{jump="closed"},
	},
}

newChat{ id="closed",
	text = [[*This store seems to not be open yet*]],
	answers = {
		{"[leave]"},
	}
}

newChat{ id="welcome",
	text = [[Ah my good friend @playername@!
Thansk to you I made it safely to this great city, I am to open my shop soon, but I owe you a bit so I could maybe open early for you if you are in need of some rare goods.]],
	answers = {
		{"Yes please, let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"Sorry I have to go!"},
	}
}

return "start"
