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
	text = [[#LIGHT_GREEN#*As you step out of the portal you notice a human standing there, he wears a robe.*#WHITE#
Well met @playername@!
I am Meranas, Herald of Angolwen, I have come here at the request of King Eldarion who got worried about not seeing you coming back.
It has been some time we watched Tannen, and you revealed his true nature - and stopped him. For this we are grateful, and I think we can pay you back.
We have studied his portal research and if you give me the components I will create the portal for you, here and now!]],
	answers = {
		{"Yes Tannen was not exactly friendly. I thank you for your help, here are the components. [hand him the diamon and the athame]", action=function(npc, player) player:hasQuest("east-portal"):create_portal(npc, player) end},
	}
}

return "welcome"
