-- ToME - Tales of Middle-Earth
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
	text = [[Thanks for your help. What may I do for you?]],
	answers = {
		{"Tell me more about the Gates of Morning.", jump="explain-gates"},
		{"I need help to hunt for clue about the staff.", jump="clues", cond=function(npc, player) return not player:hasQuest("orc-pride") end},
		{"I am back from Mount Doom, where the orcs took the staff.", jump="mount-doom", cond=function(npc, player) return player:hasQuest("mount-doom") and player:hasQuest("mount-doom"):isCompleted() end},
		{"Sorry I have to go!"},
	}
}

newChat{ id="explain-gates",
	text = [[There are two main group of people here, humans and elves.
Humans came here in the second age, our ancestors were part of an expedition from Numenor to explore the world. Their ship was torn apart and the survivors landed on this continent.
They came across a group of elves fighting against the orc pride and helped them.
The elves invited them to stay with them in the Gates of Morning, in the Sunwall mountains.
The name comes from the earliest days of the world when the world was flat and the Sun came out of a gigantic cavern in the Sunwall.]],
	answers = {
		{"Thanks my lady.", jump="welcome"},
	},
}

newChat{ id="clues",
	text = [[I much as I would like to help our forces are already spread too thin, we can not provide you direct power.
But I might be able to help you by explaining how the Pride is organised, we could help each others.
Recently we have heard the pride speaking about a new master, or masters. They might be the ones behind the staff mystery of yours.
We suppose their main place of power is the High Peek in the center of the continent but it is innaccessible and covered by some kind of shield.
You must investigate the bastions of the Pride, maybe you will find more information about the High Peek, and any orcs you kill is one less that will attack us.
The known bastions of the Pride are:
- Rak'shor Pride, in the south west of the High Peek
- Gorbat Pride, in the southern desert
- Vor Pride, in the north east
- Grushnak Pride, which we could never locate, we only heard evasive rumours about it
- A group of corrupted humans live in Eastport on the southen costline, they have contact wit the Pride]],
	answers = {
		{"I will investigate them.", jump="welcome", action=function(npc, player)
			player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			player:grantQuest("orc-pride")
		end},
	},
}

newChat{ id="mount-doom",
	text = [[I have heard about that, some good men lost their life for this, I hope it was worth it.]],
	answers = {
		{"Yes my lady, they delayed the orcs so that I could get to the heart of the volcano. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="mount-doom-success",
			cond=function(npc, player) return player:isQuestStatus("mount-doom", engine.Quest.COMPLETED, "stopped") end,
		},
		{"I am afraid I was too late, but still I have some precious informations. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="mount-doom-fail",
			cond=function(npc, player) return player:isQuestStatus("mount-doom", engine.Quest.COMPLETED, "not-stopped") end,
		},
	},
}

newChat{ id="mount-doom-success",
	text = [[Blue Wizards ? I have never heard of them, there were rumours about a new master of the Pride, it seems they got two.
Thanks for all, you must continue your hunt, now you know what to look for.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("mount-doom", engine.Quest.DONE) end}
	},
}

newChat{ id="mount-doom-fail",
	text = [[Blue Wizards ? I have never heard of them, there were rumours about a new master of the Pride, it seems they got two.
I am afraid with the power they gained today they will be even harder to stop, but we do not have a choice.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("mount-doom", engine.Quest.DONE) end}
	},
}


return "welcome"
