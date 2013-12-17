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

if not game.state:isAdvanced() and game.player.level < 20 then
newChat{ id="welcome",
	text = [[Good day to you.]],
	answers = {
		{"Good day to you too."},
	}
}
return "welcome"
end

if not game.player:hasQuest("spydric-infestation") then
newChat{ id="welcome",
	text = [[I have heard you are a great hero of the west. Could you help me, please?]],
	answers = {
		{"Maybe, what is it about?", jump="quest", cond=function(npc, player) return not player:hasQuest("spydric-infestation") end},
		{"I have got enough problems sorry."},
	}
}
else
newChat{ id="welcome",
	text = [[Welcome back, @playername@.]],
	answers = {
		{"I have found your husband. I take it he made it home safely?", jump="done", cond=function(npc, player) return player:isQuestStatus("spydric-infestation", engine.Quest.COMPLETED) end},
		{"I've got to go. Bye."},
	}
}
end

newChat{ id="quest",
	text = [[My husband, Rashim, is a Sun Paladin. He was sent to clear the spider lair of Ardhungol to the north of this town.
It has been three days now. He should be back by now. I have a feeling something terrible has happened to him. Please find him!
He should have a magical stone given by the Anorithil to create a portal back here, yet he did not use it!]],
	answers = {
		{"I will see if I can find him.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
		{"Spiders? Eww, sorry, but he is probably dead now."},
	}
}

newChat{ id="done",
	text = [[Yes, yes he did! He said he would have died if not for you.]],
	answers = {
		{"It was nothing.", action=function(npc, player)
			player:setQuestStatus("spydric-infestation", engine.Quest.DONE)
			world:gainAchievement("SPYDRIC_INFESTATION", game.player)
			game:setAllowedBuild("divine")
			game:setAllowedBuild("divine_sun_paladin", true)
		end},
	}
}

return "welcome"
