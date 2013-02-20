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

newChat{ id="ambush",
	text = [[#VIOLET#*As you come out of the Dreadfell, you encounter a band of orcs*#LAST#
You! Give us the staff NOW and we might offer you a quick death!]],
	answers = {
		{"What are you talking about?", jump="what"},
		{"Why would you want it?", jump="why"},
		{"#LIGHT_GREEN#[Attack]"},
	}
}

newChat{ id="what",
	text = [[Do not play dumb with Ukruk! ATTACK!]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

newChat{ id="why",
	text = [[That is not your concern! ATTACK!]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

return "ambush"
