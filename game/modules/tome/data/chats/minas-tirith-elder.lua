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
	text = [[Welcome @playername@ to Minas Tirith traveler, please be quick as my time is precious.]],
	answers = {
		{"I have found a strange staff in my travels(#LIGHT_GREEN#*describe it in detail*#LAST#)  It looked very old and very powerful. I dared not use it.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) end},
		{"Nothing, excuse me. Bye!"},
	}
}

newChat{ id="found_staff",
	text = [[#LIGHT_GREEN#*He remains silent for a while*#WHITE# Indeed you were right to come here.
The staff you describe reminds me of an artifact of great power from ancient times. May I see it?]],
	answers = {
		{"Here it is. #LIGHT_GREEN#*Tell him the encounter with the orcs*#LAST# You should keep it, I can feel its power and it would be safer if it was guarded by the armies of the kingdom.",
		 jump="given_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk") end},
		{"I am afraid I lost it. #LIGHT_GREEN#*Tell him about the encounter with the orcs*",
		 jump="lost_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush-finish") end},
	}
}

newChat{ id="given_staff",
	text = [[I am truly astonished by your strength; surviving that encounter was an epic feat. Please take this as a token of my gratitude for your services.
As for the orcs, it is deeply troubling.  We have not seen any for eighty years...could they have come from the far east?
Anyway, thank you again, @playername@, for your help.]],
	answers = {
		{"Thank you, my lord.", action=function(npc, player)
			local o, item, inven_id = player:findInAllInventories("Staff of Absorption")
			player:removeObject(inven_id, item, true)
			o:removed()

			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			world:gainAchievement("A_DANGEROUS_SECRET", player)
		end, jump="orc_hunt"},
	}
}

newChat{ id="lost_staff",
	text = [[Orcs?! In the west?! This is deeply alarming! We have not seen any for nearly eighty years. They must have come from the far east...
But do not let me trouble you; you brought important news and you are lucky to be alive.]],
	answers = {
		{"Thank you, my lord.", action=function(npc, player)
			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			world:gainAchievement("A_DANGEROUS_SECRET", player)
		end, jump="orc_hunt"},
	}
}

newChat{ id="orc_hunt",
	text = [[We have heard rumours from the dwarves that there may still be an orc presence deep in the mines of Moria.
I know you have been through a lot, but we need somebody to investigate and determine if there is a connection with the staff.]],
	answers = {
		{"I will check the mines.", action=function(npc, player)
			player:grantQuest("orc-hunt")
		end},
	}
}

return "welcome"
