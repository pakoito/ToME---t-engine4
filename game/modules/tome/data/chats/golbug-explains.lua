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
	text = [[#VIOLET#*As you open the door you notice a huge orc in the distance, covered in both flames and ice.*#LAST#
@playerdescriptor.race@! You should never have come, your doom awaits!
The Orc Pride will never yield to anybody, they have their precious and there is nothing you can do.]],
	answers = {
		{"The Orc Pride obeys to a master? Yes .. 'pride' indeed!", jump="mock"},
		{"#LIGHT_GREEN#[Attack]"},
	}
}

newChat{ id="mock",
	text = [[The Pride chooses its allies, it has no master! ATTACK!]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

return "welcome"
