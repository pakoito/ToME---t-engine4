-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local q = game.player:hasQuest("tutorial")

newChat{ id="welcome",
	text = [[Hello there. What subject interests you?]],
	answers = {
		{"Basic gameplay", 
			action = function(npc, player) 
				game:changeLevel(2, "tutorial") 
				q:choose_basic_gameplay()
				player:setQuestStatus("tutorial", engine.Quest.COMPLETED, "started-basic-gameplay")
			end},
		{"Combat stat mechanics", 
			action = function(npc, player)
				game:changeLevel(3, "tutorial")
				q:choose_combat_stats()
				player:setQuestStatus("tutorial", engine.Quest.COMPLETED, "started-combat-stats")
			end},
		{"Never mind."},
		{"Is there nothing more for me to learn here?", 
			jump = "done",
			cond = function(npc, player) return q and q:isCompleted("finished-basic-gameplay") and q:isCompleted("finished-combat-stats") end, 
		},
	}
}


newChat{ id="done",
	text = [[

You have completed all the tutorials, and should now know the basics of ToME4. You are ready to step forward into the world to find glory, treasures and be mercilessly slaughtered by hordes of creatures you thought you could handle!

During this tutorial some creatures were adjusted according to the needs of the lessons. In the unforgiving world of Eyal, monsters are rarely this nice!

If you need a reminder of which key does what, you can access the game menu by pressing #GOLD#Escape#WHITE# and checking the key binds. You can also adjust them to suit your needs.

If this is your first time with the game, you will find the selection of races and classes limited. Don't worry; many, many more will become available as you unlock them during your adventures. 

Now go boldly and remember: #GOLD#have fun!#WHITE#
Press #GOLD#Escape#WHITE#, then select #GOLD#Save and Exit#WHITE#, and create a new character!]],
	answers = {
		{"Thank you."},
	}
}

return "welcome"
