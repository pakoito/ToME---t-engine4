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

newChat{ id="welcome",
	text = [[Welcome @playername@ to my shop.]],
	answers = {
		{"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"I am looking for martial training.", jump="training"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="training",
	text = [[I can indeed offer some martial training (talent category Technique/Combat-training) for a fee of 50 gold pieces; or the basic usage of bows and slings (Shoot talent) for 8 gold pieces.]],
	answers = {
		{"Please train me in generic weapons and armour usage.", action=function(npc, player)
			game.logPlayer(player, "The smith spends some time with you, teaching you the basics of armour and weapon usage.")
			player:incMoney(-50)
			player:learnTalentType("technique/combat-training", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 50 then return end
			if player:knowTalentType("technique/combat-training") then return end
			return true
		end},
		{"Please train me in the basic usage of bows and slings.", action=function(npc, player)
			game.logPlayer(player, "The smith spends some time with you, teaching you the basics of bows and slings.")
			player:incMoney(-8)
			player:learnTalent(player.T_SHOOT, true, nil, {no_unlearn=true})
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
