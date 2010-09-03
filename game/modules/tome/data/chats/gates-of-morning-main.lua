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
	text = [[Thank you for your help. What may I do for you?]],
	answers = {
		{"Tell me more about the Gates of Morning.", jump="explain-gates"},
		{"I need help in my hunt for clues about the staff.", jump="clues", cond=function(npc, player) return not player:hasQuest("orc-pride") end},
		{"I am back from Mount Doom, where the orcs took the staff.", jump="mount-doom", cond=function(npc, player) return player:hasQuest("mount-doom") and player:hasQuest("mount-doom"):isCompleted() end},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="explain-gates",
	text = [[There are two main group in the population here, humans and elves.
Humans came here in the second age. Our ancestors were part of an expedition from Numenor to explore the world. Their ship was wrecked and the survivors landed on this continent.
They came across a group of elves fighting against the orc pride and helped them.
The elves invited them to stay with them in the Gates of Morning, in the Sunwall mountains.
Their name comes from the earliest days of the world, when the world was flat and the Sun came out of a gigantic cavern in the Sunwall.]],
	answers = {
		{"Thank my lady.", jump="welcome"},
	},
}

newChat{ id="prides-dead",
	text = [[The news has indeed reached me, I could not believe it, for so long have we been at war with the Pride.
Now they are dead? At the hands of just one @playerdescriptor.race@? Truly I am amazed by your power.
While you were busy bringing their end to the orcs we managed to discover some parts of truth from a captive orc.
He talked about the shield protecting the High Peak, it seems to be controlled by "orbs of command" which the masters of the Prides had in their possession.
Look for them if you have not yet found them.
He also said the only way to enter the peak and de-activate the shield is through the "slime tunnels", located somewhere in one of the Prides, probably Grushnak.
]],
	answers = {
		{"Thanks my lady I will look for the tunnel and venture inside the Peak.", action=function(npc, player)
			player:setQuestStatus("orc-pride", engine.Quest.DONE)
			player:grantQuest("high-peak")
		end},
	},
}

newChat{ id="clues",
	text = [[As much as I would like to help, our forces are already spread too thin; we can not provide you with direct assistance.
But I might be able to help you by explaining how the Pride is organised.
Recently we have heard the Pride speaking about a new master, or masters. They might be the ones behind that mysterious staff of yours.
We believe that the heart of their power is the High Peek, in the center of the continent. But it is innaccessible and covered by some kind of shield.
You must investigate the bastions of the Pride. Perhaps you will find more information about the High Peek, and any orc you kill is one less that will attack us.
The known bastions of the Pride are:
- Rak'shor Pride, in the west of the southern deset
- Gorbat Pride, in a mountain range in the the southern desert
- Vor Pride, in the north east
- Grushnak Pride, on the eastern slope of the High Peak]],
-- - A group of corrupted humans live in Eastport on the southen costline, they have contact wit the Pride
	answers = {
		{"I will investigate them.", jump="welcome", action=function(npc, player)
			player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			player:grantQuest("orc-pride")
		end},
	},
}

newChat{ id="mount-doom",
	text = [[I have heard about that; good men lost their lives for this. I hope it was worth it.]],
	answers = {
		{"Yes my lady, they delayed the orcs so that I could get to the heart of the volcano. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="mount-doom-success",
			cond=function(npc, player) return player:isQuestStatus("mount-doom", engine.Quest.COMPLETED, "stopped") end,
		},
		{"I am afraid I was too late, but I still have some valuable information. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="mount-doom-fail",
			cond=function(npc, player) return player:isQuestStatus("mount-doom", engine.Quest.COMPLETED, "not-stopped") end,
		},
	},
}

newChat{ id="mount-doom-success",
	text = [[Blue Wizards ? I have never heard of them. There were rumours about a new master of the Pride, but it seems they got two.
Thank you for everything. You must continue your hunt now that you know what to look for.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("mount-doom", engine.Quest.DONE) end}
	},
}

newChat{ id="mount-doom-fail",
	text = [[Blue Wizards ? I have never heard of them, there were rumours about a new master of the Pride, but it seems they got two.
I am afraid with the power they gained today they will be even harder to stop, but we do not have a choice.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("mount-doom", engine.Quest.DONE) end}
	},
}


return "welcome"
