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
	text = [[@playername@, I am one of a party of Sun Paladins sent by Aeryn. We arrived here tracking the orcs.
They have gone through the portal, and a few of my friends were pulled in with them.
We captured an orc earlier.  He revealed that the staff you seek is to be used to absorb the power of a remote place for dark rituals.
You must traverse this portal, if you have any means to, and stop the orcs.]],
	answers = {
		{"I think I can use the portal. Do not worry!"},
	}
}

return "welcome"
