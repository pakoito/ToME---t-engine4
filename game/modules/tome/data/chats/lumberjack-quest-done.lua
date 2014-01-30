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
	text = [[#LIGHT_GREEN#*Ben lies defeated at your feet*#WHITE#
T...thank you for... *cough*... saving me from the curse.
I did no... not want for this to...
#LIGHT_GREEN#*he coughs one last time and dies, a smile on his face as his curse is gone.*#WHITE#]],
	answers = {
		{"Rest in peace.", action=function(npc, player) player:setQuestStatus("lumberjack-cursed", engine.Quest.COMPLETED) end},
	}
}

return "welcome"
