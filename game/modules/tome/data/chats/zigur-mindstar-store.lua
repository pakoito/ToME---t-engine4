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
		{"I am looking for mindstar training.", jump="training"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="training",
	text = [[I can teach you mindstar mastery (talent category Wild-gift/Mindstar mastery).  Learning the basics costs 100 gold, while more intensive training to gain proficiency costs 500 gold.  Once you're proficient, I can teach you some additional skills for 750 gold.]],
	answers = {
		{"Just give me the basics (reveals locked talent category) - 100 gold.", action=function(npc, player) -- Normal basic training
			game.logPlayer(player, "The shopkeeper spends some time with you, teaching you the basics of channeling energy through mindstars.")
			player:incMoney(-100)
			player:learnTalentType("wild-gift/mindstar-mastery", false)
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1 then
				player:setTalentTypeMastery("wild-gift/mindstar-mastery", math.min(1.1, player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.3))
				game.logPlayer(player, "He is impressed with your affinity for natural forces.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") or player:knowTalentType("wild-gift/mindstar-mastery") == false then return end
			return true
		end},
		{"Please teach me what I need to know (unlocks talent category) - 500 gold.", action=function(npc, player)
			game.logPlayer(player, "The shopkeeper spends a great deal of time going over the finer details of channeling energy through mindstars with you.")
			player:incMoney(-500)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("wild-gift/mindstar-mastery", math.max(1.0, player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.3))
			end
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") > 1 then
				game.logPlayer(player, "He is impressed with your mastery and shows you a few tricks to handle stronger energy flows.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			return true
		end},
		{"I'm already proficient, but I want to be an expert (improves talent mastery by 0.2) - 750 gold.", action=function(npc, player) --Enhanced intensive training
			player:incMoney(-750)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			player:setTalentTypeMastery("wild-gift/mindstar-mastery", player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.2)
			game.logPlayer(player, ("The shopkeeper spends a great deal of time going over the finer details of channeling energy through mindstars with you%s."):format(player:getTalentTypeMastery("wild-gift/mindstar-mastery")>1 and ", and teaches you enhanced mental discipline needed to maintain powerful energy fields" or ""))
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") and player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1.2 then return true end
		end},
		{"No thanks."},
	}
}

return "welcome"
