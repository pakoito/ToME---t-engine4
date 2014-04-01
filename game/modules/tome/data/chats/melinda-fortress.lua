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

local ql = game.player:hasQuest("love-melinda")
local set = function(what) return function(npc, player) ql:setStatus(ql.COMPLETED, "chat-"..what) end end
local isNotSet = function(what) return function(npc, player) return not ql:isCompleted("chat-"..what) end end
local melinda = game.level:findEntity{define_as="MELINDA_NPC"}
local butler = game.level:findEntity{define_as="BUTLER"}
print("===", butler)

newChat{ id="welcome",
	text = [[Hi, sweety!]],
	answers = {
		{"#LIGHT_GREEN#[kiss her]#WHITE#"},
		{"Are you settling in fine?", cond=isNotSet"settle", action=set"settle", jump="settle"},
	}
}

ql.wants_to = ql.wants_to or "derth"
local dest = {
	derth = [[I want to open my own little shop in Derth?]],
	magic = [[I want to study magic at Angolwen?]],
	antimagic = [[I want to train at Zigur?]],
}

newChat{ id="settle",
	text = [[Well let me say that tank is #{bold}#dreadful#{normal}#, but that weird butler says it is the only way.
I do start to feel better too.
However I must say I get bored around here a little.
Do you remember, I once told you ]]..dest[ql.wants_to]..[[ Maybe we could find a way to get me there during the day and return for my treatment during the night?]],
	answers = {
		{"Oh yes, I think we could arrange that. Shadow, would it be possible to create a portal for her?", jump="portal", switch_npc=butler},
	}
}

newChat{ id="portal",
	text = [[Yes Master. I will arrange for that right now.
She will be able to come and go unnoticed.]],
	answers = {
		{"That is perfect.", jump="portal2", switch_npc=melinda, action=function(npc, player)
			local spot = game.level:pickSpot{type="portal-melinda", subtype="back"}
			if spot then
				local g = game.zone:makeEntityByName(game.level, "terrain", "TELEPORT_OUT_MELINDA")
				game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
			end
		end},
	}
}

newChat{ id="portal2",
	text = [[Oh this is great, thank you! My own secret lair, my own life.]],
	answers = {
		{"I only wish your happiness, I am glad to provide.", jump="reward"},
	}
}

newChat{ id="reward",
	text = [[#LIGHT_GREEN#*Looking all glamorous she comes closer*#WHITE#
Now my sweet one, where were we the last time?]],
	answers = {
		{"My memory fails me, care to help me remember? #LIGHT_GREEN#[smile playfully at her]", action=function(npc, player)
			player:setQuestStatus("love-melinda", engine.Quest.COMPLETED, "portal-done")
			world:gainAchievement("MELINDA_LUCKY", player)
			game:setAllowedBuild("cosmetic_bikini", true)
		end},
	}
}

return "welcome"
