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

-- Maj'Eyal, the main continent

quickEntity('~', {always_remember = true, show_tooltip=true, name='the sea of Maj', display='~', color=colors.DARK_BLUE, back_color=colors.BLUE, image="terrain/river.png", block_move=true, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity('-', {always_remember = true, show_tooltip=true, name='river', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter=true, equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity('*', {always_remember = true, show_tooltip=true, name='lake of Nur', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter=true, equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })

quickEntity('^', {always_remember = true, show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('m', {always_remember = true, show_tooltip=true, name='Daikara', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/rocky_mountain.png", block_move=true})
quickEntity('#', {always_remember = true, show_tooltip=true, name='Iron Throne', display='^', color=colors.SLATE, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})

quickEntity('T', {always_remember = true, show_tooltip=true, name='forest', force_clone=true, display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", resolvers.generic(function(e) e.add_displays = e:makeTrees("terrain/tree_alpha") end), block_move=true})
quickEntity('t', {always_remember = true, show_tooltip=true, name='cold forest', display='#', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/rocky_snowy_tree.png", block_move=true})
quickEntity('_', {always_remember = true, show_tooltip=true, name='burnt forest', display='#', color=colors.UMBER, back_color=colors.DARK_GREY, image="terrain/burnt-tree.png", block_move=true})
quickEntity('v', {always_remember = true, show_tooltip=true, name='old forest', force_clone=true, display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/grass_dark1.png", resolvers.generic(function(e) e.add_displays = e:makeTrees("terrain/tree_alpha") end), block_move=true})

quickEntity('.', {always_remember = true, show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('|', {always_remember = true, show_tooltip=true, name='desert', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10})

quickEntity('"', {always_remember = true, show_tooltip=true, name='polar cap', display='.', color=colors.LIGHT_BLUE, back_color=colors.WHITE, can_encounter=true, image="terrain/frozen_ground.png", equilibrium_level=-10})
quickEntity('=', {always_remember = true, show_tooltip=true, name='frozen sea', display=';', color=colors.LIGHT_BLUE, back_color=colors.WHITE, can_encounter=true, image="terrain/ice_shelf.png", equilibrium_level=-10})

quickEntity('{', {always_remember = true, show_tooltip=true, name='the Charred Scar', display='.', color=colors.WHITE, back_color=colors.LIGHT_DARK, image="terrain/lava_floor.png", shader = "lava", can_encounter=true})

quickEntity('!', {always_remember = true, show_tooltip=true, name='hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter=true, equilibrium_level=-10})
quickEntity('h', {always_remember = true, show_tooltip=true, name='low hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter=true, equilibrium_level=-10})

quickEntity('&', {always_remember = true, show_tooltip=true, name='cultivated fields', display=';', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/cultivation.png", can_encounter=true, equilibrium_level=-10})

quickEntity('A', {always_remember = true, show_tooltip=true, name="Ruins of Kor'Pul", 	display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="ruins-kor-pul"})
quickEntity('B', {always_remember = true, show_tooltip=true, name="Passageway into the Trollshaws", 	display='>', color={r=0, g=255, b=0}, notice = true, change_level=1, change_zone="trollshaws"})
quickEntity('C', {always_remember = true, show_tooltip=true, name="A gate into a maze", 			display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="maze"})
quickEntity('D', {always_remember = true, show_tooltip=true, name="A path into the Old Forest", 		display='>', color={r=0, g=255, b=155}, notice = true, change_level=1, change_zone="old-forest"})
quickEntity('E', {always_remember = true, show_tooltip=true, name="A mysterious hole in the beach", 	display='>', color={r=200, g=255, b=55}, notice = true, change_level=1, change_zone="sandworm-lair"})
quickEntity('F', {always_remember = true, show_tooltip=true, name="The entry to the old tower of Tol Falas",display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="tol-falas"})
quickEntity('G', {always_remember = true, show_tooltip=true, name="Passageway into Daikara",display='>', color=colors.UMBER, notice = true, change_level=1, change_zone="daikara"})
quickEntity('H', {always_remember = true, show_tooltip=true, name='Charred Scar', display='>', color=colors.RED, back_color=colors.LIGHT_DARK, image="terrain/volcano1.png", notice = true, change_level=1, change_zone="charred-scar"})

quickEntity('1', {always_remember = true, show_tooltip=true, name="Derth (Town)", desc="A quiet town at the crossroads of the north", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-derth"})
quickEntity('2', {always_remember = true, show_tooltip=true, name="Last Hope (Town)", desc="Capital city of the Allied Kingdoms ruled by King Tolak", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-last-hope"})
quickEntity('4', {always_remember = true, show_tooltip=true, name="Shatur (Town)", desc="Capital city of Thaloren lands, ruled by Nessilla Tantaelen", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true})
quickEntity('5', {always_remember = true, show_tooltip=true, name="Elvala (Town)", desc="Capital city of Shaloren lands, ruled by Aranion Gayaeil", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true})

-- Angolwen is only know from the start to mages
if game.player:knowTalent(game.player.T_TELEPORT_ANGOLWEN) then
	quickEntity('3', {always_remember = true, show_tooltip=true, name="Angolwen, the hidden city of magic", desc="Secret place of magic, set apart from the world to protect it.", display='*', color=colors.WHITE, back_color=colors.UMBER, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-angolwen"})
else
	quickEntity('3', '^')
end

-- Load encounters for this map
prepareEntitiesList("encounters", "mod.class.Encounter", "/data/general/encounters/maj-eyal.lua")
addData{ encounters = {
	chance=function(who)
		local harmless_chance = 1 + who:getLck(7)
		local hostile_chance = 5
		if rng.percent(hostile_chance) then return "hostile"
		elseif rng.percent(harmless_chance) then return "harmless"
		end
	end}
}

return [[
==========""""""""""""""""""""""""""""""""""""""""""""""""m###########
========""""""""""""""""""""""""""""""""""""""""""""""""mmm###########
=======""""""""""""""""""""""""""""""ttttt"""""""mmmmmmmmmm""#########
=======""""""""""""""""""""""""tttttttttttttmm"mmmmmmmmmmmm"""########
======="""""""...."""""""""""tttttttttttttttmmmmmmTTTT!mmmm""""#######
======="""""......"""""...""tttttttttttttttttmmmmTTTTT!!Gm""""""######
========"".........""".....tttttttttTTTTTtttttmmTTTTT!!!!!!.."""######
=======........!!!........BTtttttttTT!4!TTTTTTTTTTTTTT!!!!!..."""#####
===~~~.........!!!....A....TTTtttTTTT!!!TTTTTTTTTTTTT!!!!!!......#####
~~~~~||.......!!!!&&........TTTTTTTTTT!TTTTTTTTTTTTT!!!!!!.......#####
~~~~|||.......!!!&&&&...T........TTTTTTTTTTTTTTTTT....!!!.....T..#####
~~~|||........!!!&&&&..1TT........TTTTTTTTTTTT................T..#####
~~||||...TT...!!!&&&...TTT...................................TT...-###
~~||||..TTTTT.!!!&&&.........................................TTT..-###
~~||||.TTT^^T..!!.........................................T.TTTT..-###
~~||||TTT^^^T.............vv..............................TTTTTT.--###
~~|||.TT^^^^C..............vv.............................TTTTTT.-.###
~~|||.TT^^^^.............Dvvvv..............................TTT..-..##
~~E||.TT^^3^............vvvvvvvvv............................TT..-...#
~~|||..T^^^^............vvv**vvvvv...............................-...#
~~|||..TT^^^.............vv**vvvvv...............................--...
~~|||.TT.^^-..............vvvvv...................................-...
~~|||.TT...--............vvvvvvv..................................-...
~~|||.T.....--...........vv..vv...................................-...
~~|||.......T--TT........v.................................&&.....-...
~~~|.......TTT-TTT.......................................&&&&&&...-...
~~~........TTT-TTT......................................&&&&&&&&.--...
~~~~.......TT---TT......................................&&&&&&&&--....
~~~~~..~...TT-T--.......................................&&&&&&&--.....
~~~~~~~~....--TT-.........................TT...............&&&&-......
~~~~~~~~~..--TTT-.......................TTTT................&--.......
~~~~~~~~~~--....-...~~.................TTTT.................--.....!!!
~~~~~~~~~~-TTT..--~~~~................TTTTT.........~......--....!!!!~
~~~~~~~~~~TTTTT...~~~.................____T........~~~....2-....!!!!~~
~~~~~~~~~..TTTTTTT~~~..............~.T_{{__........~~~..----....!!!~~~
~~~~~~~~...&&TTTTT~~~~.....~~~..~~~~~T_{{{_........~~~~~~.-....!!!~~~~
~~~~~~~~...&&-..TT~~~~~~~~~~~~~~~~~~~~__{{{.......~~~~~~~.-....!!~~~~~
~~~~~T~~..&&--....~~~~~~~~~~~~~~~~~~~~~___{{.....~~~~~~~~---..!!~~~~~~
~~~~~TTTT.&&-5....~~~~~~~~~~~~~~~~~~~~~~T_{{{{~~F~~~~~~~~-.-..!!~~~~~~
~~~~~TTTT.&&-.....~~~~~~~~~~..~~~~~~~~~~~~..{{~~~~~~~~~~~~.-...~~~~~~~
~~~~~TTT...----...~~~~~~~~~....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~~~~
~~~~~~TT...-..----~~~~~~~~.T^^..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~...-.....~~~~~~~~..^^^^.~~~~~~~~~~~~~~~~~~~{{{~~~~~~~~~~~~~~~~
~~~~~~~~~~--.....~~~~~~~~.^^^^^.~~~~~~~~~~~~~~~~~~{{{~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~.^^^^^.~~~~~~~~~~~~~~~~~~~{{{H~~~{{~~~~~~~~~~
~~~~~~~~~~~~....~~~~~~~~~.T^^^T.~~~~~~~~~~~~~~~~~~~{{{{{{{{{~~~~~~~~~~
~~~~~~~~~.........~~~~~~~~.TTT..~~~~~~~~~~~~~~~~~~~~{{{{{{{~~~~~~~~~~~
~~~~~~~~~..........~~~~~~~~T..~~~~~~~~~~~~~~~~~~~~~~~~~{{~~~~~~~.~~~~~
~~~~~~~~~~.........~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{..~~~~~
~~~~~~~~~~~~.......~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{{{{~~~~~
~~~~~~~~~~~~........~~~~~~........~~~~~~~~.......~~~~~~~~~~~~.{{{~~~~~
~~~~~~~~~~~~.........~~~~.........~~~~...........~~~~~~~~~~~~....~~~~~
~~~~~~~~~~~~.........~~~.........................~~~~~~~~~~~.....~~~~~
~~~~~~~~~~~~.....................................~~~~~~~~~~~.....~~~~~
~~~~~~~~~~~~......................................~~~~~~~~~.......~~~~
~~~~~~~~~~~.......................................~~~~~~~~~.......~~~~
~~~~~~~~~~~........................................~~~.............~~~
~~~~~~~............................................................~~~
~~~~~~..............................................................~~
~~~~~.................................................................
~~~~~.................................................................
~~~~~.................................................................
~~~~~.................................................................
~~~~~~................................................................
~~~~~~~...............................................................
~~~~~~~~..............................................................
~~~~~~~~~.............................................................
~~~~~~~~~.............................................................
~~~~~~~~..............................................................
~~~~~~~...............................................................]]