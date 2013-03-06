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
	text = [[Welcome @playername@ to my shop.]],
	answers = {
		{"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"I am looking for mindstar training.", jump="training"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="training",
	text = [[I can briefly go over the basics (talent category Wild-gift/Mindstar-mastery, locked) for a fee of 100 gold pieces.  Alternatively, I can provide a more in-depth study for 750.]],
	answers = {
		{"Just give me the basics.", action=function(npc, player)
			game.logPlayer(player, "The shopkeeper spends some time with you, teaching you the basics of channeling energy through mindstars.")
			player:incMoney(-100)
			player:learnTalentType("wild-gift/mindstar-mastery", false)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			--if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") or player:knowTalentType("wild-gift/mindstar-mastery") == false then return end
			return true
		end},
		{"Please teach me all there is to know.", action=function(npc, player)
			game.logPlayer(player, "The shopkeeper spends a great deal of time going over the finer details of channeling energy through mindstars with you.")
			player:incMoney(-750)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			return true
		end},
		{"No thanks."},
	}
}

return "welcome"
