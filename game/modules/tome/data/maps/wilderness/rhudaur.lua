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

quickEntity('M', {name='misty mountains', 	display='^', image="terrain/mountain.png", color=colors.UMBER, block_move=true})
quickEntity('W', {name='weather hills', 	display='^', image="terrain/mountain.png", color=colors.UMBER, block_move=true})
quickEntity('t', {name='Trallshaws', 		display='#', image="terrain/tree.png", color=colors.LIGHT_GREEN, block_move=true})
quickEntity('.', {name='plains', 		display='.', image="terrain/grass.png", color=colors.LIGHT_GREEN})
quickEntity('&', {name='Ettenmoors', 		display='^', image="terrain/hills.png", color=colors.LIGHT_UMBER})
quickEntity('_', {name='river', 		display='~', image="terrain/river.png", color={r=0, g=80, b=255}})

quickEntity('*', {name="Dunadan's Outpost", 			display='*', color={r=255, g=255, b=255}})
quickEntity('1', {name="Caves below the tower of Amon Sûl", 	display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="tower-amon-sul"})
quickEntity('2', {name="Ettenmoors's cavern", 			display='>', color={r=80, g=255, b=255}})
quickEntity('3', {name="Passageway into the Trollshaws", 	display='>', color={r=0, g=255, b=0}, change_level=1, change_zone="trollshaws"})

return {
[[W..........&&.....MM.]],
[[WW..........&&.....MM]],
[[WW...........2&&&...M]],
[[WW..............&&..M]],
[[WW1......*_________MM]],
[[WW.....___.........MM]],
[[W....._............MM]],
[[.....__..tt3t......MM]],
[[....__.ttttttt....MM.]],
[[...._....tttt....MMM.]],
}
