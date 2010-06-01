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
	text = [[#LIGHT_GREEN#*Before you stands a man covered in black clothes, he looks menacing*#WHITE#
Ahh, the intruder... Well my 'friend', what shall we do with you? Wy did you kill my men!]],
	answers = {
		{"I heard some cries, and your men ... were in my way. Now what's going on here?", jump="what"},
		{"I thought there could be some treasures to be had around here.", jump="greed"},
		{"Sorry I have to go!", jump="hostile"},
	}
}

newChat{ id="hostile",
	text = [[Ohh you will go nowhere I am afraid! KILL!]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement, you seem to be a practical man.", jump="offer"},
	}
}

newChat{ id="what",
	text = [[Oh so this is the part where I tell you my plan before you attack me ? GET THIS INTRUDER!]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement, you seem to be a pratical men.", jump="offer"},
	}
}
newChat{ id="greed",
	text = [[I am afraid this is not your lucky day then, the merchant is ours so are you... GET THIS INTRUDER! !]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement, you seem to be a pratical men.", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[Well I need somebody to replace the men you killed. You look sturdy, maybe you could work for me.
You will have to do some dirty work for me and you will be bound to me, but you might get some nice money out of it, if you are good.
And do not think of crossing me, that would be ... a mistake.]],
	answers = {
		{"Well I suppose it is better than dying.", action=function(npc, player)
			engine.Faction:setFactionReaction(player.faction, npc.faction, 100, true)
			player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")
			player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED)
		end},
		{"Money? I am in!", action=function(npc, player)
			engine.Faction:setFactionReaction(player.faction, npc.faction, 100, true)
			player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")
			player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED)
		end},
		{"Just let me and the merchant get out of here and you may live!", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
	}
}

return "welcome"
