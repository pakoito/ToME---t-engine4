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
	text = [[#LIGHT_GREEN#*Before you stands a cute little orange cat. It looks hungry and looks at you.*#WHITE#
Meowww?
]],
	answers = {
		{"Oh kitty kitty!", jump="kitty"},
		{"No time for cats!"},
	}
}

newChat{ id="kitty",
	text = [[#LIGHT_GREEN#*It rubs up against your leg and purrs.*#WHITE#
Rrrrrrrrrrrr.
]],
	answers = {
		{"Hey maybe you would like some of this delicious lookin troll intestines? #LIGHT_GREEN#[Feed him the intestines]#WHITE#", jump="pet", cond=function(npc, player) return game.party:hasIngredient("TROLL_INTESTINE") end},
		{"Sorry little fellow, I can't help you."},		
	}
}

newChat{ id="pet",
	text = [[#LIGHT_GREEN#*It eats it all and looks happy. After a while it strolls away. Somehow you feel you have not seen the last of it.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[Leave]", action=function(npc, player)
			game.state.kitty_fed = true
		end},		
	}
}

return "welcome"
