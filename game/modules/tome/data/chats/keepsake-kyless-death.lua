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

newChat{ id="kyless",
	text = [[#VIOLET#*Kyless lies dying on the floor. In his hand he holds a book.*#LAST#
Please! Before I die I have one request. Destroy the book. It wasn't me. The book brought this on us. It must be destoyed!]],
	answers = {
		{
			"I will. #LIGHT_GREEN#[destroy the book]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_good_choice(player)
			end,
			jump="destroy_book"
		},
		{
			"I'm sorry but I need it. #LIGHT_GREEN#[keep the book]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_evil_choice(player)
				player:hasQuest("keepsake"):on_keep_book(player)
			end,
			jump="keep_book"
		}
	}
}

newChat{ id="destroy_book",
	text = [[#VIOLET#*You destroy the book. When you finish you look up and see that Kyless is already dead.*#LAST#]],
	answers = {
		{"Goodbye, Kyless."},
	}
}

newChat{ id="keep_book",
	text = [[#VIOLET#*You place the book in your pack. When you finish you look up and see that Kyless is already dead.*#LAST#]],
	answers = {
		{"Goodbye, Kyless."},
	}
}

return "kyless"
