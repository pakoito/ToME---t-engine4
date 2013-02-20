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

local has_rod = function(npc, player)
	return player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL") and not player:isQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "butler")
end
local read = player:attr("speaks_shertul")

newChat{ id="welcome",
	text = [[*#LIGHT_GREEN#This orb seems to represent the world of Eyal as a whole. It is also probably used for controlling the fortress.
]]..(not read and [[You do not understand the inscriptions there.#WHITE#*
#{italic}#"Rokzan krilt copru."#{normal}#]] or [[#WHITE#*#{italic}#"Insert control rod."#{normal}#]]),
	answers = {
		{"[Examine the orb]", jump="examine", cond=has_rod},
		{"[Fly the fortress -- #LIGHT_RED#FOR TESTING ONLY#LAST#]", action=function(npc, player) player:hasQuest("shertul-fortress"):fly() end, cond=function() return config.settings.cheat end},
		{"[Begin the Lichform ceremory]", cond=function(npc, player) local q = player:hasQuest("lichform") return q and q:check_lichform(player) end, action=function(npc, player) player:setQuestStatus("lichform", engine.Quest.COMPLETED) end},
		{"[Leave the orb alone]"},
	}
}

newChat{ id="examine",
	text = [[*#LIGHT_GREEN#The device seems to be made of pure crystal. It projects a very accurate map of the known world - including the forbidden continent of the south.
There seems to be a hole about the size and form of your Rod of Recall.#WHITE#*]],
	answers = {
		{"[Insert the rod]", jump="activate"},
		{"[Leave the orb alone]"},
	}
}
newChat{ id="activate",
	text = [[*#LIGHT_GREEN#As you take the rod close to the orb it seems to vibrate and react.
A shadow appears in a corner of the room! You retract the rod immediately but the shadow stays.
It looks like the horrors you fought when coming inside, only less degenerated.
The thing looks roughly humanoid, but it has no head and its limbs look like tentacles. It does not seem hostile.#WHITE#*]],
	answers = {
		{"[Leave the orb alone]", action=function(npc, player)
			player:hasQuest("shertul-fortress"):spawn_butler()
		end,},
	}
}

return "welcome"
