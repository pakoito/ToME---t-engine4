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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*@npcname@'s deep voice booms through the caverns.*#WHITE#
This is my domain, and I do not take kindly to intruders. What is your purpose here?]],
	answers = {
		{"I am here to kill you and take your treasures! Die, damned fish!", action=attack("DIE!")},
		{"I did not mean to intrude. I shall leave now.", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[Wait! You seem to be worthy, so let me tell you a story.
During the Age of Pyre the world was sundered by the last effects of the Spellblaze. A part of the continental shelf of Maj'Eyal was torn apart and thrown into the sea.
The Naloren Elves perished... or so the world thinks. Some of them survived; using ancient Sher'Tul magic they had kept for themselves, they transformed to live underwater.
They are now called the nagas. They live deep in the ocean between Maj'Eyal and the Far East.
One of them, Slasul, rebelled against his order and decided he wanted the world for himself, both underwater and above. He found an ancient temple, probably a Sher'Tul remain, called the Temple of Creation.
He believes he can use it to #{italic}#improve#{normal}# nagas.
But he has become mad and now looks upon all other intelligent water life as a threat, and that includes myself.
I cannot leave this sanctuary, but perhaps you could help me?
After all, it would be an act of mercy to end his madness.]],
	answers = {
		{"I would still rather kill you and take your treasure!", action=attack("DIE!")},
		{"I shall do as you say, but how do I find him?", jump="givequest"},
		{"That seems... unwise. My apologies, but I must refuse.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("temple-of-creation", engine.Quest.FAILED) end},
	}
}

newChat{ id="givequest",
	text = [[I can open a portal to his lair, far away in the western sea, but be warned: this is one-way only. I cannot bring you back. You will have to find your own way.]],
	answers = {
		{"I will.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") end},
		{"This is a death trap! Goodbye.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("temple-of-creation", engine.Quest.FAILED) end},
	}
}


-----------------------------------------------------------------------
-- Coming back later
-----------------------------------------------------------------------
else
newChat{ id="welcome",
	text = [[Yes?]],
	answers = {
		{"[attack]", action=attack("TREACHERY!")},
		{"I want your treasures, water beast!", action=attack("Oh, is that so? Well, COME GET THEM!")},
		{"I spoke with Slasul, and he did not seem hostile, or mad.", jump="slasul_friend", cond=function(npc, player) return player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") and not player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "kill-slasul") end},
		{"Farewell, dragon."},
	}
}

newChat{ id="slasul_friend",
	text = [[#LIGHT_GREEN#*@npcname@ roars!*#WHITE# You listen to the lies of this mad naga!
You are corrupted! TAINTED!]],
	answers = {
		{"[attack]", action=attack("DO NOT MEDDLE IN THE AFFAIRS OF DRAGONS!")},
		{"#LIGHT_GREEN#*Shake your head.*#LAST#He swayed my mind! Please, I am not your enemy.", jump="last_chance", cond=function(npc, player) return rng.percent(30 + player:getLck()) end},
	}
}

newChat{ id="last_chance",
	text = [[#LIGHT_GREEN#*@npcname@ calms down!*#WHITE# Very well; he is indeed a trickster.  Now go finish your task, or do not come back!]],
	answers = {
		{"Thank you, mighty one."},
	}
}

end

return "welcome"

