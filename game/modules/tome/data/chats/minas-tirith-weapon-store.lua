newChat{ id="welcome",
	text = [[Welcome @playername@ to my shop.]],
	answers = {
		{"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"I am looking for martial training.", jump="training"},
		{"Sorry I have to go!"},
	}
}

newChat{ id="training",
	text = [[I can indeed give some martial training (talent type Technique/Combat-training) for a fee of 50 gold pieces if you do not already know it.]],
	answers = {
		{"Please train me!", action=function(npc, player)
			game.logPlayer(player, "The smith spends some time with you, teaching you the basics of armour and weapons usage.")
			player.money = player.money - 50
			player:learnTalentType("technique/combat-training", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 50 then return end
			if player:knowTalentType("technique/combat-training") then return end
			return true
		end},
		{"No thanks."},
	}
}

return "welcome"
