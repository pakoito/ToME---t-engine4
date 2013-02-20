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
	text = [[#LIGHT_GREEN#*He falls to his knees.*#WHITE#
Please spare me! I am pitiful. I will not stop you. Let me leave!]],
	answers = {
		{"No!", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = [[But, but, you were my... you...
You need me! What do you think you will do on the surface? Everything you will meet will try to destroy you.
You are strong but you cannot resist them all!]],
	answers = {
		{"So what do you propose?", jump="what"},
		{"[kill him]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("ARRGGggg... You are alone! You will be destroyed!", 60)
			npc:die(player)
		end},
	}
}

newChat{ id="what",
	text = [[I can give you a cloak that will conceal your true nature!
With it all people will see when they look at you is a normal average Human. You can go about your business.
Please!]],
	answers = {
		{"Thanks for the information. Now you may die. [kill him]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("ARRGGggg... You are alone! You will be destroyed!", 60)
			npc:die(player)
		end},
	}
}

return "welcome"
