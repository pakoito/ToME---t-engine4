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

local p = game.party:findMember{main=true}
if not p:attr("forbid_arcane") or p:attr("forbid_arcane") < 2 then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A Halfling woman stands before you, clad in dark steel plate.*#WHITE#
Take the test, and then we can talk.]],
	answers = {
		{"But..."},
	}
}
return "welcome"
end



newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A Halfling woman stands before you, clad in dark steel plate.*#WHITE#
I am Protector Myssil. Welcome to Zigur.]],
	answers = {
		{"I require all the help I can get, not for my sake but for the town of Derth, to the northwest of here.", jump="save-derth", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("saved-derth") and not q:isCompleted("tempest-entrance") and not q:isStatus(q.DONE) end},
		{"Protector, I have dispatched the Tempest as you commanded.", jump="tempest-dead", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("tempest-entrance") and not q:isCompleted("antimagic-reward") and q:isStatus(q.DONE) end},
		{"Farewell, Protector."},
	}
}

newChat{ id="save-derth",
	text = [[Yes, we have sensed the blight of the eldritch forces there. I have people working to dispel the cloud, but the real threat is not there.
We know that a Tempest, a powerful Archmage who can control the storms, is responsible for the damage. Those wretched fools from Angolwen will not act. All corrupted!
So you must act, @playername@. I will show you the location of this mage - high in the Daikara mountains.
Erase him.]],
	answers = {
		{"You can count on me, Protector.", action=function(npc, player)
			player:hasQuest("lightning-overload"):create_entrance()
		end},
	}
}

newChat{ id="tempest-dead",
	text = [[So have I heard, @playername@. You prove worthy of your training. Go with the blessing of nature, @playername@ of Zigur.
#LIGHT_GREEN#*She touches your skin.  You can feel nature infusing your very being.*#WHITE#
This shall help your on your travels. Farewell!]],
	answers = {
		{"Thank you, Protector.", action=function(npc, player)
			player:hasQuest("lightning-overload"):create_entrance()
			if player:knowTalentType("wild-gift/fungus") then
				player:setTalentTypeMastery("wild-gift/fungus", player:getTalentTypeMastery("wild-gift/fungus") + 0.1)
			elseif player:knowTalentType("wild-gift/fungus") == false then
				player:learnTalentType("wild-gift/fungus", true)
			else
				player:learnTalentType("wild-gift/fungus", false)
			end
			-- Make sure a previous amulet didnt bug it out
			if player:getTalentTypeMastery("wild-gift/fungus") == 0 then player:setTalentTypeMastery("wild-gift/fungus", 1) end
			game.logPlayer(player, "#00FF00#You gain the fungus talents school.")
			player:hasQuest("lightning-overload"):setStatus(engine.Quest.COMPLETED, "antimagic-reward")
		end},
	}
}

return "welcome"
