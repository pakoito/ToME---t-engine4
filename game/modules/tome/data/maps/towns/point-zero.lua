-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

defineTile('<', "RIFT")

defineTile("1", "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile('2', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "ARCHER_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "STAFF_WEAPON_STORE")
defineTile('6', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('7', "HARDWALL", nil, nil, "RUNEMASTER")
defineTile('8', "HARDWALL", nil, nil, "JEWELRY")

defineTile("~", "DEEP_WATER")
defineTile("*", "OUTERSPACE")
defineTile("^", "HARDMOUNTAIN_WALL")
defineTile("-", "FLOATING_ROCKS")
defineTile("t", "TREE")
defineTile("s", "COLD_FOREST")
defineTile(".", "GRASS")
defineTile("=", "SPACETIME_RIFT")
defineTile("_", "VOID")
defineTile("#", "HARDWALL")
defineTile("Z", "VOID", nil, "ZEMEKKYS")

startx = 24
starty = 29

-- addSpot section
addSpot({1, 2}, "pop", "foes")
addSpot({2, 2}, "pop", "foes")
addSpot({1, 3}, "pop", "foes")
addSpot({2, 3}, "pop", "foes")
addSpot({1, 4}, "pop", "foes")
addSpot({2, 4}, "pop", "foes")
addSpot({1, 5}, "pop", "foes")
addSpot({2, 5}, "pop", "foes")
addSpot({1, 6}, "pop", "foes")
addSpot({2, 6}, "pop", "foes")
addSpot({1, 7}, "pop", "foes")
addSpot({2, 7}, "pop", "foes")
addSpot({1, 8}, "pop", "foes")
addSpot({2, 8}, "pop", "foes")
addSpot({1, 9}, "pop", "foes")
addSpot({2, 9}, "pop", "foes")
addSpot({47, 31}, "pop", "foes")
addSpot({48, 31}, "pop", "foes")
addSpot({47, 32}, "pop", "foes")
addSpot({48, 32}, "pop", "foes")
addSpot({47, 33}, "pop", "foes")
addSpot({48, 33}, "pop", "foes")
addSpot({47, 34}, "pop", "foes")
addSpot({48, 34}, "pop", "foes")
addSpot({47, 35}, "pop", "foes")
addSpot({48, 35}, "pop", "foes")
addSpot({47, 36}, "pop", "foes")
addSpot({48, 36}, "pop", "foes")
addSpot({47, 37}, "pop", "foes")
addSpot({48, 37}, "pop", "foes")
addSpot({47, 38}, "pop", "foes")
addSpot({48, 38}, "pop", "foes")
addSpot({46, 4}, "pop", "foes")
addSpot({46, 5}, "pop", "foes")
addSpot({46, 6}, "pop", "foes")
addSpot({46, 7}, "pop", "foes")
addSpot({46, 8}, "pop", "foes")
addSpot({46, 9}, "pop", "foes")
addSpot({46, 10}, "pop", "foes")
addSpot({46, 11}, "pop", "foes")
addSpot({2, 31}, "pop", "foes")
addSpot({2, 32}, "pop", "foes")
addSpot({7, 7}, "pop", "defender")
addSpot({11, 4}, "pop", "defender")
addSpot({7, 13}, "pop", "defender")
addSpot({12, 26}, "pop", "defender")
addSpot({10, 40}, "pop", "defender")
addSpot({15, 37}, "pop", "defender")
addSpot({21, 32}, "pop", "defender")
addSpot({8, 46}, "pop", "defender")
addSpot({44, 41}, "pop", "defender")
addSpot({44, 42}, "pop", "defender")
addSpot({38, 39}, "pop", "defender")
addSpot({28, 33}, "pop", "defender")
addSpot({37, 32}, "pop", "defender")
addSpot({40, 28}, "pop", "defender")
addSpot({35, 19}, "pop", "defender")
addSpot({35, 12}, "pop", "defender")
addSpot({35, 9}, "pop", "defender")
addSpot({35, 4}, "pop", "defender")
addSpot({23, 4}, "pop", "defender")
addSpot({28, 3}, "pop", "defender")
addSpot({15, 0}, "pop", "foes")
addSpot({16, 0}, "pop", "foes")
addSpot({17, 0}, "pop", "foes")
addSpot({18, 0}, "pop", "foes")
addSpot({19, 0}, "pop", "foes")
addSpot({34, 0}, "pop", "foes")
addSpot({35, 0}, "pop", "foes")
addSpot({36, 0}, "pop", "foes")
addSpot({37, 0}, "pop", "foes")
addSpot({38, 0}, "pop", "foes")
addSpot({0, 40}, "pop", "foes")
addSpot({0, 41}, "pop", "foes")
addSpot({0, 42}, "pop", "foes")
addSpot({0, 43}, "pop", "foes")
addSpot({0, 44}, "pop", "foes")
addSpot({24, 32}, "pop", "player-attack")
addSpot({25, 32}, "pop", "player-attack")
addSpot({26, 36}, "pop", "defiler")

-- addZone section
addZone({23, 25, 23, 28}, "particle", "house_flamebeam")
addZone({22, 16, 22, 23}, "particle", "house_flamebeam")
addZone({23, 6, 23, 13}, "particle", "house_flamebeam")
addZone({13, 13, 13, 22}, "particle", "house_flamebeam")
addZone({17, 8, 24, 8}, "particle", "house_flamebeam")
addZone({26, 31, 36, 31}, "particle", "house_flamebeam")
addZone({33, 12, 33, 18}, "particle", "house_flamebeam")

-- ASCII map section
return [[
**************************************************
**************************************************
**************************************************
************************---------*****************
***********---*********--######-----**************
*********--------******---####-------*************
********----####--*****----1#--------*************
*******-----####--******-------##--***************
*******-###-2#3#--******------####-***************
*******-###------*********----7#8#--**************
*******-4##-----***********---------**************
*******-----*---************--------**************
*******----**---**************------**************
*******----**--*******--**************************
********--***********---**************************
********************---***************************
********************---***************************
**************************************************
*********************************--***************
*********************************---**************
*********************************-s-**************
*********************************---**************
************--********************--**************
************---*******---*************************
************-s-*******---*************************
************-s-*******--**************************
************---***********************************
*************--***********************************
***********************---**************--********
***********************-<-**********------********
***********************----*********-----*********
**********************-----*********---***********
*********************-------*******---************
********************---------******--*************
*******************----------*********************
******************------------********************
*****************--######-----********************
***************----#5#6##------*******************
**************-----#----#-------******************
************------###--###-------*****------******
**********-----------------------------------*****
********------tt.....---------ss-------------*****
******-------ttt~~~~..-------ssss------------*****
******-----tttt~~t.~~.-------^^^^------==-==--****
******-----ttt~~tt..~...----^^^^^^^---==___==-****
******------ttttttt.~~~....^^^^^^^^---=__Z__==****
********---------t-...~~~~^^^^^^^^^---=______=****
*************--------......ssssss-----========****
********************------------------************
**************************************************]]