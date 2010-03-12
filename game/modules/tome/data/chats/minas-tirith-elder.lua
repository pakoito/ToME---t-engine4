newChat{ id="welcome",
	text = [[Welcome @playername@ to Minas Tirith traveler, please be quick my time is precious.]],
	answers = {
		{"Nothing, excuse me. Bye!"},
		{"I have found this staff in my travels, it looks really old and powerful. I dare not use it.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) and player:findInAllInventories("Staff of Absorption") end},
	}
}

newChat{ id="found_staff",
	text = [[#LIGHT_GREEN#*He examines the staff*#WHITE# Indeed you were right in bringing it here. While I cannot sense its true purpose I feel this could be used to cause many wrongs.
Please surrender the staff to the protection of the King while we work to learn its power.
This could be related to the rumours we hear from the far east...]],
	answers = {
		{"Take it Sir.", action=function(npc, player)
			local o, item, inven_id = player:findInAllInventories("Staff of Absorption")
			player:removeObject(inven_id, item, true)
			o:removed()

			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			player.winner = true
			local D = require "engine.Dialog"
			D:simplePopup("Winner!", "#VIOLET#Congratulations you have won the game! At least for now... The quest has only started!")

			config.settings.tome = config.settings.tome or {}
			config.settings.tome.allow_evil = true
			game:saveSettings("tome.allow_evil", ("tome.allow_evil = %s\n"):format(tostring(config.settings.tome.allow_evil)))
		end},
	}
}

return "welcome"
