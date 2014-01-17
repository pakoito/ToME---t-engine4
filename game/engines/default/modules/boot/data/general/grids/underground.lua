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

for i = 1, 20 do
newEntity{
	define_as = "CRYSTAL_WALL"..(i > 1 and i or ""),
	type = "wall", subtype = "underground",
	name = "crystals",
	image = "terrain/crystal_floor1.png",
	add_displays = class:makeCrystals("terrain/crystal_alpha"),
	display = '#', color=colors.LIGHT_BLUE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	dig = "CRYSTAL_FLOOR",
}
end

newEntity{
	define_as = "CRYSTAL_FLOOR",
	type = "floor", subtype = "underground",
	name = "floor", image = "terrain/crystal_floor1.png",
	display = '.', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	grow = "CRYSTAL_WALL",
	nice_tiler = { method="replace", base={"CRYSTAL_FLOOR", 100, 1, 8}},
}
for i = 1, 8 do newEntity{ base = "CRYSTAL_FLOOR", define_as = "CRYSTAL_FLOOR"..i, image = "terrain/crystal_floor"..i..".png"} end
