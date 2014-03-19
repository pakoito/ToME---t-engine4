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
	text = [[@playername@, you are called to serve. The nearby unhallowed morass inhabitants are growing restless.
You must go there and find the source.]],
	answers = {
		{"I will, Grand Keeper.", action=function() game:changeLevel(1, "unhallowed-morass") end},
		{"I am sorry, but I cannot do that.", action=function(npc, player) player:setQuestStatus("start-point-zero", engine.Quest.FAILED) end},
	}
}

return "welcome"
