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

defineTile(' ', "FLOOR", nil, nil, nil, {no_teleport=true})
quickEntity('M', {always_remember = true, show_tooltip=true, name='Sun Wall', display='^', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/mountain.png", tint=colors.GOLD, block_move=true}, {no_teleport=true})
quickEntity('<', {show_tooltip=true, name='into the wild', display='<', color=colors.WHITE, change_level=1, change_zone="wilderness"}, {no_teleport=true})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"}, {no_teleport=true})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"}, {no_teleport=true})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"}, {no_teleport=true})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/wood_wall1.png"}, {no_teleport=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha2.png"}}}, {no_teleport=true})
quickEntity('P', {name='palm tree', display='#', color=colors.LIGHT_GREEN, back_color={r=163,g=149,b=42}, image="terrain/sand.png", add_displays = {mod.class.Grid.new{image="terrain/palmtree_alpha1.png"}}, block_move=true}, {no_teleport=true})
quickEntity('~', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png", add_displays = mod.class.Grid:makeWater(true)}, {no_teleport=true})
quickEntity('O', {name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"}, {no_teleport=true})
quickEntity(':', {name='sand', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10}, {no_teleport=true})
quickEntity('"', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"}, {no_teleport=true})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('^', {name='hills', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true, block_sight=true}, {no_teleport=true})

defineTile('@', "GRASS", nil, "HIGH_SUN_PALADIN_AERYN")
defineTile('j', "GRASS", nil, mod.class.NPC.new{
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.RED,
	name = "Limmir, Expert Jeweler",
	size_category = 3, rank = 3,
	ai = "simple",
	faction = "sunwall",
	can_talk = "jewelry-store",
	can_quest = true,
})

quickEntity('1', {show_tooltip=true, name="Closed store", display='1', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('2', {show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, resolvers.store("ARMOR"), image="terrain/wood_store_armor.png"}, {no_teleport=true})
quickEntity('3', {show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, resolvers.store("WEAPON"), image="terrain/wood_store_weapon.png"}, {no_teleport=true})
quickEntity('4', {show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"}, {no_teleport=true})
quickEntity('5', {show_tooltip=true, name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), resolvers.chatfeature("magic-store"), image="terrain/wood_store_book.png"}, {no_teleport=true})
quickEntity('6', {show_tooltip=true, name="Closed store", display='6', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('7', {show_tooltip=true, name="Closed store", display='7', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('8', {show_tooltip=true, name="Closed store", display='8', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('9', {show_tooltip=true, name="Closed store", display='9', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('0', {show_tooltip=true, name="Closed store", display='0', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('a', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('b', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('c', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('d', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"}, {no_teleport=true})
quickEntity('e', {show_tooltip=true, name="Zemekkys Home", display='+', color=colors.LIGHT_UMBER, resolvers.chatfeature("zemekkys"), image="terrain/wood_store_closed.png"}, {no_teleport=true})

startx = 0
starty = 27
endx = 0
endy = 27

return [[
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMM                MMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMM                             MMMMMMMMM
MMMMMMMMMM                     ###          MMMMMM
MMMMMMMMM                     #####          MMMMM
MMMMMMMM                      #####          MMMMM
MMMMMMM                       #4O5#          MMMMM
MMMMMM                          O            MMMMM
MMMMMM                          O             MMMM
MMMMMM     #####                O             MMMM
MMMMMM    ######                O            MMMMM
MMMMM     #####3OOO            OO    ###    MMMMMM
MMMMM     ######  OOOO         O     ###    MMMMMM
MMMMM      #####     OOOOO     O     #e#    MMMMMM
MMMMM                    OOOO  O      O     MMMMMM
MMMMM                       OOOO      O      MMMMM
MMMM          ###             O      OO       MMMM
MMMM       #########          O      O       MMMMM
MMM        #########          OOOOOOOOOOOOOOOOMMMM
MMM        ####2####         OO                MMM
MMMMM          O             O                 MMM
MMMMMM         O            OO                 MMM
---MMM         O           OO                  MMM
----MM        OO          OO                   MMM
----MM        O          OO                     MM
---MMMM       O          O                       M
<---@OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  M
---MMMM                   O                     MM
---MMM                    O                 MMMMMM
-MMMM                     O                  MMMMM
-MMM                      O                     MM
MMM                       O                    MMM
MMM                      OO                   MMMM
MMM          TTTTT       O                   MMMMM
MMM       TTTT"""""""""""O"""""""            MMMMM
MMMM     TT"""""~~~""""""""""""""""""""""    MMMMM
MMMMMM  TT"""""~~~~~""""""""""""""""""::""""MMMMMM
MMMMMMMMM""""""~~~~~"""""""TT"""""""::P:::::MMMMMM
MMMMMMMMM"""j"""~~~"""""TT"T""""""::::::::::MMMMMM
MMMMMMMMM"""""""~~""""""TTTT"""""::::::::P:::MMMMM
MMMMMMMMM"""""TT~"""""""TT"""""":::::P:::::MMMMMMM
MMMMMMMMM"""TTTT~""""""""""""""::::::::::::MMMMMMM
MMMMMMMMMM""TTT~~""""""""""""::::P::::::::::MMMMMM
MMMMMMMMMMM"TT~~"""""""""""""::::::::::::P::::MMMM
MMMMMMMMMMMMMM~MMMMMMMMMM""""::::P:::P::::::::MMMM
MMMMMMMMMMMMM~~MMMMMMMMMMM""::::::P::::::::::::MMM
MMMMMMMM~~~~~~MMMMMMMMMMMMMM:::::::::::::::::MMMMM
MMMMMMM~~MMMMMMMMMMMMMMMMMMMMMM::::MMMMMMMMMMMMMMM
MMMMMMM~MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM]]
