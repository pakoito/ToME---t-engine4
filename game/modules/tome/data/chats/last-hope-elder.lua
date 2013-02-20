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

newChat{ id="welcome",
	text = [[Welcome, @playername@, to Last Hope. Traveler, please be quick as my time is precious.]],
	answers = {
		{"I have found a strange staff in my travels (#LIGHT_GREEN#*describe it in detail*#LAST#)  It looked very old and very powerful. I dared not use it.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) end},
		{"The hunt for the staff took me to a continent far to the east, accessible only by magic portal. I've recently returned by just such a portal, and I come bearing instructions on how to construct a similar portal here in Last Hope to make the return journey possible. I'm sure the Elves there would welcome trade with the west.", jump="east_portal", cond=function(npc, player) local q = player:hasQuest("east-portal"); return q and not q:isCompleted("talked-elder") end},
		{"Nothing, excuse me. Bye!"},
	}
}

newChat{ id="found_staff",
	text = [[#LIGHT_GREEN#*He remains silent for a while*#WHITE# Indeed you were right to come here.
The staff you describe reminds me of an artifact of great power from ancient times. May I see it?]],
	answers = {
		{"Here it is. #LIGHT_GREEN#*Tell him about the encounter with the orcs*#LAST# You should keep it. I can feel its power and it would be safer if it were guarded by the armies of the kingdom.",
		 jump="given_staff", cond=function(npc, player) return game.party:findInAllPartyInventoriesBy("define_as", "STAFF_ABSORPTION") and player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk") or false end},
		{"I am afraid I lost it. #LIGHT_GREEN#*Tell him about the encounter with the orcs*",
		 jump="lost_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush-finish") end},
		{"I had it briefly but have lost it somehow.  It could have been some orcs I encountered ...",
		 jump="lost_staff", fallback=true, cond=function(npc, player) return player:hasQuest("staff-absorption") end},
	}
}

newChat{ id="given_staff",
	text = [[I am truly astonished by your strength; surviving that encounter was an epic feat.
As for the orcs, it is deeply troubling.  We have not seen any for eighty years... could they have come from the far east?
Anyway, thank you again, @playername@, for your help.]],
	answers = {
		{"Thank you, my lord.", action=function(npc, player)
			local mem, o, item, inven_id = game.party:findInAllPartyInventoriesBy("define_as", "STAFF_ABSORPTION")
			if mem and o then
				mem:removeObject(inven_id, item, true)
				o:removed()
			end

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
	text = [[We have heard rumours from the Dwarves that there may still be an orc presence deep in the old kingdom of Reknor, in the Iron Throne.
I know you have been through a lot, but we need somebody to investigate and determine if there is a connection with the staff.]],
	answers = {
		{"I will check the mines.", action=function(npc, player)
			player:grantQuest("orc-hunt")
		end},
	}
}

newChat{ id="east_portal",
	text = [[That's extraordinary! I know a number of merchant princes who will salivate at the idea of new trade routes opening. But tell me, how fares your quest for the staff?]],
	answers = {
		{"The staff is recovered and the culprits slain. They will trouble us no more. [tell him the whole story]", jump="east_portal_winner", cond=function(npc, player) return player:isQuestStatus("high-peak", engine.Quest.DONE) end},
		{"The hunt continues. The construction of this portal will be of great assistance in the staff's recovery.", jump="east_portal_hunt", cond=function(npc, player) return not player:isQuestStatus("high-peak", engine.Quest.DONE) end},
	}
}

newChat{ id="east_portal_winner",
	text = [[Excellent! Well then, concerning this fascinating portal, I'm afraid that men have largely forgotten whatever they once knew about the great magics of old. I know of only one man in these lands who might be able to help you, a wise man and recent arrival to Last Hope named Tannen. He claims to hail from Angolwen, a supposed haven for practitioners of magic and mysticism. He arrived just months ago with fabulous wealth and has already constructed his own tower in the northern part of the city. I know little of him, but if he is to be believed, then he is your best hope.]],
	answers = {
		{"Thank you.", action=function(npc, player) player:setQuestStatus("east-portal", engine.Quest.COMPLETED, "talked-elder") end},
	}
}

newChat{ id="east_portal_hunt",
	text = [[In that case, let us proceed as quickly as possible. Now, concerning this fascinating portal. I'm afraid that men have largely forgotten whatever they once knew about the great magics of old. I know of only one man in these lands who might be able to help you, a wise man and recent arrival to Last Hope named Tannen. He claims to hail from Angolwen, a supposed haven for practitioners of magic and mysticism. He arrived just months ago with fabulous wealth and has already constructed his own tower in the northern part of the city. I know little of him, but if he is to be believed, then he is your best hope.]],
	answers = {
		{"Thank you.", action=function(npc, player) player:setQuestStatus("east-portal", engine.Quest.COMPLETED, "talked-elder") end},
	}
}

return "welcome"
