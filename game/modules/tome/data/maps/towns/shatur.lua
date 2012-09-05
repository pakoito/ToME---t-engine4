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

defineTile('<', "GRASS_UP_WILDERNESS")
defineTile('t', "TREE")
defineTile('s', {"ROCKY_SNOWY_TREE","ROCKY_SNOWY_TREE2","ROCKY_SNOWY_TREE3","ROCKY_SNOWY_TREE4","ROCKY_SNOWY_TREE5","ROCKY_SNOWY_TREE6","ROCKY_SNOWY_TREE7","ROCKY_SNOWY_TREE8","ROCKY_SNOWY_TREE9","ROCKY_SNOWY_TREE10","ROCKY_SNOWY_TREE11","ROCKY_SNOWY_TREE12","ROCKY_SNOWY_TREE13","ROCKY_SNOWY_TREE14","ROCKY_SNOWY_TREE15","ROCKY_SNOWY_TREE16","ROCKY_SNOWY_TREE17","ROCKY_SNOWY_TREE18","ROCKY_SNOWY_TREE19","ROCKY_SNOWY_TREE20"})
defineTile('-', "ROCKY_GROUND")
defineTile('~', "DEEP_WATER")
defineTile('.', "GRASS")
defineTile('_', "COBBLESTONE")

quickEntity('@', {show_tooltip=true, name="Moss covered statue", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue3.png"}}, color=colors.GREEN, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("thaloren-lament") end return true end})

defineTile('2', "ROCKY_GROUND", nil, nil, "SWORD_WEAPON_STORE")
defineTile('3', "ROCKY_GROUND", nil, nil, "MAUL_WEAPON_STORE")
defineTile('4', "ROCKY_GROUND", nil, nil, "ARCHER_WEAPON_STORE")
defineTile('5', "GRASS", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('6', "GRASS", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('7', "GRASS", nil, nil, "HERBALIST")
defineTile('9', "GRASS", nil, nil, "MINDSTAR")

startx = 30
starty = 49

-- addSpot section

-- addZone section

-- ASCII map section
return [[
ssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssss-4-sssss-3--ssssssssssssssssss
sssssssssssssssssssss--ssssss----sssssssssssssssss
sssssssssssssssssssss---sssss----sssssssssssssssss
ssssssssssssssssssssss----sss----sssssssssssssssss
sssssssssssss-2--ssssss---ss--ssssssssssssssssssss
ssssssssssssss----sssssss-ss-sssssssssssssssssssss
ssssssssssssssss----sssss----sssssssssssssssssssss
sssssssssssssssss---sssss----ssssssss--sssssssssss
ssssssssssssssss----------ss-sssssss--ssssssssssss
sssssssssssssss----ssss--sss-sssssss-sssssssssssss
ssssssssssssss----sssss--ssss--------sssssssssssss
ssssssssssssssssssssssss--ssssssssss--ssssssssssss
ssssssssssssssssssssssss--sssssssssss---ssssssssss
sssssssssssssssssssss~~~__~ssssssssssss--sssssssss
sssssssssssssssss~~~~~~~__~~~~ssssssssssssssssssss
~~~~~~~ssssssss~~~~~~~~~__~~~~~~~~~sssssssssssssss
~~~~~~~~~~sss~~~~~~~~~~~__~~~~~~~~~~~~ssssssssssss
~~~~~~~~~~~~~~~~~~~~~~~~__~~~~~~~~~~~~~sssssssssss
~~~~~~~~~~~~~~~~~~~~~~tt..tt~~~~~~~~~~~~~~ssssss~~
~~~~~~~~~~~~~~~~tttttttt..tttttt~~~~~~~~~~~~~~~~~~
~ttttt~~~~~~~ttttttttttt..tttttttt~~~~~~~~~~~~~~~~
tttttttttttttttttttttttt..tttttttttt~~~~~~~~~~~~~~
ttttttttttttttttttttttt...ttttttttttttt~~~~~~~~~~~
ttttttttttttt.5.ttttttt.....tttt.7.tttttt~~~~~~~~~
ttttttttttttt.....tttt...@..t......ttttttttttttttt
ttttttttttttttttt.............tttttttttttttttttttt
ttttttttttttttttttt...t......ttttttttttttttttttttt
ttttttttttttttttttttttt.......tttttttttttttttttttt
tttttttttttttttttttttt....ttt..ttttttttttttttttttt
ttttttttttttttttttttt..tt.ttt....ttttttttttttttttt
ttttttttttttttttttttt..tt.ttt.....tttttttttttttttt
ttttttttttttttttttt....tt..tttt.....9.tttttttttttt
ttttttttttttt.6.......tttt.tttttt.....tttttttttttt
ttttttttttttt........ttttt.ttttttttttttttttttttttt
tttttttttttttttttttttttttt.ttttttttttttttttttttttt
tttttttttttttttttttttttttt..tttttttttttttttttttttt
ttttttttttttttttttttttttttt.tttttttttttttttttttttt
ttttttttttttttttttttttttttt..ttttttttttttttttttttt
tttttttttttttttttttttttttttt.ttttttttttttttttttttt
tttttttttttttttttttttttttttt..tttttttttttttttttttt
ttttttttttttttttttttttttttttt.tttttttttttttttttttt
ttttttttttttttttttttttttttttt..ttttttttttttttttttt
tttttttttttttttttttttttttttttt.ttttttttttttttttttt
tttttttttttttttttttttttttttttt.ttttttttttttttttttt
tttttttttttttttttttttttttttttt<ttttttttttttttttttt]]
