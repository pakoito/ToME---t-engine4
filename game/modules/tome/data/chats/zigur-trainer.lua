-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local sex = game.player.female and "Sister" or "Brother"

if game.player:hasQuest("antimagic") then

newChat{ id="welcome",
	text = [[Welcome back, ]]..sex..[[.]],
	answers = {
		{"I am ready for the test", jump="test", cond=function(npc, player) return player:hasQuest("antimagic"):ten_levels_ok(player) end},
		{"I have got to go."},
	}
}

else

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A grim-looking Fighter stands there, clad in mail armour and a large olive cloak. He doesn't appear hostile - his sword is sheathed.*#WHITE#
]]..sex..[[, our guild has been watching you and we believe that you have potential.
We see that the hermetic arts have always been at the root of each and every trial this land has endured, and we also see that one day it will bring about our destruction, so we have decided to take action, training ourselves to combat those who wield the arcane.
We can train you, but you need to prove you are pure from the eldritch forces.
Return to us when your power has grown ten times without using any spells, runes or other magic devices. Come back here, and you will be tested and then we will train you.]],
	answers = {
		{"Ok, I will return then.", jump="ok"},
		{"I'm not interested.", jump="ko"},
	}
}
end

newChat{ id="ok",
	text = [[Excellent. Come back soon!]],
	answers = {
		{"I will, thank you.", action=function(npc, player) player:grantQuest("antimagic") end},
	}
}

newChat{ id="ko",
	text = [[Very well. I will say that this is disappointing, but it is your choice. Farewell.]],
	answers = {
		{"Farewell.", action=function(npc, player) player:grantQuest("antimagic") player:setQuestStatus("antimagic", engine.Quest.FAILED) end},
	}
}

newChat{ id="test",
	text = [[#VIOLET#*You are grabbed by two olive-clad warriors and thrown into a crude arena!*
#LIGHT_GREEN#*You hear the voice of the Fighter ring above you.*#WHITE#
]]..sex..[[! Your training begins! I want to see you prove your superiority over the works of magic! Fight!]],
	answers = {
		{"But wha.. [you notice your first opponent is already there]", action=function(npc, player) player:hasQuest("antimagic"):start_event() end},
	}
}

return "welcome"
