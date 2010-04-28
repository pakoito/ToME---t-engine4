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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*@npcname@ deep voice booms through the level.*#WHITE#
This is my domain, and I do not take on intruders kindly. What is your purpose here?]],
	answers = {
		{"I am here to kill you and take your treasures! Die bastard fish!", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"I did not mean to intrude, I shall leave now."},
	}
}

return "welcome"
