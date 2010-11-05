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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A tall woman stands before you, her fair skin radiates incredible power throught her white robe.*#WHITE#
I am Linaniil of the Kar'Krul. Welcome to our city, @playerdescriptor.subclass@. What may I do for you?]],
	answers = {
		{"I require all the help I can get, not for my sake but for the town of Derth, in the north east of here.", jump="save-derth", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("saved-derth") and not q:isCompleted("tempest-located") end},
		{"I am ready, send me to Urkis!", jump="teleport-urkis", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and not q:isEnded("tempest-located") and q:isCompleted("tempest-located") end},
		{"Nothing for now, sorry to have took your time. Farewell my lady."},
	}
}

newChat{ id="save-derth",
	text = [[Yes we have noticed the devastation that happened there. I have sent some friends to dispose of the cloud but the real threat is not there.
We know who created this abomination: Urkis. He is a Tempest, a powerful archmage who can control the storms.
A few years ago he has gone rogue, cutting himself from Angolwen. He remained quiet so we were reluctant to go against him openly, but it seems we have no choice now.
The removal of the cloud will take much time, in the meanwhile we can, if you are willing, send you to Urkis lair to try stop him.
I will not lie to you, we can send you there but this could be a death trap, and we have no way of knowing if there is a way for you to exit his lair as he lives on top of a tall peak in the Daikara mountains.]],
	answers = {
		{"I need to prepare myself, I will be back soon.", action=function(npc, player) player:setQuestStatus("lightning-overload", engine.Quest.COMPLETED, "tempest-located") end},
		{"I am ready, send me, I will not let the good people of Derth down.", action=function(npc, player) player:setQuestStatus("lightning-overload", engine.Quest.COMPLETED, "tempest-located") player:hasQuest("lightning-overload"):teleport_urkis() end},
	}
}

newChat{ id="teleport-urkis",
	text = [[Good luck to you, you have the blessings of Angolwen.]],
	answers = {
		{"Thank you.", action=function(npc, player) player:hasQuest("lightning-overload"):teleport_urkis() end},
	}
}

return "welcome"
