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
	text = [[I can indeed give some martial training (talent type Technique/Combat-training) for a fee of 50 gold pieces or the basic usage of bows and slings (Shoot talent) for 8 gold pieces.]],
	answers = {
		{"Please train me in generic weapons and armour usage.", action=function(npc, player)
			game.logPlayer(player, "The smith spends some time with you, teaching you the basics of armour and weapons usage.")
			player.money = player.money - 50
			player:learnTalentType("technique/combat-training", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 50 then return end
			if player:knowTalentType("technique/combat-training") then return end
			return true
		end},
		{"Please train me in the basic usage of bows and slings.", action=function(npc, player)
			game.logPlayer(player, "The smith spends some time with you, teaching you the basics of bows and slings.")
			player.money = player.money - 8
			player:learnTalent(player.T_SHOOT, true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 8 then return end
			if player:knowTalent(player.T_SHOOT) then return end
			return true
		end},
		{"No thanks."},
	}
}

return "welcome"
