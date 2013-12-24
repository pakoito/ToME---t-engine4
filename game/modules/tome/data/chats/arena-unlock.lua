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
	text = [[#LIGHT_GREEN#*A tall, hooded man stares at you*#WHITE#
Yes...yes...you look like a promising warrior indeed...
I have an offer, @playerdescriptor.race@.
You see...I am an agent for the Arena. I look for promising warriors that
can provide a good show for our audience. Perhaps you are strong enough to join.
All you need to do is beat three of my men in battle, and you shall be rewarded.
#LIGHT_GREEN#*You consider the offer of the mysterious hooded man for a moment*
]],
	answers = {
		{"Interesting. Tell me more about that Arena.", jump="more_ex",
			action = function (self, player) self.talked_to = 1 end,
			cond=function(npc, player) return not profile.mod.allow_build.campaign_arena end},
		{"I am strong! What do you have to offer?", jump="more",
			action = function (self, player) self.talked_to = 1 end,
			cond=function(npc, player) return profile.mod.allow_build.campaign_arena end},
		{"I don't accept deals from shady hooded men.", jump="refuse",
		action = function (self, player) self.talked_to = 1 end},
	}
}

newChat{ id="more",
	text = [[#LIGHT_GREEN#*You can feel the man smiling from inside his hood*#WHITE#
I have wealth and glory to offer, and some very useful
#YELLOW#combat experience#WHITE# from fighting our men...
So, what do you think? Are you up to it?
]],
	answers = {
		{"I am ready for battle. Let's go!", jump="accept", action = function (self, player) self.talked_to = 2 end },
		{"I don't have time for games, Cornac.", jump="refuse"},
	}
}

newChat{ id="more_ex",
	text = [[#LIGHT_GREEN#*You can feel the man smiling from inside his hood*#WHITE#
The Arena is where the brave come to fight against all odds.
We are still growing up, and we lack challengers...
It's like a gamble, but you use your fighting instead of money to play, you see?
We in the Arena work hard to make a good show, and in return...you can get enough
wealth and glory to last for centuries!
If you can pass my little test...I will #LIGHT_RED#allow you to join the Arena when
you are done with your adventures.#WHITE#
You also shall gather some much needed #LIGHT_RED#combat experience#WHITE# from fighting
our men...so, what do you think? Are you up to it?
]],
	answers = {
		{"I am ready for battle. Let's go!", jump="accept", action = function (self, player) self.talked_to = 2 end },
		{"I don't have time for games, Cornac.", jump="refuse"},
	}
}

newChat{ id="refuse",
	text = [[#LIGHT_GREEN#*The man lets out a disappointed sigh*#WHITE#
That's unfortunate. We could have used someone like you.
You are just the type the audience likes. You could have been a champion.
Alas, if you stand by your choice, we shall never meet again.
However, if you change your mind...I will #YELLOW#stay in Derth just a little
longer.#WHITE#
If I am still around, we can have a deal. Think about it, @playerdescriptor.race@.
]],
	answers = {
		{"We'll see. [Leave]"},
	}
}

newChat{ id="accept",
	text = [[#LIGHT_GREEN#*The man smiles in approval*#WHITE#
Excellent! A great fighter is always willing to head into battle.
You certainly won't regret meeting us, indeed...
So, are you ready to fight?
]],
	answers = {
		{"Sounds like fun. I'm ready!", jump="go"},
		{"Wait. I am not ready yet.", jump="ok"},
	}
}

newChat{ id="go",
	text = "#LIGHT_GREEN#*The man quietly walks away, after making you a gesture to follow him*",
	answers = {
		{"[Follow him]",
		action = function (self, player)
			self:die()
			player:grantQuest("arena-unlock")
			game:changeLevel(1, "arena-unlock", {direct_switch=true})
			require("engine.ui.Dialog"):simpleLongPopup("Get ready!", "Defeat all three enemies!", 400)
		end
		},
	}
}


newChat{ id="win",
	text = [[#LIGHT_GREEN#*The Cornac rogue comes back from the shadows*#WHITE#
Well done, @playerdescriptor.race@! I knew you had potential.
#LIGHT_GREEN#*The rogue takes off his hood, showing a fairly young, but unmistakably
#LIGHT_GREEN#battle-hardened man.#WHITE#
The name's Rej. I work for the arena to recruit great fighters who can give a
good show... and not die in two blows. You are one of those, indeed!
I won't keep you away from your adventures. I was there too, long ago.
But we can make you a true champion, beloved by many and bathing in diamonds.

#LIGHT_GREEN#*As you travel back to Derth in company of the rogue, you discuss your
#LIGHT_GREEN#battles in the forest. He provides you with great insight on your combat technique (#WHITE#+2 generic talent points#LIGHT_GREEN#)*
#WHITE#Very well, @playername@. I must go now.
Good luck in your adventures, and come visit us when you are done!
]],
	answers = {
		{ "I will. Farewell for now.", action = function (self, player) game:onLevelLoad("arena-unlock-1", function()
			local g = game.zone:makeEntityByName(game.level, "terrain", "SAND_UP_WILDERNESS")
			g.change_level = 1
			g.change_zone = "town-derth"
			g.name = "exit to Derth"
			game.zone:addEntity(game.level, g, "terrain", player.x, player.y)

			game.party:reward("Select the party member to receive the +2 generic talent points:", function(player)
				player.unused_generics = player.unused_generics + 2
			end)
			game:setAllowedBuild("campaign_arena", true)
			game.player:setQuestStatus("arena-unlock", engine.Quest.COMPLETED)
			world:gainAchievement("THE_ARENA", game.player)
		end) end},
	}
}

newChat{ id="ok",
	text = "#WHITE#I see. I will be waiting... #YELLOW#But not for long.",
	answers = {
		{ "See you."},
	}
}

newChat{ id="back",
	text = [[#LIGHT_GREEN#*The Cornac rogue displays a welcoming smile*#WHITE#
Welcome back, @playerdescriptor.race@. Have you reconsidered my generous offer?
]],
	answers = {
		{ "Yes, tell me more.", jump = "accept", action = function (self, player) self.talked_to = 2 end },
		{ "No, see you."},
	}
}

newChat{ id="back2",
	text = [[
Welcome back, @playerdescriptor.race@. Are you ready to go?
]],
	answers = {
		{ "Let's go, Cornac.", jump = "go" },
		{ "Just a minute. I have to prepare my equipment."},
	}
}

if npc.talked_to then
	if npc.talked_to == 1 then return "back"
	elseif npc.talked_to >= 2 then return "back2"
	end
else return "welcome" end
