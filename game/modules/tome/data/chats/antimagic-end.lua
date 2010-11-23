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

newChat{ id="welcome",
	text = [[Excellent! You truly prove that no mage-wrought flame or storm can stand against blade and arrow! Come, learn our ways. You are ready.]],
	answers = {
		{"Thank you. I shall not let magic triumph! #LIGHT_GREEN#[you are taught the secrets of antimagic]", action=function(npc, player) player:setQuestStatus("antimagic", engine.Quest.COMPLETED) end},
	}
}

return "welcome"
