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

quickEntity('^', {show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_BLUE, image="terrain/mountain.png", block_move=true, block_sight=true})
quickEntity('<', {show_tooltip=true, name='portal back', display='<', color=colors.WHITE, change_level=1, change_zone=game.player.last_wilderness}, nil, {type="portal", subtype="back"})
quickEntity('t', {show_tooltip=true, name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha2.png"}}})
quickEntity('*', {show_tooltip=true, name='magical rock', display='#', color=colors.GREY, back_color={r=44,g=95,b=43}, block_move=true, block_sight=true, image="terrain/rock_grass.png"})
quickEntity('~', {show_tooltip=true, name='fountain', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png", shader = "water", textures = { function() return _3DNoise, true end }})
quickEntity('.', {show_tooltip=true, name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('-', {show_tooltip=true, name='cultivated fields', display=';', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/cultivation.png", equilibrium_level=-10})
quickEntity('_', {show_tooltip=true, name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})

quickEntity('2', {show_tooltip=true, name="Jewelry", display='2', color=colors.BLUE, resolvers.store("ANGOLWEN_JEWELRY"), resolvers.chatfeature("jewelry-store"), image="terrain/wood_store_gem.png"})
quickEntity('4', {show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {show_tooltip=true, name="Library", display='5', color=colors.WHITE, resolvers.store("ANGOLWEN_SCROLL"), image="terrain/wood_store_book.png"})
quickEntity('6', {show_tooltip=true, name="Staves & Wands", display='6', color=colors.RED, resolvers.store("ANGOLWEN_STAFF_WAND"), resolvers.chatfeature("magic-store"), image="terrain/wood_store_closed.png"})

defineTile('@', "GRASS", nil, "SUPREME_ARCHMAGE_LINANIIL")

startx = 24
starty = 46

return [[
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^2^^4^5^^6^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^.._.._._.._..^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^.._________..^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^...t.._..t...^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^...._....^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.._..^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^.^^^^_^^^_^^^^^^..._...^^^^^^^^^^^^^^^^^^^^^^
^^^^...^^^_^^^_^^^^^...___...^^^^^^^^^^^^^^^^^^^^^
^^^.....^^_^^^_^^^^^..__~__..^^^^^^^^^^^^^^^^^^^^^
^^.*....____________.__~~~__.___________^^^^^^^^^^
^^.@_____^^^^^^^^^^___~~t~~___^^^^^^^^^_^^^^^^^^^^
^^.*....____________.__~~~__.___________^^^^^^^^^^
^^^.....^^_^^^_^^^^^..__~__..^^^^^^^^^^_^^^^^^^^^^
^^^^...^^^_^^^_^^^^^...___...^^^^^^^^^^_^^^^^^^^^^
^^^^^.^^^^_^^^_^^^^^^..._...^^^^^^^^^^^_^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^.........^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^t_t^^^^^^^^^.-------.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.---*---.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^.........^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.___.^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^t._<_.t^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.___.^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^...^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^]]