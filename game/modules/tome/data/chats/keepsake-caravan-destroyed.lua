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

newChat{ id="caravan",
	text = [[#VIOLET#*As the last member of the caravan lies dying, you look at him and see the hate that fills his eyes.*#LAST#
We should have finished you off that day. You deserved no mercy!]],
	answers = {
		{
			"And I will show you no mercy. #LIGHT_GREEN#[Kill him]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_evil_choice(player)
				player:hasQuest("keepsake"):on_caravan_destroyed_chat_over(player)
			end
		},
		{
			"I am sorry. #LIGHT_GREEN#[Help him]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_good_choice(player)
			end,
			jump="apology"
		},
	}
}

newChat{ id="apology",
	text = [[#VIOLET#*Before you can help him, he collapses to the ground and dies.*#LAST#]],
	answers = {
		{
			"...",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_caravan_destroyed_chat_over(player)
			end,
		},
	}
}

return "caravan"
