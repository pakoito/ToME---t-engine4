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

setStatusAll{no_teleport=true}

quickEntity('^', {show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_BLUE, image="terrain/mountain.png", block_move=true, block_sight=true})
quickEntity('<', {show_tooltip=true, name='portal back', display='<', color=colors.WHITE, change_level=1, change_zone=game.player.last_wilderness, image="terrain/sand.png", add_displays = {mod.class.Grid.new{image="terrain/worldmap.png"}}}, nil, {type="portal", subtype="back"})
defineTile('t', {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
quickEntity('~', {show_tooltip=true, name='lake', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png", shader = "water", textures = { function() return _3DNoise, true end }})
quickEntity('.', {show_tooltip=true, name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('-', {show_tooltip=true, name='cultivated fields', display=';', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/cultivation.png", equilibrium_level=-10})
quickEntity('_', {show_tooltip=true, name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(',', {show_tooltip=true, name='sand', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10}, {no_teleport=true})
quickEntity('!', {show_tooltip=true, name='giant rock', display='#', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY, always_remember = true, does_block_move = true, block_sight = true, air_level = -20, image="terrain/maze_rock.png"})
quickEntity('#', {show_tooltip=true, name='wall', display='#', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY, always_remember = true, does_block_move = true, block_sight = true, air_level = -20, image="terrain/bigwall.png"})
quickEntity('+', {show_tooltip=true, name='closed door', display='+', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY, always_remember = true, does_block_move = true, block_sight = true, air_level = -20, image="terrain/stone_store_closed.png"})
quickEntity('=', {show_tooltip=true, name='lava pit', display='~', color=colors.LIGHT_RED, back_color=colors.RED, always_remember = true, does_block_move = true, image="terrain/lava_floor.png"})
defineTile("?", "OLD_FLOOR")
defineTile(":", "FLOOR")
defineTile("@", "FLOOR", nil, "PROTECTOR_MYSSIL")
quickEntity("'", {show_tooltip=true, name="Open gates", display="'", color=colors.UMBER, image="terrain/stone_store_open.png"})

quickEntity('1', {show_tooltip=true, name="Trainer", display='1', color=colors.UMBER, chat_faction="zigur", resolvers.chatfeature("zigur-trainer", "zigur"), image="terrain/stone_store_training.png"})
quickEntity('2', {show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, store_faction="zigur", resolvers.store("ARMOR", "zigur"), image="terrain/stone_store_armor.png"})
quickEntity('3', {show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, store_faction="zigur", resolvers.store("WEAPON", "zigur"), image="terrain/stone_store_weapon.png"})

startx = 24
starty = 49
endx = 24
endy = 49

-- addSpot section
addSpot({32, 7}, "portal", "portal")
addSpot({39, 8}, "portal", "portal")
addSpot({38, 15}, "portal", "portal")
addSpot({32, 15}, "portal", "portal")
addSpot({35, 11}, "quest", "arena")
addSpot({28, 12}, "quest", "outside-arena")
addSpot({15, 31}, "arrival", "rhaloren")
addSpot({16, 31}, "arrival", "rhaloren")
addSpot({17, 31}, "arrival", "rhaloren")
addSpot({18, 31}, "arrival", "rhaloren")
addSpot({19, 31}, "arrival", "rhaloren")
addSpot({20, 31}, "arrival", "rhaloren")
addSpot({15, 32}, "arrival", "rhaloren")
addSpot({16, 32}, "arrival", "rhaloren")
addSpot({17, 32}, "arrival", "rhaloren")
addSpot({18, 32}, "arrival", "rhaloren")
addSpot({19, 32}, "arrival", "rhaloren")
addSpot({20, 32}, "arrival", "rhaloren")
addSpot({15, 33}, "arrival", "rhaloren")
addSpot({16, 33}, "arrival", "rhaloren")
addSpot({17, 33}, "arrival", "rhaloren")
addSpot({18, 33}, "arrival", "rhaloren")
addSpot({19, 33}, "arrival", "rhaloren")
addSpot({20, 33}, "arrival", "rhaloren")
addSpot({15, 34}, "arrival", "rhaloren")
addSpot({16, 34}, "arrival", "rhaloren")
addSpot({17, 34}, "arrival", "rhaloren")
addSpot({18, 34}, "arrival", "rhaloren")
addSpot({19, 34}, "arrival", "rhaloren")
addSpot({20, 34}, "arrival", "rhaloren")
addSpot({15, 35}, "arrival", "rhaloren")
addSpot({16, 35}, "arrival", "rhaloren")
addSpot({17, 35}, "arrival", "rhaloren")
addSpot({18, 35}, "arrival", "rhaloren")
addSpot({19, 35}, "arrival", "rhaloren")
addSpot({20, 35}, "arrival", "rhaloren")
addSpot({28, 16}, "arrival", "ziguranth")
addSpot({29, 16}, "arrival", "ziguranth")
addSpot({28, 17}, "arrival", "ziguranth")
addSpot({29, 17}, "arrival", "ziguranth")
addSpot({24, 7}, "arrival", "ziguranth")
addSpot({25, 7}, "arrival", "ziguranth")
addSpot({24, 8}, "arrival", "ziguranth")
addSpot({25, 8}, "arrival", "ziguranth")
addSpot({9, 13}, "arrival", "ziguranth")
addSpot({10, 13}, "arrival", "ziguranth")
addSpot({9, 14}, "arrival", "ziguranth")
addSpot({10, 14}, "arrival", "ziguranth")
addSpot({10, 30}, "arrival", "ziguranth")
addSpot({11, 30}, "arrival", "ziguranth")
addSpot({10, 31}, "arrival", "ziguranth")
addSpot({11, 31}, "arrival", "ziguranth")
addSpot({18, 21}, "arrival", "ziguranth")
addSpot({19, 21}, "arrival", "ziguranth")
addSpot({18, 22}, "arrival", "ziguranth")
addSpot({19, 22}, "arrival", "ziguranth")
addSpot({29, 35}, "arrival", "ziguranth")
addSpot({30, 35}, "arrival", "ziguranth")
addSpot({29, 36}, "arrival", "ziguranth")
addSpot({30, 36}, "arrival", "ziguranth")
addSpot({31, 23}, "arrival", "ziguranth")
addSpot({32, 23}, "arrival", "ziguranth")
addSpot({31, 24}, "arrival", "ziguranth")
addSpot({32, 24}, "arrival", "ziguranth")

-- addZone section

-- ASCII map section
return [[
~~~~~~~~~~~~~~~~~~~~~~~~~ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~~~ttttttttttt..tttttttttttt
~~~~~~~~~~~~~..........~~tt###............tttttttt
~~~~~~~~~~~..............tt###.............ttttttt
~~~~~~~~~~.....#########...###..............tttttt
~~~~~~~~.......#:::@:::#...###..========.....ttttt
~~~~~~~~.......#:::::::#...#1#.==??????==....##ttt
~~~~~~~tt......#:##'##:#......==????????==...##ttt
~~~~~~ttt......#:#._.#:#......=??!!??????=...###tt
~~~~~tttt......###._.###.....==??????????==..####t
~~~~~ttt..........._.........=????????????=..###tt
~~~~tttt........._____.......=????????????==.+#ttt
~~~tttt.........._ttt_....___=??????????!??=...ttt
~~~ttttt........._ttt_..___..=?????????!???=...ttt
~~...ttt.........________....==???!???????==...ttt
~~..............._ttt_........=???????????=.....tt
~~~.............._ttt_........===???????===.....tt
~~~~~............_____..........=========.......tt
~~~.............................................tt
~~~..........................######............ttt
~~~..........................######............ttt
~~~~,........................##3###...........tttt
~~~~,,,.....................................tttttt
~~~~,,,,..................................tttttttt
~~~~~~,,,,...............................ttttttttt
~~~~~~~~,,,.............tt###2##....tt..tttttttttt
~~~~~~~~~,,............ttt######.....t.ttttttttttt
~~~~~~~~~,,,............ttt#####.......ttttttttttt
~~~~~~~~~,,,,...........tttt####........tttttttttt
~~~~~~~~~~,,,.............ttt...........tttttttttt
~~~~~~~~~~,,,,..............t...........tttttttttt
~~~~~~~~~~,,,,..........................tttttttttt
~~~~~~~~~~,,,,,..........................ttttttttt
~~~~~~~~~~~,,,,,...........................ttttttt
~~~~~~~~~~~,,,,,,,...........................ttttt
~~~~~~~~~~~~,,,,,,,...........................tttt
~~~~~~~~~~~~~,,,,,,,,,....................-----ttt
~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,..........------tt
~~~~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,.........------.t
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,........------.t
~~~~~~~~~~~~~~~~~~~~~~~,,,~~~~~~~,........------.t
~~~~~~~~~~~~~~~~~~~~~~,,t,,~~~~~~,t.......------.t
~~~~~~~~~~~~~~~~~~~~~~,ttt,,~~~~~,tt......------tt
~~~~~~~~~~~~~~~~~~~~~~,tttt,,,~,,,ttt.....------tt
~~~~~~~~~~~~~~~~~~~~~~,tttttt,,,tttttttt..------tt
~~~~~~~~~~~~~~~~~~~~~~,,tttttttttttttttttt-----ttt
~~~~~~~~~~~~~~~~~~~~~~~,,tttttttttttttttttttt..ttt
~~~~~~~~~~~~~~~~~~~~~~~~,ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~~,ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~~<ttttttttttttttttttttttttt]]
