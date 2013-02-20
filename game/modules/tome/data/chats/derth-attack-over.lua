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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A Halfling comes forth from his hiding place.*#WHITE#
You killed them all? Are we safe now? Oh, please tell me this was a bad dream!]],
	answers = {
		{"Be at ease. I have dispatched those monstrosities. Do you know where they came from or what they wanted?", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[From nowhere! From the sky!
I do not know. I was tending my crop just outside the town when I heard screaming. As I entered the town, I saw the dark cloud over here. Those... those... things were coming from it in blasts of lightning!]],
	answers = {
		{"It seems they have stopped coming for now. I will look for somebody who could help dispose of this nefarious cloud.", jump="quest2"},
	}
}

newChat{ id="quest2",
	text = [[Thank you! You have saved many people today!
I have heard of rumours of a reclusive town of wise and powerful men somewhere in the mountains. Maybe they could help? If they even exist...
There are also those Zigur-something people that claim to fight magic. Why are they not here?!]],
	answers = {
		{"You mean the Ziguranth. That would be me.", cond=function(npc, player) return player:isQuestStatus("antimagic", engine.Quest.DONE) end, jump="zigur"},
		{"I will not let you down.", action=function(npc, player) player:hasQuest("lightning-overload"):done_derth() end},
	}
}

newChat{ id="zigur",
	text = [[Well then please do something about this evil magic!]],
	answers = {
		{"I will!", action=function(npc, player) player:hasQuest("lightning-overload"):done_derth() end},
	}
}

return "welcome"
