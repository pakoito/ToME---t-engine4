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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A tall, hooded man stares at you*#WHITE#
I am waiting for a great fighter. Go away.
#LIGHT_GREEN#*The man ignores you for a few uncomfortable seconds, then asks:*#WHITE#
What is it? Are you the fighter I am waiting for?
]],
	answers = {
		{"No", jump="no"},
		{"Yes", jump="yes"},
	}
}

newChat{ id="no",
	text = [[#LIGHT_GREEN#*The man stares back at you*#WHITE#
That's unfortunate. You look like a fighter.
#LIGHT_GREEN#*The hooded man draws a smile in his face. You can't tell if it's an arrogant
#LIGHT_GREEN#smirk, or a sign of satisfaction. Concerned, you draw your hand closer to your
#LIGHT_GREEN#weapon*#WHITE#
Heheheh... indeed, you are.
I am looking for strong fighters for battling in the arena. A tiny entertainment for the
masses... but also a good source of good gold, and experience.
Listen, here is the deal. If you can prove your worth as fighter, I will give you
an invitation to the arena.
Fight three combatants. If you win, you get a pass. If you can survive, that is...
]],
	answers = {
		{"Interesting. I am up to the challenge.", jump="yes"},
		{"I am not interested.", jump="ok"},
	}
}

newChat{ id="yes",
	text = [[#LIGHT_GREEN#*The man shows a devious smile*#WHITE#
Ah, excellent. A great fighter is always willing to head into battle.
Heheh... very well then, follow me, @playerdescriptor.race@.
#LIGHT_GREEN#*The man starts walking away, but suddenly turns to you*#WHITE#
Just remember, you might lose your life if you are weak.
But that is not the case, is it? Heheh...
]],
	answers = {
		{"Let's go", jump="go"},
		{"Wait, I am not ready yet.", jump="ok"},
	}
}

newChat{ id="go",
	text = "#LIGHT_GREEN#*The man quietly walks away, after making you a gesture to follow him*",
	answers = {
		{"#LIGHT_GREEN#*You follow the man*",
		action = function (self, player)
			self:die()
			player:grantQuest("arena-unlock")
			game:changeLevel(1, "arena-unlock")
			require("engine.ui.Dialog"):simpleLongPopup("Get ready!", "Defeat all three enemies!", 400)
		end
		},
	}
}


newChat{ id="win",
	text = [[#LIGHT_GREEN#*The Cornac rogue comes back from the shadows*#WHITE#
Hehehe, well done, @playerdescriptor.race@! I knew you had potential.
#LIGHT_GREEN#*The rogue takes out his hood, showing a fairly young, but unmistakingly
#LIGHT_GREEN#battle-hardened man. He is smiling widely, but this time you can clearly
#LIGHT_GREEN#recognize satisfaction in his smile.#WHITE#
The name's Rej. I work for the arena to recruit great fighters who can give a good
show... and not die in two blows.
A promise is a promise. This envelope contains an invitation to the arena, and a map
with its location.
When you are done adventuring, I'd like to see you there.
#LIGHT_GREEN#*As you travel back to Derth in company of the rogue, you both talk about past
#LIGHT_GREEN#battles and techniques. His experience in combat inspires you greatly. (#WHITE#+2 generic talent points#LIGHT_GREEN#)
#WHITE#Very well, @playername@. I must go now. I need to meet with some fighters at
Zigur, not too far from here.
Come to the arena when you are done with your adventures, will you?.
]],
	answers = {
		{ "I will. Farewell for now.", action = function (self, player)
			local g = game.zone:makeEntityByName(game.level, "terrain", "SAND_UP_WILDERNESS")
			g.change_level = 1
			g.change_zone = "town-derth"
			g.name = "exit to Derth"
			game.zone:addEntity(game.level, g, "terrain", player.x, player.y)

			player.unused_generics = player.unused_generics + 2
			game:setAllowedBuild("campaign_arena", true)
			game.player:setQuestStatus("arena-unlock", engine.Quest.COMPLETED)
			world:gainAchievement("THE_ARENA", game.player)
		end
		},
	}
}

newChat{ id="ok",
	text = "#WHITE#I see... come back if you change your mind...",
	answers = {
		{ "See you."},
	}
}

return "welcome"
