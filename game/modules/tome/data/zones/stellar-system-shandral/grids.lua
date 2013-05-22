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

load("/data/general/grids/void.lua")

newEntity{ base = "VOID",
	define_as = "BLOCK",
	block_move = true,
	block_fortress = true,
}

class = require "mod.class.StellarBody"
newEntity{ base = "VOID",
	define_as = "CELESTIAL_BODY",
	image="invis.png",
	notice = true,
	block_move = true,
	always_remember = true,
	show_tooltip = true,
}

--------------------------------------------------------------------
-- STARS
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "SHANDRAL",
	name = "Shandral (Sun)",
	display = '*', color=colors.GOLD,
	desc = [[The sun of the Shandral star system.]],
	sphere_map = "stars/sun_surface.png",
	sphere_size = 8,
	x_rot = 20, y_rot = -20, rot_speed = 17000,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "EYAL",
	name = "Eyal (Planet)",
	display = 'O', color=colors.BLUE,
	desc = [[One of the main planet of the Shandral system.]],
	sphere_map = "stars/eyal.png",
	sphere_size = 1,
	x_rot = 30, y_rot = -30, rot_speed = 9000,
}

newEntity{ base = "CELESTIAL_BODY",
	define_as = "SUMMERTIDE",
	name = "Summertide (Moon of Eyal)",
	display = 'o', color=colors.GREY,
	desc = [[Moon of Eyal.]],
	sphere_map = "stars/moon1.png",
	sphere_size = 0.32,
	x_rot = 50, y_rot = -80, rot_speed = 5600,
}

newEntity{ base = "CELESTIAL_BODY",
	define_as = "WINTERTIDE",
	name = "Wintertide (Moon of Eyal)",
	display = 'o', color=colors.GREY,
	desc = [[Moon of Eyal.]],
	sphere_map = "stars/moon1.png",
	sphere_size = 0.32,
	x_rot = -50, y_rot = 20, rot_speed = 5600,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "KOLAL",
	name = "Kolal (Planet)",
	display = 'O', color=colors.BROWN,
	desc = [[One of the main planet of the Shandral system.]],
	sphere_map = "stars/kolal.png",
	sphere_size = 0.8,
	x_rot = 10, y_rot = -50, rot_speed = 4000,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "LUXAM",
	name = "Luxam (Planet)",
	display = 'O', color=colors.BROWN,
	desc = [[One of the main planet of the Shandral system.]],
	sphere_map = "stars/luxam.png",
	sphere_size = 1.3,
	x_rot = -90, y_rot = -20, rot_speed = 1000,
}
