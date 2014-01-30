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
		{"I am looking for staff training.", jump="training"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="training",
	text = [[I can teach you staff combat (talent category Spell/Staff combat).  Learning the basics costs 100 gold, while more intensive tutelage to gain proficiency costs 500 gold.  Once you're proficient, I can teach you more refined techniques for an additional 750 gold.]],
	answers = {
		{"Just give me the basics (reveals locked talent category) - 100 gold.", action=function(npc, player) -- Normal basic training
			game.logPlayer(player, "The staff carver spends some time with you, teaching you the basics of staff combat.")
			player:incMoney(-100)
			player:learnTalentType("spell/staff-combat", false)
			if player:getTalentTypeMastery("spell/staff-combat") < 1 then
				player:setTalentTypeMastery("spell/staff-combat", math.min(1.1, player:getTalentTypeMastery("spell/staff-combat") + 0.3))
				game.logPlayer(player, "He is surprised at how quickly you are able to follow his tutelage.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("spell/staff-combat") or player:knowTalentType("spell/staff-combat") == false then return end
			return true
		end},
		{("Please teach me what I need to know (unlocks talent category) - %d gold."):format(500),
		action=function(npc, player) --Normal intensive training
			game.logPlayer(player, "The staff carver spends a substantial amount of time teaching you all of the techniques of staff combat.")
			player:incMoney(-500)
			player:learnTalentType("spell/staff-combat", true)
			if player:getTalentTypeMastery("spell/staff-combat") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("spell/staff-combat", math.max(1.0, player:getTalentTypeMastery("spell/staff-combat") + 0.3))
			end
			if player:getTalentTypeMastery("spell/staff-combat") > 1 then
				game.logPlayer(player, "He is impressed with your mastery and shows you a few extra techniques.")
			end
			player.changed = true
		end,
		cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("spell/staff-combat") then return end
			return true
		end},
		{"I'm already proficient, but I want to be an expert (improves talent mastery by 0.2) - 750 gold.", action=function(npc, player) --Enhanced intensive training
			player:incMoney(-750)
			player:learnTalentType("spell/staff-combat", true)
			player:setTalentTypeMastery("spell/staff-combat", player:getTalentTypeMastery("spell/staff-combat") + 0.2)
			game.logPlayer(player, ("The staff carver spends a great deal of time going over the finer details of staff combat with you%s."):format(player:getTalentTypeMastery("spell/staff-combat")>1 and ", including some esoteric techniques" or ""))
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("spell/staff-combat") and player:getTalentTypeMastery("spell/staff-combat") < 1.2 then return true end
		end},
		{"No thanks."},
	}
}

return "welcome"
