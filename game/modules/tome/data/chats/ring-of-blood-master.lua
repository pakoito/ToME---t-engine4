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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a small humanoid creature with a disproportionate head.*#WHITE#
Ah, what have we here? @playerdescriptor.race@, I believe you have turned at the wrong corner.]],
	answers = {
		{"So it would seem. What is going on here?", jump="what"},
	}
}

newChat{ id="what",
	text = [[This is my Ring of Blood! Listen, you have now two choices.
Since you do not look like slave fodder to me I will offer to let you pay to play the game.
If you feel you cannot take part in a slaver's game, I am afraid you will need to... disappear.]],
	answers = {
		{"Slavers? This is so wrong! [attack]", action=attack("You think so? Die.")},
		{"Game? I like playing, what's this about?", jump="game"},
	}
}

newChat{ id="game",
	text = [[Well, you see, it's quite simple. I will mentally take control of various wild creatures or slaves while you use the orb of command on the other side of this room to take control of a slave.
Then we fight using our pawns for 10 rounds. If your slave survives you will win the Bloodcaller.]],
	answers = {
		{"What if I lose?", jump="lose"},
		{"Blood, death without self-harm risks? Great fun!", jump="price"},
	}
}

newChat{ id="lose",
	text = [[Normally you would be taken as a slave, but you look like you would be more useful as a full-time player, so you can just try again.]],
	answers = {
		{"Blood, death without self-harm risks? Great fun!", jump="price"},
	}
}

newChat{ id="price",
	text = [[Superb. Oh yes, before I forget, to use the orb you will need to pay the standard fee of 150 gold pieces.
I'm sure this is small money to an adventurer of your class.]],
	answers = {
		{"150 gold? Err... yes, sure.", action=function(npc) npc.can_talk = nil end},
	}
}

return "welcome"
