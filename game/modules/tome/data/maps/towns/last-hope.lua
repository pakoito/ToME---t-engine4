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

--[[
quickEntity('<', {show_tooltip=true, name='into the wild', notice=true, display='<', color=colors.WHITE, change_level=1, change_zone="wilderness", image="terrain/stone_road1.png", add_displays = {mod.class.Grid.new{image="terrain/worldmap.png"}}})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/tree.png"})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png"})
quickEntity('O', {name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(' ', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/granite_wall1.png"})
quickEntity('*', {name="Tannen's Tower", display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/granite_wall1.png"})
quickEntity('^', {name='hills', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true, block_sight=true})
quickEntity(',', {name='dirt', display='.', color=colors.LIGHT_UMBER, image="terrain/sand.png"})
quickEntity('I', {name='tunneled wall', show_tooltip=true, display='#', color=colors.WHITE, image="terrain/wood_wall1.png"})
quickEntity('M', {name='tunneled hills', show_tooltip=true, display='^', color=colors.SLATE, image="terrain/mountain.png"})
quickEntity('1', {type="store", show_tooltip=true, name="Closed store", display='1', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('2', {type="store", show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, resolvers.store("ARMOR"), image="terrain/wood_store_armor.png"})
quickEntity('3', {type="store", show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, resolvers.store("WEAPON"), resolvers.chatfeature("last-hope-weapon-store"), image="terrain/wood_store_weapon.png"})
quickEntity('4', {type="store", show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {type="store", show_tooltip=true, name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), resolvers.chatfeature("magic-store"), image="terrain/wood_store_book.png"})
quickEntity('6', {type="store", show_tooltip=true, name="Closed store", display='6', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('7', {type="store", show_tooltip=true, name="Closed store", display='7', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('8', {type="store", show_tooltip=true, name="Closed store", display='8', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('9', {type="store", show_tooltip=true, name="Closed store", display='9', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('0', {type="store", show_tooltip=true, name="Closed store", display='0', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('a', {type="store", show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('b', {type="store", show_tooltip=true, name="Hall of the King", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('c', {type="store", show_tooltip=true, name="Library", display='*', color=colors.LIGHT_RED, resolvers.store("LAST_HOPE_LIBRARY"), image="terrain/wood_store_book.png"})
quickEntity('d', {type="store", show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('e', {type="store", show_tooltip=true, name="Rare goods", display='*', color=colors.AQUAMARINE, resolvers.store("LOST_MERCHANT"), resolvers.chatfeature("last-hope-lost-merchant"), image="terrain/wood_store_weapon.png"})
quickEntity('g', {type="store", show_tooltip=true, name="Rich merchant", display='*', color=colors.AQUAMARINE, resolvers.chatfeature("last-hope-melinda-father"), image="terrain/wood_store_closed.png"})
]]
quickEntity('E', {type="store", show_tooltip=true, name="The Elder", display='*', color=colors.VIOLET, resolvers.chatfeature("last-hope-elder"), image="terrain/wood_store_closed.png"})
quickEntity('T', {type="store", show_tooltip=true, name="Tannen's Tower", display='*', color=colors.VIOLET, resolvers.chatfeature("tannen"), image="terrain/wood_store_closed.png"})

quickEntity('@', {show_tooltip=true, name="Statue of King Tolak the Fair", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-tolak-statue") end return true end})
quickEntity('Z', {show_tooltip=true, name="Statue of King Toknor the Brave", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-toknor-statue") end return true end})
quickEntity('Y', {show_tooltip=true, name="Statue of Queen Mirvenia the Inspirer", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-mirvenia-statue") end return true end})

-- defineTile section
defineTile("#", "HARDWALL")
defineTile("&", "HARDMOUNTAIN_WALL")
defineTile("~", "DEEP_WATER")
defineTile("_", "ROAD")
defineTile(".", "GRASS")
defineTile("t", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
defineTile(" ", "FLOOR")

--[[
defineTile('1', "HARDWALL", nil, nil, "TRAINER")
defineTile('2', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "HERBALIST")
defineTile('5', "HARDWALL", nil, nil, "MACE_WEAPON_STORE")
defineTile('6', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('7', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('9', "HARDWALL", nil, nil, "LIBRARY")
]]

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
ttttt~~~~#    ### _  ##34 56##  _  #     #~~~~tttt
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
t~~~#  #####1  _~#tt_&&_____&&_tt#~_  7#####  #~~~
t~~~#  #####   _~#tt_&&_###_&&_tt#~_   #####  #~~~
t~~~#  #####2  _~#tt_&&_#E#_&&_tt#~_  8#####  #~~~
t~~~#      ##  _~##t__&&___&&__t##~_  ##      #~~~
t~~~#      ### _~~#tt_&&&&&&&_tt#~~_ ###      #~~~
t~~~##      ## __~##t___&&&___t##~__ ##      ##~~~
tt~~~#       ## _~~##tt_____tt##~~_ ##       #~~~t
tt~~~#          __~~##ttttttt##~~__          #~~~t
tt~~~##          __~~###ttt###~~__          ##~~~t
tt~~~~#           __~~~#####~~~__           #~~~~t
ttt~~~##           ___~~~~~~~___      #    ##~~~tt
ttt~~~~#     #       _________       ###   #~~~~tt
tttt~~~##   ###     #         #     ###   ##~~~ttt
tttt~~~~##   ###    ###     ###    ###   ##~~~~ttt
ttttt~~~~#    ###    #### ####      #    #~~~~tttt
tttttt~~~##    #      #######           ##~~~ttttt
tttttt~~~~##            ###            ##~~~~ttttt
ttttttt~~~~###          ###          ###~~~~tttttt
tttttttt~~~~~##         ###         ##~~~~~ttttttt
ttttttttt~~~~~###       ###       ###~~~~~tttttttt
tttttttttt~~~~~~###             ###~~~~~~ttttttttt
tttttttttttt~~~~~~####       ####~~~~~~ttttttttttt
ttttttttttttt~~~~~~~~#########~~~~~~~~tttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~~tttttttttttttt
ttttttttttttttttt~~~~~~~~~~~~~~~~~tttttttttttttttt
ttttttttttttttttttttt~~~~~~~~~tttttttttttttttttttt]]