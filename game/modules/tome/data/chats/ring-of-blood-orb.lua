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
	text = [[#LIGHT_GREEN#*You place your hands on the orb.*#WHITE#
You must provide 150 gold to take part in the fight.]],
	answers = {
		{"[Pay 150 gold]", jump="pay",
			cond=function(npc, player)
				return player:hasQuest("ring-of-blood") and player:hasQuest("ring-of-blood"):find_master() and player.money >= 150
			end,
			action=function(npc, player) player:incMoney(-150) end
		},
		{"[Leave]"},
	}
}

newChat{ id="pay",
	text = [[Let the fight start!]],
	answers = {
		{"Bring it on!", action=function(npc, player) player:hasQuest("ring-of-blood"):start_game() end},
	}
}

return "welcome"
