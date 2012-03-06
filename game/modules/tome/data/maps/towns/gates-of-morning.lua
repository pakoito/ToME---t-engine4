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


-- defineTile section
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("#", "HARDWALL")
defineTile("m", "GOLDEN_MOUNTAIN")
defineTile("~", "DEEP_WATER")
defineTile(":", "DEEP_OCEAN_WATER")
defineTile("*", "SAND")
defineTile("_", "ROAD")
defineTile("p", "PALMTREE")
defineTile(".", "FLOOR")
defineTile("t", "TREE")
defineTile(" ", "GRASS")

defineTile('1', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('2', "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "MAUL_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "ARCHER_WEAPON_STORE")
defineTile('A', "HARDWALL", nil, nil, "STAFF_WEAPON_STORE")
defineTile('6', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('7', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile('9', "HARDWALL", nil, nil, "HERBALIST")
defineTile('0', "HARDWALL", nil, nil, "RUNES")

defineTile('Z', "HARDWALL", nil, nil, "ZEMEKKYS")

defineTile('@', "GRASS", nil, "HIGH_SUN_PALADIN_AERYN")
defineTile('j', "GRASS", nil, mod.class.NPC.new{
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.RED,
	name = "Limmir the Jeweler",
	size_category = 3, rank = 3,
	ai = "simple",
	faction = "sunwall",
	can_talk = "jewelry-store",
	can_quest = true,
})

defineTile('s', "FLOOR", nil, mod.class.NPC.new{
	type = "humanoid", subtype = "human",
	display = "p", color=colors.BLUE,
	name = "Melnela",
	female = true,
	size_category = 3, rank = 2,
	ai = "simple",
	faction = "sunwall",
	can_talk = "ardhungol-start",
	can_quest = true,
})

startx = 0
starty = 26

-- addSpot section
addSpot({42, 26}, "npc", "aeryn-main")
addSpot({43, 21}, "pop-quest", "farportal")
addSpot({43, 20}, "pop-quest", "farportal-npc")
addSpot({42, 21}, "pop-quest", "farportal-player")
addSpot({40, 30}, "pop-birth", "sunwall")
addSpot({42, 30}, "pop-birth", "slazish-fens")

-- addZone section

-- ASCII map section
return [[
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmm.........mmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmm..............mmmmmm..........mmmmmmm
mmmmmmmmmmmmm................mm..............mmmmm
mmmmmmmmmmmm.........................####.....mmmm
mmmmmmmmm............................####.....mmmm
mmmmmmmm.......###...................8#A#.....mmmm
mmmmmmmm......######................._._.....mmmmm
mmmmmmmm......######...#####....._______.....mmmmm
mmmmmmmm......##6###...#####..____....._....mmmmmm
mmmmmmmm........_......###7#.._.......__....mmmmmm
mmmmmmmm........_........._..__......._.....mmmmmm
mmmmmmm.........______________..#####._.....mmmmmm
mmmmmm.........._........._....#######_......mmmmm
mmmmmm.........._..####..._....#######_......mmmmm
mmmmm...###....__..#####.._..s..3#4#5#_..###..mmmm
mmmmm...###...._...#####.._......._____..#Z#..mmmm
mmmmm..#####..._...1#2#..._......__......._...mmmm
mmmmm..#0#9#..._...___....________......___....mmm
 mmmm...___....______.....__...._......__......mmm
 mmm....._....._.........._.....________........mm
  mm.....___..__.........._..........._.........mm
   mm......____..........._..........._........mmm
   mm...#..._..#......#..._.#.....#..._.#......mmm
<  _@_________________________________________mmmm
   mm...#......#......#..._.#.....#.....#....mmmmm
   mm....................__.................mmmmmm
m mmm...................._.................mmmmmmm
mmmm....................__.................mmmmmmm
mmmm.................  ._..................mmmmmmm
mmmm.........ttt.               ...........mmmmmmm
mmmm...tttttttt                             mmmmmm
mmmm.ttttttttt                              mmmmmm
mmmmtt                          ******       mmmmm
mmmmt       ~~~~              ****pp*******  mmmmm
mmmm       ~~~~~~            ****************mmmmm
mmmm       ~~~~~~ttt j       *p********p*****mmmmm
mmmmm       ~~~~~ttt        ***********p**p**mmmmm
mmmmmm     tt~~~~tt         *****p**p********mmmmm
mmmmmm    ttt~~~           **p***************mmmmm
mmmmm    ttt~~~            ******************mmmmm
mmmmm    ttt~~            *****:::::::*******mmmmm
mmmmm       ~             ****:::::::::::::*mmmmmm
mmmmmmm     ~            ***:::::::::::::::mmmmmmm
mmmmmmm  ~~~~ mmmm     ****:::::::::::::::mmmmmmmm
mmmmmm~~~~~mmmmmmmm    **mmmmm::::::::::mmmmmmmmmm
mmmmmm~mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmm~mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm]]
