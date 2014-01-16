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

local function evil(npc, player)
	engine.Faction:setFactionReaction(player.faction, npc.faction, 100, true)
	player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")
	player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED)
	world:gainAchievement("LOST_MERCHANT_EVIL", player)
	game:setAllowedBuild("rogue_poisons", true)
	local p = game.party:findMember{main=true}
	if p.descriptor.subclass == "Rogue"  then
		if p:knowTalentType("cunning/poisons") == nil then
			p:learnTalentType("cunning/poisons", false)
			p:setTalentTypeMastery("cunning/poisons", 1.3)
		end
	end

	if p:knowTalent(p.T_TRAP_MASTERY) then
		p:learnTalent(p.T_FLASH_BANG_TRAP, 1, nil, {no_unlearn=true})
		game.log("#LIGHT_GREEN#Before you leave the Lord teaches you how to create flash bang traps!")
	end

	game:changeLevel(1, "wilderness")
	game.log("As you depart the assassin lord says: 'And do not forget, I own you now.'")
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a menacing man clothed in black.*#WHITE#
Ahh, the intruder at last... And what shall we do with you? Why did you kill my men?]],
	answers = {
		{"I heard some cries, and your men... they were in my way. What's going on here?", jump="what"},
		{"I thought there might be some treasure to be had around here.", jump="greed"},
		{"Sorry, I have to go!", jump="hostile"},
	}
}

newChat{ id="hostile",
	text = [[Oh, you are not going anywhere, I'm afraid! KILL!]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement; you seem to be a practical man.", jump="offer"},
	}
}

newChat{ id="what",
	text = [[Oh, so this is the part where I tell you my plan before you attack me? GET THIS INTRUDER!]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement; you seem to be a practical man.", jump="offer"},
	}
}
newChat{ id="greed",
	text = [[I am afraid this is not your lucky day then. The merchant is ours... and so are you! GET THIS INTRUDER!!]],
	answers = {
		{"[attack]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"Wait! Maybe we could work out some kind of arrangement; you seem to be a practical man.", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[Well, I need somebody to replace the men you killed. You look sturdy; maybe you could work for me.
You will have to do some dirty work for me, though, and you will be bound to me.  Nevertheless, you may make quite a profit from this venture, if you are as good as you seem to be.
And do not think of crossing me.  That would be... unwise.]],
	answers = {
		{"Well, I suppose it is better than dying.", action=evil},
		{"Money? I'm in!", action=evil},
		{"Just let me and the merchant get out of here and you may live!", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
	}
}

return "welcome"
