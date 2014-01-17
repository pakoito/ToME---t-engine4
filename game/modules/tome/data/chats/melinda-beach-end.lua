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

newChat{ id="welcome",
	text = [[What just happened?!]],
	answers = {
		{"I'm sorry I didn't manage to protect you and as you were about to die you... fired a powerful wave of blight.", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[But I have never cast a spell in my life!]],
	answers = {
		{"You are still tainted by that ... foul Demon!  The taint is not all gone!", jump="next_am", cond=function(npc, player) return player:attr("forbid_arcane") end},
		{"There must be some of that demon's taint still inside you.", jump="next_notam", cond=function(npc, player) return not player:attr("forbid_arcane") end},
	}
}

newChat{ id="next_am",
	text = [[This is terrible! I assure you I had no idea this would happen.  You must trust me!]],
	answers = {
		{"I do.  The Ziguranth are not raving zealots, you know.  We will look for a way to cure you, as long as you reject the blight.", jump="next2"},
	}
}

newChat{ id="next_notam",
	text = [[This is terrible!  What is happening to me?!?  You must help me!]],
	answers = {
		{"I will.  We will find a cure for this together.", jump="next2"},
	}
}

newChat{ id="next2",
	text = [[I'm a very lucky girl, am I not... This is the second time I've had you to save me now.]],
	answers = {
		{"Over the last weeks you've become very important to me, and I am glad to have you.  This is certainly not the place to talk, though, let's go.", jump="next3"},
	}
}

newChat{ id="next3",
	text = [[You're right, let's get out of here.]],
	answers = {
		{"#LIGHT_GREEN#[go back to Last Hope]", action=function(npc, player)
			game:changeLevel(1, "town-last-hope", {direct_switch=true})
			player:move(25, 44, true)
		end},
	}
}

return "welcome"
