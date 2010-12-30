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

local has_rod = function(npc, player) return player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL") end
local q = game.player:hasQuest("shertul-fortress")
local set = function(what) return function(npc, player) q:setStatus(q.COMPLETED, "chat-"..what) end end
local isNotSet = function(what) return function(npc, player) return not q:isCompleted("chat-"..what) end end

newChat{ id="welcome",
	text = [[*#LIGHT_GREEN#The creature slowly turns to you. You hear its terrible voice directly in your head.#WHITE#*
Welcome master.]],
	answers = {
		{"What are you and what is this place?", jump="what", cond=isNotSet"what", action=set"what"},
		{"Master? I am not your mas..", jump="master", cond=isNotSet"master", action=set"master"},
		{"Why do I understand you, the texts are unreadable to me.", jump="understand", cond=isNotSet"understand", action=set"understand"},
		{"What can I do here?", jump="storage", cond=isNotSet"storage", action=set"storage"},
		{"[leave]"},
	}
}

newChat{ id="master",
	text = [[*#LIGHT_GREEN#The creature glares at you.#WHITE#*
You posses a control rod. You are the master.]],
	answers = {
		{"Err ok.", jump="welcome"},
	}
}
newChat{ id="understand",
	text = [[*#LIGHT_GREEN#The creature glares at you.#WHITE#*
You are the master, you have the rod. I am created to speak to the master.]],
	answers = {
		{"Err ok.", jump="welcome"},
	}
}

newChat{ id="what",
	text = [[*#LIGHT_GREEN#The creature glares at you with intensity. You 'see' images in your head.
You see titanic wars in an age now forgotten. You see armies of what you suppose are Sher'Tuls since they look like the shadow.
They fight with weapons, magic and other things. They fight gods. They hunt them down, killing or banishing them.
You see great fortresses like this one, flying all over the skies of Eyal - shining bastions of power glittering in the young sun.
You see the gods beaten, defeated and dead. All but one.
Then you see darkness, it seems like the shadow does not know what followed those events.

You shake your head as the vision disipates, your normal sight comes back slowly.
#WHITE#*
]],
	answers = {
		{"Those are Sher'Tuls? They fought the gods?!", jump="godslayers"},
	}
}

newChat{ id="godslayers",
	text = [[They had to. They forged terrible weapons of war. They won.]],
	answers = {
		{"But then were are they now if they won?", jump="where"},
	}
}

newChat{ id="where",
	text = [[They are gone now. I can not tell you more.]],
	answers = {
		{"But I am the master!", jump="where"},
		{"Fine.", jump="welcome"},
	}
}

newChat{ id="storage",
	text = [[*#LIGHT_GREEN#The creature glares at you.#WHITE#*
You are the master. You can use this place as you desire. However most of the energies are depleted and only some rooms are usable.
To the south you will find the storage room.]],
	answers = {
		{"Thanks.", jump="welcome"},
	}
}

return "welcome"
