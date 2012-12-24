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

newChat{ id="welcome",
	action = function(npc, player) npc.talked_times = (npc.talked_times or 0) + 1 end,
	text = [[@playername@, nice to see you again! Or is this the first time you see me?]],
	answers = {
		{"Farewell, Grand Keeper."},
		{"Yes, this is our first meeting.", jump="first", cond=function(npc, player) return not npc.talked_times end},
	}
}

newChat{ id="first",
	text = [[Ah, for you perhaps, but not for me.
Listen, someday you will encounter me again but it will not be me as of now. A younger me, if you will.
This is very important: do not tell my previous me about me. Understood?]],
	answers = {
		{"I think so..."},
		{"Yes, Grand Keeper."},
	}
}

return "welcome"
