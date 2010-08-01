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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("maglor", engine.Quest.COMPLETED, "drake-story") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*@npcname@ deep voice booms through the level.*#WHITE#
This is my domain, and I do not take kindly to intruders. What is your purpose here?]],
	answers = {
		{"I am here to kill you and take your treasures! Die bastard fish!", action=attack("DIE!")},
		{"I did not mean to intrude, I shall leave now.", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[Wait! You seem powerful, let me tell you a story first.
A very long time ago, at the very end of the first age of the world, the Silmarils where recoverd from the grasp of Morgoth in the War of the Wrath.
Soon after they were stolen by the two remaining sons of Fëanor, Maedhros and Maglor, therefore fullfilling their oath.
But they found they could no longer bear to wield them, they burned their flesh for their sins.
Maedhros thrust himself in a fiery chasm along with his Silmaril and Maglor threw his into the depths of the ocean, wandering the shores endlessly.
However after a while he regreted his act and dived to recover it, he had no chance of success yet he prevailed.
Ossë helped him, granting him the ability to live under the ocean to guard the Silmaril. There he remained for all the ages of the world.
But something happened recently, Maglor turned mad and now he looks upon all intelligent water live as a threat, which includes myself.
I can not leave this sanctuary but maybe you could help me?
After all this would be a gesture of kindness to end his madness and the Silmaril would gain a new, powerful, guardian.]],
	answers = {
		{"I still rather kill you and take your treasure!", action=attack("DIE!")},
		{"I shall do as you say, but how do I find him?", jump="givequest"},
		{"This seems... unwise, I must refuse sorry.", action=function(npc, player) player:grantQuest("maglor") player:setQuestStatus("maglor", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("maglor", engine.Quest.FAILED) end},
	}
}

newChat{ id="givequest",
	text = [[I can open a portal to his lair, far into the western sea, but be warned, this is one way only, I can not get you back you will have to find your own way.]],
	answers = {
		{"I will.", action=function(npc, player) player:grantQuest("maglor") player:setQuestStatus("maglor", engine.Quest.COMPLETED, "drake-story") end},
		{"This is a death trap! Goodbye.", action=function(npc, player) player:grantQuest("maglor") player:setQuestStatus("maglor", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("maglor", engine.Quest.FAILED) end},
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
		{"I want your treasures, water beast!", action=attack("Oh, is it so? Well, EARN IT !")},
		{"I spoke with Maglor, he did not seem hostile, or mad.", jump="maglor_friend", cond=function(npc, player) return player:isQuestStatus("maglor", engine.Quest.COMPLETED, "maglor-story") and not player:isQuestStatus("maglor", engine.Quest.COMPLETED, "kill-maglor") end},
		{"Farewell, Dragon."},
	}
}

newChat{ id="maglor_friend",
	text = [[#LIGHT_GREEN#*@npcname@ roars!*#WHITE# You listen to the lies of this mad elf!
You are corrupted! TAINTED!]],
	answers = {
		{"[attack]", action=attack("DO NOT MESS IN THE AFFAIRS OF DRAGONS!")},
		{"#LIGHT_GREEN#*Shake your head.*#LAST#He swayed my mind! Please I am not your ennemy.", jump="last_chance", cond=function(npc, player) return rng.percent(30 + player:getLck()) end},
	}
}

newChat{ id="last_chance",
	text = [[#LIGHT_GREEN#*@npcname@ calms down!*#WHITE# Very well, he is a trickster, now go finish your task, or do not come back.]],
	answers = {
		{"Thank you, mighty one."},
	}
}

end

return "welcome"

