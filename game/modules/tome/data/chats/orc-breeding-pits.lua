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
	text = [[#LIGHT_GREEN#*A ray of light illuminates the gleam of steal amidst the grass. Investigating, you find a lone sun paladin lying stricken on the ground. Her wounds are minor, but her pallid features bely a poison that is taking its final toll. She whispers to you.*#WHITE#
Help, Help me.
]],
	answers = {
		{"What should I do?", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[I found it... the abomination Aeryn sent me to seek out. The breeding pits of the orcs... It is more vile than you can imagine... They have it hidden away from their encampments, out of sight of all their people. Their mothers, their young, all there - all vulnerable!
#LIGHT_GREEN#*She pulls out a sketched map, and with some effort puts it in your palm.*#WHITE#

This could be the final solution, the end to the war... forever. We must strike soon, before reinforcements...

#LIGHT_GREEN#*She looks hard at you, exerting all her effort into a final pleading stare.*#WHITE#]],
	answers = {
		{"I cannot do this myself... I will tell Aeryn about it, it is in her hands.", action=function(npc, player)
			player:grantQuest("orc-breeding-pits")
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out")
		end},
		{"I will go myself and ensure this is thoroughly dealt with.", action=function(npc, player)
			player:grantQuest("orc-breeding-pits")
			local q = player:hasQuest("orc-breeding-pits")
			q:reveal()
		end},
		{"You want me to kill mothers and children? This is barbaric, I'll have nothing to do with it!"},
	}
}

return "welcome"
