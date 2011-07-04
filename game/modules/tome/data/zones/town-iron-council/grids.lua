-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

load("/data/general/grids/basic.lua")
load("/data/general/grids/underground.lua")

for i = 1, 20 do
newEntity{
	define_as = "CRYSTAL_WALL"..(i > 1 and i or ""),
	type = "wall", subtype = "underground",
	name = "crystals",
	image = "terrain/oldstone_floor.png",
	add_displays = class:makeCrystals("terrain/crystal_alpha"),
	display = '#', color=colors.LIGHT_BLUE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	dig = "CRYSTAL_FLOOR",
}
end

newEntity{ base = "DOWN", define_as = "ESCAPE_REKNOR", name="Escape route from Reknor", change_zone="reknor-escape" }
newEntity{ base = "DOWN", define_as = "DEEP_BELLOW", name="The Deep Bellow", glow=true, change_zone="deep-bellow" }

newEntity{ define_as = "STATUE",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}},
	does_block_move = true,
	block_sight = true,
}
