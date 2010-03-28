newChat{ id="welcome",
	text = [[Welcome @playername@ to Minas Tirith traveler, please be quick my time is precious.]],
	answers = {
		{"I have found a strange staff(#LIGHT_GREEN#*describe it in details*#LAST#) in my travels, it looked really old and powerful. I dared not use it.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) end},
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
			D:simplePopup("Winner!", "#VIOLET#Congratulations you have won the game! At least for now... The quest has only started!")

--			game:setAllowedBuild("evil_race", true)
		end},
	}
}

return "welcome"
