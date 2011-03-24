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

defineTile('<', "GRASS_UP_WILDERNESS")
defineTile('t', {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
defineTile('~', "DEEP_WATER")
defineTile('.', "GRASS")
defineTile('-', "FIELDS")
defineTile('_', "COBBLESTONE")
defineTile(',', "SAND")
defineTile('!', "ROCK")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('=', "LAVA")
defineTile("?", "OLD_FLOOR")
defineTile(":", "FLOOR")
defineTile("&", "POST")
defineTile("'", "DOOR")

defineTile('2', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('1', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('4', "HARDWALL", nil, nil, "HERBALIST")
defineTile('9', "HARDWALL", nil, nil, "JEWELRY")

startx = 0
starty = 20

-- addSpot section
addSpot({29, 13}, "npc", "arena")
addSpot({21, 11}, "npc", "elemental")
addSpot({16, 16}, "npc", "elemental")
addSpot({12, 25}, "npc", "elemental")
addSpot({16, 32}, "npc", "elemental")
addSpot({23, 24}, "npc", "elemental")
addSpot({28, 32}, "npc", "elemental")
addSpot({26, 38}, "npc", "elemental")
addSpot({37, 30}, "npc", "elemental")
addSpot({32, 29}, "npc", "elemental")
addSpot({33, 37}, "npc", "elemental")
addSpot({33, 24}, "npc", "elemental")
addSpot({34, 15}, "npc", "elemental")
addSpot({37, 20}, "npc", "elemental")
addSpot({24, 18}, "npc", "elemental")
addSpot({28, 20}, "npc", "elemental")
addSpot({25, 13}, "npc", "elemental")
addSpot({22, 30}, "npc", "elemental")
addSpot({18, 36}, "npc", "elemental")
addSpot({12, 31}, "npc", "elemental")
addSpot({12, 31}, "npc", "elemental")

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
ttttttttttttttttttt~~~~~~~~~~ttttttttttttttttttttt
ttttttttttttttttt~~~~~~~~~~~~~~~tttttttttttttttttt
tttttttttttttttt~~~~~~~~~~~~~~~~~~tttttttttttttttt
ttttttttttttttt~~~~~ttttttt~~~~~~~~~tttttttttttttt
tttttttttttttt~~~~ttt.....tttttt~~~~~~tttttttttttt
ttttttttttttt~~~~tt............tt~~~~~~tttttttttt~
tttttttttttt~~~~tt..............ttt~~~~tttttttt~~~
tttttttttttt~~~tt.................ttt~~~tttttt~~~~
ttttttttttt~~~~t....................t~~~~ttt~~~~~~
ttttttttttt~~~tt..######....######...t~~~t~~~~~~~t
tttttttttt~~~~t...######....######...tt~~~~~~~~~~t
tttttttttt~~~tt...######....######....t~~~~~~~~ttt
tttttttttt~~~t....###4##.....___......tt~~~~~~tttt
tttttttttt~~tt......___......._........t~~~~tttttt
ttttttttt...t........_........_........t~~~ttttttt
<______________......_.......__........t~~~ttttttt
tttttttt...t.._____.___.....__..###....tt~~ttttttt
tttttttt~~~t......___._______...#9#.....t~~ttttttt
tttttttt~~~t.....__....._t_.....___.....t~~ttttttt
ttttttt~~~~t....__......___......_......t~~ttttttt
ttttttt~~~~t..___........_......__......t~~ttttttt
ttttttt~~~tt.__.........._......_.......t~~~tttttt
ttttttt~~~t.._.#####....._......_.###...t~~~tttttt
ttttttt~~~t.._.#####....._.####._.###...t~~~tttttt
ttttttt~~~t.._.#####....._.####._.###...t~~~tttttt
ttttttt~~~t.._.#5#2#....___####._.###...t~~~tttttt
ttttttt~~~t.._______..___._.._.._.###...t~~~tttttt
ttttttt~~~t......._..__..._______.###..tt~~~tttttt
ttttttt~~~tt......_.._.........._.._...t~~~ttttttt
tttttttt~~~tt.....____.####.....____...t~~~ttttttt
ttttttttt~~~tt......_..####....._......t~~~ttttttt
ttttttttt~~~~tt.....__.####....._.....tt~~~ttttttt
tttttttttt~~~~ttt....__#13#....._.....t~~~tttttttt
tttttttttttt~~~~tt....___________...tt~~~~tttttttt
ttttttttttttt~~~~ttttt............ttt~~~~ttttttttt
tttttttttttttt~~~~~~~ttttttt...tttt~~~~~~ttttttttt
tttttttttttttttt~~~~~~~~~~~ttttt~~~~~~~~tttttttttt
ttttttttttttttttttt~~~~~~~~~~~~~~~~~~~~ttttttttttt
ttttttttttttttttttttt~~~~~~~~~~~~~~~tttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttt]]