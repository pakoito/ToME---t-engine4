-- ToME - Tales of Maj'Eyal
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

------------------------------------------------------------
-- For inside the sea
------------------------------------------------------------

newEntity{
	define_as = "WATER_FLOOR",
	name = "underwater", image = "terrain/water_floor.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	air_level = -5, air_condition="water",
}
for i = 2, 20 do
newEntity{
	define_as = "WATER_FLOOR"..i,
	name = "underwater", image = "terrain/water_floor.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:mergeSubEntities(class:makeWater(true), class:makeShells("terrain/shell")),
	air_level = -5, air_condition="water",
}
end

newEntity{
	define_as = "WATER_WALL",
	name = "coral wall", image = "terrain/water_wall.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -5,
}
newEntity{
	define_as = "WATER_DOOR",
	name = "coral door", image = "terrain/granite_door1.png",
	display = '+', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	notice = true,
	always_remember = true,
	block_sight = true,
	door_opened = "WATER_DOOR_OPEN",
	dig = "WATER_DOOR_OPEN",
	air_level = -5, air_condition="water",
}
newEntity{
	define_as = "WATER_DOOR_OPEN",
	name = "open coral door", image = "terrain/granite_door1_open.png",
	display = "'", color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	always_remember = true,
	door_closed = "WATER_DOOR",
	air_level = -5, air_condition="water",
}

------------------------------------------------------------
-- For outside
------------------------------------------------------------

newEntity{
	define_as = "SHALLOW_WATER",
	name = "shallow water", image = "terrain/water_floor.png",
	display = '~', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(false),
	always_remember = true,
}

newEntity{
	define_as = "DEEP_WATER",
	name = "deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	always_remember = true,
	air_level = -5, air_condition="water",
}

newEntity{
	define_as = "POISON_SHALLOW_WATER",
	name = "poisoned shallow water", image = "terrain/water_floor.png",
	display = '~', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN,
	add_displays = class:makeWater(false, "poison_"),
	always_remember = true,
}

newEntity{
	define_as = "POISON_DEEP_WATER",
	name = "poisoned deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.YELLOW_GREEN, back_color=colors.DARK_GREEN,
	add_displays = class:makeWater(true, "poison_"),
	always_remember = true,
	air_level = -5, air_condition="water",
}
