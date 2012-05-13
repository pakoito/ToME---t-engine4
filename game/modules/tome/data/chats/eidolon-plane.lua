-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	text = [[#LIGHT_GREEN#*Before you stands an humanoid shape filled with 'nothing'. It seems to stare at you.*#WHITE#
I have brought you here on the instant of your death. I am the Eidolon.
I have deemed you worthy of my 'interest'. I will watch your future steps with interest.
You may rest here, and when you are ready I will send you back to the material plane.
But do not abuse my help. I am not your servant, and someday I might just let you die.
As for your probable many questions, they will stay unanswered. I may help, but I am not here to explain why.]],
	answers = {
		{"Thank you. I will rest for a while."},
		{"Thank you. I am ready to go back!", action=function() game.level.data.eidolon_exit(false) end},
		{"Thank you, but I fear I will not survive anyway, can you send me back somewhere else please?",
			cond=function() return not game.level.source_level.data or not game.level.source_level.data.no_worldport end,
			action=function() game.level.data.eidolon_exit(true) end
		},
		{"Thank you, but I am weary of this life, I wish no more, please let me go.", jump="die"},
	}
}

newChat{ id="die",
	text = [[#LIGHT_GREEN#*It seems to stare at you in weird way.*#WHITE#
I...had plans for you, but I can not go against your free will. Know that you had a destiny waiting for you.
Are you sure?]],
	answers = {
		{"Just let me go please.", action=function(npc, player) game:getPlayer(true):die(game.player) end},
		{"No actually, perhaps life is still worth it!"},
	}
}

return "welcome"
