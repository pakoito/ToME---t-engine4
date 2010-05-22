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
	text = [[Welcome @playername@ to Minas Tirith traveler, please be quick my time is precious.]],
	answers = {
		{"I have found a strange staff (#LIGHT_GREEN#*describe it in detail*#LAST#) in my travels, it looked really old and powerful. I dared not use it.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) end},
		{"Nothing, excuse me. Bye!"},
	}
}

newChat{ id="found_staff",
	text = [[#LIGHT_GREEN#*He remains silent for a while*#WHITE# Indeed you were right in coming here.
The staff you describe reminds me of some artifact of power of the old ages. Please may I see it?]],
	answers = {
		{"I am afraid I lost it. #LIGHT_GREEN#*Tell him the encounter with the orcs*", jump="lost_staff"},
	}
}

newChat{ id="lost_staff",
	text = [[Orcs?! In the west! This is most alarming! We have not seen any for nearly eighty years. They must come from the far east...
But do not let me trouble you, you brought important news and you are lucky to be alive. Please rest for a while.]],
	answers = {
		{"Thank you Sir.", action=function(npc, player)
			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			player.winner = true
			local D = require "engine.Dialog"
			D:simplePopup("Winner!", "#VIOLET#Congratulations, you have won the game! At least for now... The quest has only started!")

			world:gainAchievement("A_DANGEROUS_SECRET", player)
--			game:setAllowedBuild("evil_race", true)
		end},
	}
}

return "welcome"
