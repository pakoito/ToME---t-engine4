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

defineTile("#", "WALL")
defineTile("+", "LOCK")
quickEntity(':', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
defineTile(".", "SAND")
defineTile("-", "FLOOR")
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha1.png"}}})

startx = 8
starty = 12

-- ASCII map section
return [[
:.:::T:::.::::T:T
:#######+#######:
:#...#.....#...#:
:#.............#.
:#....#...#....#:
.##...........##T
:#.............#:
T#...#.....#...#:
.#.............#:
:##...........##:
:#....#...#....#:
:#.............#.
:#...#..:..#...#:
:#######+#######:
:::TT:T:::T:.::.:
]]
