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

newChat{ id="berethh",
	text = [[#VIOLET#*Before you stands Berethh. His face shows no emotion, but his posture is threatening.#LAST#
]],
	answers = {
		{"Kyless is dead.", jump="response"}
	}
}

newChat{ id="response",
	text = [[I'm not sure if you deserved your fate. Still I cannot let you live.]],
	answers = {
		{
			"Then you will die like Kyless. #LIGHT_GREEN#[Attack]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_evil_choice(player)
			end
		},
		{
			"I need your help. I want to overcome my curse.",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_good_choice(player)
			end,
			jump="attack"
		},
		{
			"I do not want to kill you.",
			jump="attack"
		}
	}
}

newChat{ id="attack",
	text = [[#VIOLET#*Berethh ignores your comment, unslings his bow and prepares his attack.*#LAST#]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

return "berethh"
