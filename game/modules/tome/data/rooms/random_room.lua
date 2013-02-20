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

local list = {
	"simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple", "simple",
	"pilar", "oval","s","cells","inner_checkerboard","y","inner","small_inner_cross","small_cross","big_cells","cells2","inner_cross","cells3","cells4","cells5","cells6","cross","equal2","pilar2","cells7","cells8","double_y","equal","center_arrows","h","pilar_big",
	"big_cross", "broken_room", "cells9", "double_helix", "inner_fort", "multi_pillar", "split2", "womb", "big_inner_circle", "broken_x", "circle_cross", "inner_circle2", "inner_pillar", "small_x", "weird1", "xroads", "broken_infinity", "cells10", "cross_circled", "inner_circle", "micro_pillar", "split1", "weird2",
	"basic_cell", "circular", "cross_quartet", "double_t", "five_blocks", "five_pillars", "five_walls", "four_blocks", "four_chambers", "hollow_cross", "interstice", "long_hall", "long_hall2", "narrow_spiral", "nine_chambers", "sideways_s", "side_passages_2", "side_passages_4", "spiral_cell", "thick_n", "thick_wall", "tiny_pillars", "two_domes", "two_passages", "zigzag",
}

-- Load a random normal room file and use it
return function(gen, id, lev, old_lev)
	local roomfile = rng.table(gen.data.random_rooms_list or list)
	local room = gen:loadRoom(roomfile)
	-- If this is a function, we can just return the room's method
	if type(room) == "function" then return room(gen, id, lev, old_lev)
	else return room end
end
