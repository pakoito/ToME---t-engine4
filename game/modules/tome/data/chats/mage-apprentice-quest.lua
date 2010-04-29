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
	text = [[#LIGHT_GREEN#*Before you stands a young man, a novice mage by his looks*#WHITE#
Good day to you fellow traveller!]],
	answers = {
		{"What brings an apprentice mage in the wilds?", cond=function(npc, player) return not player:hasQuest("mage-apprentice") end, jump="quest"},
		{"Do you have any items to sell?", jump="store"},
		{"Sorry I have to go!"},
	}
}

newChat{ id="quest",
	text = [[Ahh, that is my sad story ... but I would not bother you with it my friend.]],
	answers = {
		{"Please you do not.", jump="quest2"},
		{"Ok, bye then!"},
	}
}
newChat{ id="quest2",
	text = [[Well if you insist...
I am a novice mage, as you might have noticed, and my goal is to be accepted by the elves of Angolwen to be taugth the secrets of the arcane.]],
	answers = {
		{"Who are the elves of Angolwen?", jump="quest3"},
		{"Well good luck, bye!"},
	}
}
newChat{ id="quest3",
	text = [[The keepers of ar... err I do not think I am supposed to talk about them sorry my friend...
Anyway, I must collect 15 magic staves and I have yet to find one. If you could bring me some should you find any, I would be grateful]],
	answers = {
		{"I will keep that in mind", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"No way, bye!"},
	}
}

return "welcome"
