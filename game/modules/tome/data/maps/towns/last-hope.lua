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

quickEntity('@', {show_tooltip=true, name="Statue of King Tolak the Fair", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-tolak-statue") end return true end})
quickEntity('Z', {show_tooltip=true, name="Statue of King Toknor the Brave", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-toknor-statue") end return true end})
quickEntity('Y', {show_tooltip=true, name="Statue of Queen Mirvenia the Inspirer", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-mirvenia-statue") end return true end})

-- defineTile section
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("#", "HARDWALL")
defineTile("&", "HARDMOUNTAIN_WALL")
defineTile("~", "DEEP_WATER")
defineTile("_", "ROAD")
defineTile(".", "GRASS")
defineTile("t", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
defineTile(" ", "FLOOR")

defineTile('1', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('2', "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "MAUL_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('6', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('7', "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "HERBALIST")
defineTile('9', "HARDWALL", nil, nil, "RUNES")

defineTile('E', "HARDWALL", nil, nil, "ELDER")
defineTile('T', "HARDWALL", nil, nil, "TANNEN")
defineTile('H', "HARDWALL", nil, nil, "ALCHEMIST")
defineTile('M', "HARDWALL", nil, nil, "RARE_GOODS")
defineTile('F', "HARDWALL", nil, nil, "MELINDA_FATHER")


startx = 25
starty = 0
endx = 25
endy = 0

-- addSpot section
addSpot({6, 20}, "pop-quest", "farportal")
addSpot({7, 19}, "pop-quest", "farportal-player")
addSpot({10, 19}, "pop-quest", "tannen-remove")
addSpot({6, 19}, "pop-quest", "farportal-npc")

-- addZone section

-- ASCII map section
return [[
ttttttttttttttttttttttttt<tttttttttttttttttttttttt
ttttttttttttttttttttt~~~._.~~~tttttttttttttttttttt
ttttttttttttttttt~~~~~~~._.~~~~~~~tttttttttttttttt
ttttttttttttttt~~~~~~~~~._.~~~~~~~~~tttttttttttttt
ttttttttttttt~~~~~~~~####_####~~~~~~~~tttttttttttt
tttttttttttt~~~~~~####_______####~~~~~~ttttttttttt
tttttttttt~~~~~~###   _     _   ###~~~~~~ttttttttt
ttttttttt~~~~~###     _ ### _     ###~~~~~tttttttt
tttttttt~~~~~##       _ ### _       ##~~~~~ttttttt
ttttttt~~~~###      ___ ### ___      ###~~~~tttttt
tttttt~~~~##       __   ###   __       ##~~~~ttttt
tttttt~~~##    #  __  #######  __       ##~~~ttttt
ttttt~~~~#    ### _  ##56 7###  _  #     #~~~~tttt
tttt~~~~##   ###  _ ###     ### _ ###    ##~~~~ttt
tttt~~~##   ###   _ #         # _  ###    ##~~~ttt
ttt~~~~#     #    _  _________  _   M##    #~~~~tt
ttt~~~##          ____~~~_~~~____    #     ##~~~tt
tt~~~~#  ###      __~~~##_##~~~__           #~~~~t
tt~~~##  ###     __~~###@_t###~~__          ##~~~t
tt~~~#   #T#    __~~##ttY_Ztt##~~__          #~~~t
tt~~~#       ## _~~##tt_____tt##~~_ ##       #~~~t
t~~~##      ## __~##t___&_&___t##~__ ##      ##~~~
t~~~#      ### _~~#tt_&&&_&&&_tt#~~_ ###      #~~~
t~~~#      ##  _~##t__&&&_&&&__t##~_  ##      #~~~
t~~~#  #####1  _~#tt_&&_____&&_tt#~_  3#####  #~~~
t~~~#  #####   _~#tt_&&_###_&&_tt#~_   #####  #~~~
t~~~#  #8###2  _~#tt_&&_#E#_&&_tt#~_  4###9#  #~~~
t~~~#      ##  _~##t__&_____&__t##~_  ##      #~~~
t~~~#      ### _~~#tt_&&&&&&&_tt#~~_ ###      #~~~
t~~~##      ## __~##t___&&&___t##~__ ##      ##~~~
tt~~~#       ## _~~##tt_____tt##~~_ ##       #~~~t
tt~~~#          __~~##ttttttt##~~__          #~~~t
tt~~~##          __~~###ttt###~~__          ##~~~t
tt~~~~#           __~~~#####~~~__           #~~~~t
ttt~~~##           ___~~~~~~~___      #    ##~~~tt
ttt~~~~#     #       _________       ###   #~~~~tt
tttt~~~##   ###     #         #     ###   ##~~~ttt
tttt~~~~##   ###    ###     ###    ##H   ##~~~~ttt
ttttt~~~~#    ###    ###9 ####      #    #~~~~tttt
tttttt~~~##    #      #######           ##~~~ttttt
tttttt~~~~##            ###            ##~~~~ttttt
ttttttt~~~~###          ###          ###~~~~tttttt
tttttttt~~~~~##         ###         ##~~~~~ttttttt
ttttttttt~~~~~###       #F#       ###~~~~~tttttttt
tttttttttt~~~~~~###             ###~~~~~~ttttttttt
tttttttttttt~~~~~~####       ####~~~~~~ttttttttttt
ttttttttttttt~~~~~~~~#########~~~~~~~~tttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~~tttttttttttttt
ttttttttttttttttt~~~~~~~~~~~~~~~~~tttttttttttttttt
ttttttttttttttttttttt~~~~~~~~~tttttttttttttttttttt]]
