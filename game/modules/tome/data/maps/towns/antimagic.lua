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

-- defineTile section
defineTile("#", "WALL")
defineTile("+", "DOOR")
quickEntity(',', {name='grass', display='.', color=colors.LIGHT_GREEN, does_block_move = true, back_color={r=44,g=95,b=43}, image="terrain/grass.png"})
defineTile(".", "FLOOR")
defineTile(" ", "OLD_FLOOR")
defineTile('T', {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
quickEntity('!', {name='giant rock', display='#', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY, always_remember = true, does_block_move = true, block_sight = true, air_level = -20, image="terrain/maze_rock.png"})

-- addSpot section
addSpot({7, 16}, "portal", "portal")
addSpot({7, 7}, "portal", "portal")
addSpot({14, 9}, "portal", "portal")
addSpot({13, 15}, "portal", "portal")

startx = 10
starty = 11

-- ASCII map section
return [[
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTT,,TTTTTTTTTTTT
TT####,,,,,,,,,,,TTTTTTTT
TT#..#,,,,,,,,,,,,TTTTTTT
TT#..#,,,,,,,,,,,,,TTTTTT
TT#.##,,,,,,,,,,,,,,TTTTT
TT#+#,,       ,,,,,###TTT
TT,,,,          ,,,#.#TTT
T,,,,   !!       ,,+.#,TT
T,,,,            ,,#.#,,T
T,,,              ,#.#,TT
TT,,              ,###TTT
T,,,              ,,,,TTT
T,,,,           ! ,,,,TTT
TT,,,           ! ,,,,TTT
TT,,,,   !        ,,,,,TT
TT,,,,,          ,,,,,,TT
TTT,,,,,      ,,,,,,,,,TT
TT,,####,,,,,,,,,,,,,,,TT
TT,,#..###,,,,,,,,,,,,TTT
TTT,#....+,,,,,,,,,,,,TTT
TTTT######,,T,,,,,,,,TTTT
TTTTTTTT,,,TT,,,,,,TTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTT]]
