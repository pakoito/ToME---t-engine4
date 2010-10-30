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
quickEntity('*', {always_remember = true, show_tooltip=true, name='lake of Nur', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", block_move=true, equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity(')', {always_remember = true, show_tooltip=true, name='sea of Sash', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", block_move=true, equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity('(', {always_remember = true, show_tooltip=true, name='lake', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", block_move=true, equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })

quickEntity('q', {always_remember = true, show_tooltip=true, name='volcanic mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/volcano2.png", block_move=true})
quickEntity('^', {always_remember = true, show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('m', {always_remember = true, show_tooltip=true, name='Daikara', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/rocky_mountain.png", block_move=true})
quickEntity('#', {always_remember = true, show_tooltip=true, name='Iron Throne', display='^', color=colors.SLATE, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('w', {always_remember = true, show_tooltip=true, name='Sun Wall', display='^', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/mountain.png", tint=colors.GOLD, block_move=true})

quickEntity('p', {always_remember = true, show_tooltip=true, name='palm forest', display='#', color=colors.LIGHT_GREEN, back_color={r=163,g=149,b=42}, image="terrain/sand.png", add_displays = {mod.class.Grid.new{image="terrain/palmtree_alpha1.png"}}, block_move=true})
quickEntity('T', {always_remember = true, show_tooltip=true, name='forest', force_clone=true, display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", resolvers.generic(function(e) e.add_displays = e:makeTrees("terrain/tree_alpha") end), block_move=true})
quickEntity('t', {always_remember = true, show_tooltip=true, name='cold forest', display='#', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/rocky_snowy_tree.png", block_move=true})
quickEntity('_', {always_remember = true, show_tooltip=true, name='burnt forest', display='#', color=colors.UMBER, back_color=colors.DARK_GREY, image="terrain/burnt-tree.png", block_move=true})
quickEntity('v', {always_remember = true, show_tooltip=true, name='old forest', force_clone=true, display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/grass_dark1.png", resolvers.generic(function(e) e.add_displays = e:makeTrees("terrain/tree_dark_alpha") end), block_move=true})

quickEntity('.', {always_remember = true, show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('|', {always_remember = true, show_tooltip=true, name='desert', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10})

quickEntity('"', {always_remember = true, show_tooltip=true, name='polar cap', display='.', color=colors.LIGHT_BLUE, back_color=colors.WHITE, can_encounter=true, image="terrain/frozen_ground.png", equilibrium_level=-10})
quickEntity('=', {always_remember = true, show_tooltip=true, name='frozen sea', display=';', color=colors.LIGHT_BLUE, back_color=colors.WHITE, can_encounter=true, image="terrain/ice_shelf.png", equilibrium_level=-10})

quickEntity('{', {always_remember = true, show_tooltip=true, name='Charred Scar', display='.', color=colors.WHITE, back_color=colors.LIGHT_DARK, image="terrain/lava_floor.png", shader = "lava", can_encounter=true})

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
quickEntity('H', {always_remember = true, show_tooltip=true, name='Charred Scar Volcano', display='>', color=colors.RED, back_color=colors.LIGHT_DARK, image="terrain/volcano1.png", notice = true, change_level=1, change_zone="charred-scar"})
quickEntity('I', {always_remember = true, show_tooltip=true, name="Sun Wall Outpost (Town)", display='*', color=colors.GOLD, notice = true, change_level=1, change_zone="town-sunwall-outpost"})
quickEntity('J', {always_remember = true, show_tooltip=true, name="High Peak", display='>', color=colors.VIOLET, notice = true, change_level=1, change_zone="high-peak"})

quickEntity('1', {always_remember = true, show_tooltip=true, name="Derth (Town)", desc="A quiet town at the crossroads of the north", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-derth"})
quickEntity('2', {always_remember = true, show_tooltip=true, name="Last Hope (Town)", desc="Capital city of the Allied Kingdoms ruled by King Tolak", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-last-hope"})
quickEntity('4', {always_remember = true, show_tooltip=true, name="Shatur (Town)", desc="Capital city of Thaloren lands, ruled by Nessilla Tantaelen", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true})
quickEntity('5', {always_remember = true, show_tooltip=true, name="Elvala (Town)", desc="Capital city of Shaloren lands, ruled by Aranion Gayaeil", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true})
quickEntity('6', {always_remember = true, show_tooltip=true, name="Gates of Morning", desc="A massive hole in the Sunwall", display='*', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/gate-morning.png", tint=colors.GOLD, notice = true, change_level=1, change_zone="town-gates-of-morning"})

-- Angolwen is only know from the start to mages
if game.player:knowTalent(game.player.T_TELEPORT_ANGOLWEN) then
	quickEntity('3', {always_remember = true, show_tooltip=true, name="Angolwen, the hidden city of magic", desc="Secret place of magic, set apart from the world to protect it.", display='*', color=colors.WHITE, back_color=colors.UMBER, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-angolwen"})
else
	quickEntity('3', '^')
end

-- Load encounters for this map
prepareEntitiesList("encounters", "mod.class.Encounter", "/data/general/encounters/maj-eyal.lua")
prepareEntitiesList("encounters_npcs", "mod.class.WorldNPC", "/data/general/encounters/maj-eyal-npcs.lua")
addData{
	wda = { script="maj-eyal", },
	encounters = {
		chance=function(who)
			local harmless_chance = 1 + who:getLck(7)
			local hostile_chance = 5
			if rng.percent(hostile_chance) then return "hostile"
			elseif rng.percent(harmless_chance) then return "harmless"
			end
		end
	},
}

-- addSpot section
addSpot({35, 33}, "patrol", "allied-kingdoms")
addSpot({23, 10}, "patrol", "allied-kingdoms")
addSpot({15, 33}, "patrol", "allied-kingdoms")
addSpot({16, 33}, "patrol", "allied-kingdoms")
addSpot({40, 12}, "patrol", "allied-kingdoms")
addSpot({40, 13}, "patrol", "allied-kingdoms")
addSpot({63, 5}, "patrol", "allied-kingdoms")
addSpot({58, 32}, "patrol", "allied-kingdoms")
addSpot({27, 24}, "hostile", "random")
addSpot({28, 24}, "hostile", "random")
addSpot({27, 25}, "hostile", "random")
addSpot({28, 25}, "hostile", "random")
addSpot({54, 7}, "hostile", "random")
addSpot({55, 7}, "hostile", "random")
addSpot({54, 8}, "hostile", "random")
addSpot({55, 8}, "hostile", "random")
addSpot({43, 37}, "hostile", "random")
addSpot({44, 37}, "hostile", "random")
addSpot({43, 38}, "hostile", "random")
addSpot({44, 38}, "hostile", "random")
addSpot({8, 25}, "hostile", "random")
addSpot({9, 25}, "hostile", "random")
addSpot({8, 26}, "hostile", "random")
addSpot({9, 26}, "hostile", "random")
addSpot({35, 29})
addSpot({54, 14})

-- ASCII map section
return [[
==========ttt""""""""tttt"""""""""""""""""""""""""""""""""m##############~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
========""tttt""""""""ttt"""""""""""""""""""""""""""""""mmm###############~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=======""tttt""""""""""""""""""""""""ttttt"""""""mmmmmmmmmm""#############~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~~~~~~~~....~~~~~~~
=======""ttt"""""""""""""""""""tttttttttttttmm"mmmmmmmmmmmm"""############~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..........~~~........~~~~~~
======="""""""...."""""""""""tttttttttttttttmmmmmmTTTT!mmmm""""###########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......................~~~~
======="""""......"""""...""tttttttttttttttttmmmmTTTTT!!Gm""""""##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......~~~~~~~...........................~
========"".........""".....tttttttttTTTTTtttttmmTTTTT!!!!!!.."""##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.........~~~~~~..............!!....------.~
=======........!!!........BTtttttttTT!4!TTTTTTTTTTTTTT!!!!!..."""#########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.........~~~~~~............!!!!.----....--~
===~~~.........!!!....A....TTTtttTTTT!!!TTTTTTTTTTTTT!!!!!!......#########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.............~~~~~.......^^^!!!.--.........~
~~~~~||.......!!!!&&........TTTTTTTTTT!TTTTTTTTTTTTT!!!!!!.......########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.............~~......TT^^^^!!^--..........~
~~~~|||.......!!!&&&&...T........TTTTTTTTTTTTTTTTT....!!!.....T..########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....^^............TTT^^^^^^^T...........~
~~~|||........!!!&&&&..1TT........TTTTTTTTTTTT-!!.............T..########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....^^TT...........TTT^^^^^^TT...........~
~~||||...TT...!!!&&&...TTT...................--!!............TT...-#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~...!!^TTTTTT........TTT^^^^^TTTT.........~~
~~||||..TTTTT.!!!&&&.........................-!!!............TTT..-#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~...!!!^TTTTT........TTTT^^^^^TTTT.........~~
~~||||.TTT^^T..!!............................-!!..........T.TTTT..-#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....!!!TTTTT.........TTT^^^^^^TTTT........~~~
~~||||TTT^^^T.............vv................--!!..........TTTTTT.--#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....!!!...............TTT^^^^^^TTTT........~~~
~~|||.TT^^^^C..............vv...!!!.........-!!...........TTTTTT.-.#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....!!!..............TT^^^^^^^^TTTT........~~~
~~|||.TT^^^^.............Dvvvv.!!!!!.......)))).............TTT..-..####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......!!...............T^^^^^^^^^TTTTT......~~~~
~~E||.TT^^3^............vvvvvvvvv!!!......)))))))............TT..-...###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....................--^^^^^^^^^.TTTTT......~~~~
~~|||..T^^^^............vvv**vvvvv!!......))))))))...............-...##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~................------..^^.(.^TTTT.TT.......~~~~
~~|||..TT^^^.............vv**vvvvv!!......))))))))...............--....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..............---..........(..TTT..TT........~~~
~~|||.TT.^^-..............vvvvv!!!!!......))))T)))................-.....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.............--............((.T.....T........~~~
~~|||.TT...--............vvvvvvv!!!........))TTT))................---...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.........----TT...........(((..............~~~~
~~|||.T.....--...........vv..vv!!!..........TTTTT-................-.---.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......--TTTTT...........((((.............~~~~
~~|||.......T--TT........v.....!!...........TTTTT--........&&.....-...---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......--!!TTT...........(((((..............~~~
~~~|.......TTT-TTT............................T...--.....&&&&&&...-.&&...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....-!!!.TT............((((..............~~~
~~~........TTT-TTT.................................-....&&&&&&&&.--.&&...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....-!!................!!(...........ww..~~~
~~~~.......TT---TT.................................-....&&&&&&&&--..&&..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~------!.........~.....!!!-..........wwww~~~~
~~~~~..~...TT-T--..................................-....&&&&&&&--...&&..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......-..........~~....!!!-..........wwww~~~~
~~~~~~~~....--TT-.........................TT.......-.......&&&&-....&&.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......-..........~~~...!!-...........wwww.~~~
~~~~~~~~~..--TTT-.......................TTTT.......--.......&--.....&&.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......--.........~~~...!!-............www..~~
~~~~~~~~~~--....-...~~.................TTTT.........-.......--.....!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......-.........~~~....!-............6ww..~~
~~~~~~~~~~-TTT..--~~~~................TTTTT.........~......--....!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......-.........~~~....--............www..~~
~~~~~~~~~~TTTTT...~~~................T____T........~~~....2-....!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......-.........~~~...--............wwwww.~~
~~~~~~~~~..TTTTTTT~~~..............~.T_{{__........~~~..----....!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....~-........~~~~----.............wwwww.~~
~~~~~~~~...&&TTTTT~~~~.....~~~..~~~~~T_{{{_........~~~~~~.-....!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~.........~~~~..................www.~~~
~~~~~~~~...&&-..TT~~~~~~~~~~~~~~~~~~~~__{{{.......~~~~~~~.-....!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.........~~~.......................~~~
~~~~~T~~..&&--!...~~~~~~~~~~~~~~~~~~~~~___{{.....~~~~~~~~---..!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~........~~~~.....^^^................~~
~~~~~TTTT.&&-5!!..~~~~~~~~~~~~~~~~~~~~~~T_{{{{~~F~~~~~~~~-.-..!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......~~~~......^^^................~~
~~~~~TTTT.&&-!!...~~~~~~~~~~..~~~~~~~~~~~~..{{~~~~~~~~~~~~.-...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~......~~~~||....^^...............^...~
~~~~~TTT...----...~~~~~~~~~....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....~~~~||..............||||....^^..~
~~~~~~TT...-..----~~~~~~~~.T^^..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~T!..~~~~~~~..~~~~|||..............|||||...^^.^~
~~~~~~~~...-...!!~~~~~~~~..^^^^.~~~~~~~~~~~~~~~~~~~{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.T!!..~~~~~~..~~~||||.............||||||...^^^^~
~~~~~~~~~~--.!!!!~~~~~~~~.^^^^^.~~~~~~~~~~~~~~~~~~{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~TT!!!.~~~~~.~~~~|||p||...........|||p|||..^^^^^~
~~~~~~~~~~~~~~~~~~~~~~~~~.^^^^^.~~~~~~~~~~~~~~~~~~~{{{H~~~{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##T.!!.~~~~~~~~~~||||p||||||....|||||||||..^^^^^~
~~~~~~~~~~~~....~~~~~~~~~.T^^^T.~~~~~~~~~~~~~~~~~~~{{{{{{{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#TT.!.~~~~~~~~~~||||p|p|||||||||||||||||....^^~~
~~~~~~~~~.........~~~~~~~~.TTT..~~~~~~~~~~~~~~~~~~~~{{{{{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###.!.~~~~~~~~~~|||p||||||||||||||||||||....~~~~
~~~~~~~~~..........~~~~~~~~T..~~~~~~~~~~~~~~~~~~~~~~~~~{{~~~~~~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##~~~~~~~~~~~~~||p||||||p|||||||||||||....~~~~
~~~~~~~~~~.........~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||pp||p|||||pp||||||p|||||....~~
~~~~~~~~~~~~..||...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||||||||||||||||||||||||....~~
~~~~~~~~~~~~||||||..~~~~~~||||||||~~~~~~~~|||||||~~~~~~~~~~~~|{{{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||||||||||||qq||||p||||||||||||||~~
~~~~~~~~~~~~|||||||||~~~~|||||||||~~~~|||||||||||~~~~~~~~~~~~||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||||||||||||qqqqq|||||||||||||||||~~
~~~~~~~~~~~~|||||||||~~~|||||||||||||||||||||||||~~~~~~~~~~~|||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||||p|||||||qqq||||||||p(((||||||~~~
~~~~~~~~~~~~|||||||||||||||||||||||||||||||||||||~~~~~~~~~~~|||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||||||||||qq|||||||||||((((||||~~~~
~~~~~~~~~~~~||p|p|||||||||||qqqq||||||||||||||||||~~~~~~~~~|||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||||||||qqqqqq|||||||p((p||~~~~~~
~~~~~~~~~~~||||||||||p||||qqqqqqqq||||||||||||||||~~~~~~~~~|||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||p||||||qqqqqq|||||||||||~~~~~~~~
~~~~~~~~~~~||||||||||pp||qqqqqqqqqq|||||||p||||||||~~~|||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||||||||qqqqqq||||||||||~~~~~~~~
~~~~~~~||||||||||p||||p||qqqqqqqqqqq|pp|||p||||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||~~~||||||q||||||||||||||~~~~~~
~~~~~~|||||||p|||||||pp|qqqqqqqqqqqqq|p|||||||||pp||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||||||||||p||p|||||~~~~~
~~~~~||||||||p||||||||||qqqqqT...qqqqq||||||||||||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||p|||||p||||||||p|~~~~~
~~~~~|||||||||||||||||||qqqqT.....qqqq|||||||||||||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||||||||||||||||~~~~
~~~~~|||||p|||||||((||||qqqqT.((..Tqqqq|||||||||||||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||||||||||||~|||||~~~~
~~~~~||||||||||ppp(((|||qqqqT.(..TTqqqqqqqq|||||||p|||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||||~||||||||~~||||~~~~
~~~~~~||||||||pppp(((|||qqqqTTT..TTqqqqqqqqq||||||||||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|||~~~~|||||~~~~~~~~~~~
~~~~~~~|||||||p(p(((||||qqqqqqqTTqqqqqqqqqqqqq|||||||||||||||||||||||||~||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~||||||p(((((|||||qqqqqqqqqqqqqqqqqqqqqqq|||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~|||||pp(((||||p|||qqqqqqqqqqqqqqqqqqqqq|||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~||||||||||||||||ppqqqqqqqqqqq|||qqqqqqqq||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~||||||p||||pp||||p|||qppp||||pp||||qqqqqq|||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~|||||||||||||||||||||||||||||||||||||qqqq||||||||||||||||||||||~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]