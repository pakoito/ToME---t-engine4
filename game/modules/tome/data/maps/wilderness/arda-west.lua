-- ToME - Tales of Middle-Earth
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

-- The western parts of Middle-earth on Arda

quickEntity('a', {show_tooltip=true, name='Ephel Duath', display='^', color=colors.LIGHT_DARK, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('d', {show_tooltip=true, name='Haradwaith', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", block_move=true})
quickEntity('b', {show_tooltip=true, name='blue mountains', display='^', color=colors.LIGHT_BLUE, back_color=colors.BLUE, image="terrain/mountain.png", block_move=true})
quickEntity('m', {show_tooltip=true, name='misty mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('f', {show_tooltip=true, name='grey mountains', display='^', color=colors.SLATE, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('u', {show_tooltip=true, name='deep forest', display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/tree.png", block_move=true})
quickEntity('t', {show_tooltip=true, name='forest', display='#', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/tree.png", block_move=true})
quickEntity('l', {show_tooltip=true, name='Lorien', display='#', color=colors.GOLD, back_color=colors.DARK_GREEN, image="terrain/lorien.png", block_move=true})
quickEntity('v', {show_tooltip=true, name='old forest', display='#', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/tree_dark1.png", block_move=true})
quickEntity('i', {show_tooltip=true, name='iron mountains', display='^', color=colors.SLATE, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('=', {show_tooltip=true, name='the great sea', display='~', color=colors.DARK_BLUE, back_color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('.', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('g', {show_tooltip=true, name='Forodwaith, the cold lands', display='.', color=colors.LIGHT_BLUE, back_color=colors.BLUE, can_encounter=true, equilibrium_level=-10})
quickEntity('q', {show_tooltip=true, name='Icebay of Forochel', display=';', color=colors.LIGHT_BLUE, back_color=colors.BLUE, can_encounter=true, equilibrium_level=-10})
quickEntity('w', {show_tooltip=true, name='ash', display='.', color=colors.WHITE, back_color=colors.LIGHT_DARK, image="terrain/ash1.png", can_encounter=true})
quickEntity('&', {show_tooltip=true, name='hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter=true, equilibrium_level=-10})
quickEntity('h', {show_tooltip=true, name='low hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter=true, equilibrium_level=-10})
quickEntity(' ', {show_tooltip=true, name='sea of Rhun', display='~', color=colors.BLUE, back_color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('_', {show_tooltip=true, name='river', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter=true, equilibrium_level=-10})
quickEntity('~', {show_tooltip=true, name='Anduin river', display='~', color={r=0, g=30, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter=true, equilibrium_level=-10})
quickEntity('-', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('|', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('x', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter=true, equilibrium_level=-10})
quickEntity('s', {show_tooltip=true, name='dead marches', display='~', color=colors.DARK_GREEN, back_color=colors.DARK_GREEN, can_encounter=true})
quickEntity('"', {show_tooltip=true, name='the valley of Nurn', display='.', color=colors.WHITE, back_color=colors.LIGHT_DARK, image="terrain/ash1.png", can_encounter=true})

quickEntity('A', {show_tooltip=true, name="Caves below the tower of Amon Sûl", 	display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="tower-amon-sul"})
quickEntity('B', {show_tooltip=true, name="Passageway into the Trollshaws", 	display='>', color={r=0, g=255, b=0}, notice = true, change_level=1, change_zone="trollshaws"})
quickEntity('C', {show_tooltip=true, name="A gate into a maze", 			display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="maze"})
quickEntity('D', {show_tooltip=true, name="A path into the Old Forest", 		display='>', color={r=0, g=255, b=155}, notice = true, change_level=1, change_zone="old-forest"})
quickEntity('E', {show_tooltip=true, name="A mysterious hole in the beach", 	display='>', color={r=200, g=255, b=55}, notice = true, change_level=1, change_zone="sandworm-lair"})
quickEntity('F', {show_tooltip=true, name="The entry to the old tower of Tol Falas",display='>', color={r=0, g=255, b=255}, notice = true, change_level=1, change_zone="tol-falas"})

quickEntity('1', {show_tooltip=true, name="Bree (Town)", desc="A quiet town at the crossroads of the north", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-bree"})
quickEntity('2', {show_tooltip=true, name="Minas Tirith (Town)", desc="Captical city of the Reunited-Kingdom and Gondor ruled by High King Eldarion", display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-minas-tirith"})

-- Angolwen is only know from the start to mages
if game.player.descriptor.class == "Mage" then
	quickEntity('3', {show_tooltip=true, name="Angolwen, the hidden city of magic", desc="Secret place of magic, set apart from the world to protect it.", display='*', color=colors.WHITE, back_color=colors.UMBER, image="terrain/town1.png", notice = true, change_level=1, change_zone="town-angolwen"})
else
	quickEntity('3', 'b')
end

-- Load encounters for this map
prepareEntitiesList("encounters", "mod.class.Encounter", "/data/general/encounters/arda-west.lua")
addData{ encounters = {
	chance=function(who)
		local harmless_chance = 1 + who:getLck(7)
		local hostile_chance = 5
		print("chance", hostile_chance, harmless_chance)
		if rng.percent(hostile_chance) then return "hostile"
		elseif rng.percent(harmless_chance) then return "harmless"
		end
	end}
}

return [[
========q=qqqqqqqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
=========q=qq=qqqqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
==========qq=q=qqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
==============qqq=qqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
===============q=q=q=gwwwwgggwwwwwgggggggggwwwwwwwwwwggggwwwwwwwwwwwwwggggwwwwwwwwggggwwwwwwwwwgggg
====================qwwwwwwwwwwwwwwwwggggggggwwwwwwwwwwwwwwwwwwwwwwwwwwggwwwwwwwwwwwwwwwwwwwwwwuuuu
======================wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuu
========================wwwwwwww...wwwwwwwwww..........wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuuuuu
========================..www....wwwwwwww................wwwwffffwwwwwwww......wwwww.uuuuuuuuuuuuuu
==========.......======.........hhhh..................fffffffwwwwwwww.........wwww.utuuuutuuuuuutuu
========......bb..===.........hhhhhhhh..&&&&&...&..fffffffffffff.................tuuututuututtuuuut
=======......bb..===............hhhh.......&&&&&&ff.._._...........................tttttttttttttttt
======...._.bb._..._..h.........................m....._._uuu................ii........ttttttttttttt
=======.._..bb.._.._..hhhh................&....&mm~~~~.uu_uuuu..........i.....iii........tttttthhhh
======.._...bb..._._..hhh.......hhhhhh.....&&&&._mm..~.uuu_u_uu..........iiiiii..............ttthhh
=====.._..ubbb...._._..h.=....hhh.hh..........__.mm__~.uuuu_h_uu..........._.....................hh
===...._....bb....._..hh.=_....h............__...mm..~.uuuuuu_uu.=........_........................
====.._...bbbb...._....hhhh__..........A..._.....mm..~.uuuuuu____........._........................
=====.._..uubb..._........._......h......._Btt...mm..~.uuuuu&&&u._........._.......................
====...__..ubbb._......hh.._.......hh...._.thhh._mm..~..uuu&&&&&u._........._......................
=====..._.....__......hhh.-_......1hh......._h...mm..~..uuuuuuuuu._........_.......................
======..==..=__....h....h..._.hh..ih....._..hhh._m...~..uuuuuuuuuu._........_......................
=============.....hhh......._.vvD.h......_.._.._mmm...~..uuuuuuuuu.._........_....................t
======........bb...h........._vvv.hh...._.._...mm.....~..uuuuuuuu...._......_....................tt
=====E........bb............._.v...h...._._..mmmmm..._~..uuuuuuuu....._......_..................ttt
=====.........bb............._........._.._..mmmm____.~~.uuuuuuuu......_.._._..................tttt
======.......bbb...Cb......._.........._._...mmmm.....~~.uuuuu.u........._.._.................ttttt
=======.....ub3b..bbbb....._..........._....mmmmm....~~...uuuu.............._...............ttttttt
==========..ubbbu........._..........._.....mmmm.....~~...uuuu..............._...._.......ttttttttt
==========..uuubbubb....._........____.....hmmmm....~~....uuuuuuu............._.__._ ...ttttttttttt
==========...uubuu......_........______....mmmmm....~~..uuuuuuuuuu............._....  ...t  ttttttt
==========.....u.u....._........_.....______mm___...~~.uuuuuuuuuu...................        ttttttt
===========.=........._........_...........mmmm_lll~~..uu&uuuuuuu..................         ttttttt
================....__........_..ttt......mmmm.llll~~..uuuuuuuuu...................         ...tttt
=================.==t........_....tt.....ttmmm.lll.~.....uuuuu..................hh.        ......tt
===================tt........._.........ttmmm.......~~.........................hhhh.       .......t
===================t==......._..........ttmmmttttt._..~~~~~~....................hhh.  ...  .......t
===================t==......_...........t&mmmmtttt___.....~~~..................hhhhh. ... ........t
=====================......_.ttt........t&mmmtttttt..__~~~~~...................hhhhhh.............t
=====================.....=_.tt.........&&mmmttttt.....~...........................hh.............t
======================...==..ttt........&&_&&&.._.......~~........................................t
=======================.===..............h_h....._........~.......................................t
===========================..............._........_.....~........................................t
==========================.tt......._._.._........_....h=hh...sss.................................t
==========================.tt._.._t_...__.........._..h===h.ssss.................................tt
==========================..__.__._._._..&&&b....._....h=hh..ss.a.a.............................ttt
============================....._..._.__.&&&......_....~~.....aaaaaa..a..aa..a..a..aa...a.....tttt
===========================.............._&&&hh....._....~~....aavvaaaaaaaaaaaaaaaaaaaaaaaaaaaaattt
===========================.......h.&.hh&&&&&&&......__.~~~~....aavvvvvvvavvvavaa_"""_""""""..aaatt
===========================.....hh.&.&_&h&.&h&_&&&....._..~~~...aavvmvvvvvvvvvva_"""""_""""""...aat
===========================....h....__hh...hhh._h&&........~~...aavvmmvvvvvvvaa_"""""""_"""".....aa
===========================..hhh_.._.......hh._.hh&&&........~~.aavvvvvvvvvvaa""_""""""_"""""""....
============================.ht_.__._........_&hhh.&&&&&........aavaavaaavvv"""""_""""_""""""".....
============================.th_..._....hh.._&&&hh.._&&&&.&...~.aaa""a"a""""""""=="""_""""""""""...
============================.th._.hhhhhhhh...__...._h&h&&&&&.~..aa""""""""""""======_"""""""""""aaa
===========================.hh._...h.h........._.._.h&hh._h2.~..aa"""_"_"""""=====""""""""""""aaaaa
==========================..hh.._.....===.=====_._&h...._...h.~.aa"__"_"__======"""""aa""""aaaadddd
==========================.h...._...=====F=====_&&h...._._...~~.aa_""""""""""""_""a"aaaaaaaaddddddd
========================.hhh=...=_.==========&hhhh.._._..._.~~..aaa""aaa""a"""aa_adaadddddddddddddd
======================....=====.==============h.h._=._.....~~...aaaaaaaaaaaaaaaaaaadddddddddddddddd
==============================================.hhh==....~~~~....................ddddddddddddddddddd
===============================================..====~~~~................dddddddddddddddddddddddddd
===============================================.==h==_............ddddddddddddddddddddddddddddddddd
=================================================hh===........ddddddddddddddddddddddddddddddddddddd]]
