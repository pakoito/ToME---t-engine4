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
	text = [[Thank you, @playername@. I hate to admit it, but you saved my life.]],
	answers = {
		{"At your service. But may I ask what you were doing in this dark place?", jump="what"},
		{"It was only natural, my lady."},
	}
}

newChat{ id="what",
	text = [[I am an Anorithil, a mage of the Sun and Moon; we fight all that is evil. I was with a group of sun paladins; we came from the Gates of Morning to the east.
My companions were ... were slaughtered by orcs, and I nearly died as well. Thank you again for your help.]],
	answers = {
		{"It was only natural, my lady.", action=function(npc, player) game:setAllowedBuild("divine") game:setAllowedBuild("divine_anorithil", true) end},
	}
}

return "welcome"
