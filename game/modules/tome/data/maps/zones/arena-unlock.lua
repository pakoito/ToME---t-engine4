-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

defineTile("#", "HARDWALL")
defineTile("+", "GENERIC_LEVER_DOOR")
defineTile(":", "GRASS", nil, nil, nil, {no_teleport=true, no_drop=true})
defineTile(".", "SAND")
defineTile("-", "FLOOR")
defineTile("_", "FLOOR", nil, nil, nil, {no_teleport=true, no_drop=true})
defineTile("T", "TREE", nil, nil, nil, {no_teleport=true, no_drop=true})

startx = 8
starty = 12

-- ASCII map section
return [[
:::::T:___::::T:T
:#######+#######:
:#...#.---.#...#:
:#.............#:
:#....#...#....#:
:##...........##T
:#.............#:
T#...#.....#...#:
:#.............#:
:##...........##:
:#....#...#....#:
:#.............#:
:#...#.---.#...#:
:#######+#######:
:::TT:T___T::::::]]
