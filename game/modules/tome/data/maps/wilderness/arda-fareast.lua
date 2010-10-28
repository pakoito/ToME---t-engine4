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

-- The far east on Arda

quickEntity('w', {always_remember = true, show_tooltip=true, name='Sun Wall', display='^', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/mountain.png", tint=colors.GOLD, block_move=true})
quickEntity('=', {always_remember = true, show_tooltip=true, name='the great sea', display='~', color=colors.DARK_BLUE, back_color=colors.BLUE, image="terrain/river.png", block_move=true, can_encounter="water", shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity(' ', {always_remember = true, show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter="plain", equilibrium_level=-10})
quickEntity('~', {always_remember = true, show_tooltip=true, name='river', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter="plain", equilibrium_level=-10, can_encounter="water", shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity('s', {always_remember = true, show_tooltip=true, name='desert', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10})
quickEntity('t', {always_remember = true, show_tooltip=true, name='forest', display='#', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha1.png"}}, block_move=true})
quickEntity('p', {always_remember = true, show_tooltip=true, name='oasis', display='#', color=colors.LIGHT_GREEN, back_color={r=163,g=149,b=42}, image="terrain/sand.png", add_displays = {mod.class.Grid.new{image="terrain/palmtree_alpha1.png"}}, block_move=true})
quickEntity('m', {always_remember = true, show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('h', {always_remember = true, show_tooltip=true, name='low hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter="plain", equilibrium_level=-10})
quickEntity('.', {always_remember = true, show_tooltip=true, name='road', display='.', color=colors.WHITE, back_color=colors.DARK_GREEN, image="terrain/marble_floor.png", can_encounter="plain", equilibrium_level=-10})


quickEntity('A', {always_remember = true, show_tooltip=true, name="Sun Wall Outpost (Town)", display='*', color=colors.GOLD, notice = true, change_level=1, change_zone="town-sunwall-outpost"})
quickEntity('B', {always_remember = true, show_tooltip=true, name="High Peak", display='>', color=colors.VIOLET, notice = true, change_level=1, change_zone="high-peak"})

quickEntity('1', {always_remember = true, show_tooltip=true, name="Gates of Morning", desc="A massive hole in the Sun Wall", display='*', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/gate-morning.png", tint=colors.GOLD, notice = true, change_level=1, change_zone="town-gates-of-morning"})

-- The shield protecting the sorcerer hideout
local p = getMap():particleEmitter(43, 25, 3, "istari_shield_map")

-- Load encounters for this map
prepareEntitiesList("encounters", "mod.class.Encounter", "/data/general/encounters/arda-fareast.lua")
addData{ encounters = {
	chance=function(who)
		local harmless_chance = 1 + who:getLck(7)
		local hostile_chance = 2
		if rng.percent(hostile_chance) then return "hostile"
		elseif rng.percent(harmless_chance) then return "harmless"
		end
	end},
	istari_shield = p,
}

return [[
mmmttttttttttttttttttttttttttttttttt~tttttttttttttttttttttttttttttttttttttttttmmm
m mmmttttttttttttttt  thhhttttttt ~~~tttttt           t  ttttttttt    ttt     mmm
m mmmmmmmhh    tttt tthhhhttttt ~~~ttttt     mmmmmm    tt tttt    tttt t ttttmmmm
mm  mmmhh     tttttt thhhhhtttt ~tttttt       mmmmmmmmtttt    ttttttttt ttttmmmmm
mmmm hh        ttttt ttttttttt ~~ttttt           mmmmmmmtttttt ttttttmmmmmmmmmmmm
hhhhh             t ttttt      ~                    mmmmmmmtttt tttmmmmmmmmmmmmmm
tttt                          ~~                      mmmmmmmmtt ttmmmmmmhhmmmmmm
ttt                      =====~                 hh         mmmmt tmmmmmmhtthmmmmm
ttt  tttt           ~~~~=tt=====            hhhhhh          mmmmmmmmmmmhttthmmmmm
ttt ttttt         ~~~  = h ======           hhhhh                mmmmhhttt  hmmmm
ttttttttt         ~    == ========.........................     mmmmhttt   thmmmm
ttttttttt        ~~    ==========~~~                      .     mmmhttt    tthmmm
ttttttttt       ~~      ===  ==    ~~~                    .    mmmmhttt   ttthmmm
ttttttt         ~                    ~~~~~~               .   mmmmmmhtttttttthmmm
=tttt           ~                         ~~~     m       .   mmmmhhtttttttttthmm
===             ~~~                              mm  tt   .........   tttttttthmm
=====             ~~~~                          mmmttt    .   hhh .     ttttthmmm
======               ~                        mmmmttt     .    hh .      tttthmmm
=======              ~~                     mmmmtttt      .   hhh .        hhmmmm
========              ~~                  mmmmttttt       .........       hmmmmmm
=========     hhh      ~~ tt       tttttttmmmtttttt........hhhhhhh.      hmmmmmmm
==========   hhhh       ~~ tttttttttttttmmmmmtttttthhhh   hmmmhhh..      hmmmmmmm
==========   hhhh        ~~ttttttttttttmmmmmmmmtmmmmmmmmhhmmhhhhh.       hmmmmmmm
=========    hhh          ~~ttttttttttmmmmmmmmmmmmmhhhmmmmmmhhh...       hmmmmmmm
=========                  ~ttttttttttmmmmmmmmmmttt     mmm.....         mmmmmmmm
========                ~~~~~~~~tttttt~~mmmBmmmmttt ........            mmmmmmmmm
=======              ~~~~      ~~~~~~~~ttmmmmmmmtttt.                  mmmmmmmmmm
======            ~~~~             tttttttmmmmmmtttt.                  mmmmmmmmmm
=====           ~~~                ttttttmmmmmmmmttt.                 wwhhhhhhhhm
=====        ~~~~                    ttttmmmmtmmmh...              w  wwwhhhhhhmm
====~~~~~~~~~~                         mmmmtttttmhthmmm           wwwwwwwwhhhmmmm
=====                                  mmtttttttthmmmh           hwwwwwwwwhhmmmmm
=====                                 mmm.........mm             hwwwwwww  hmmmmm
=====                                 mm..       .               hwwwwwww  hmmmmm
======    ...........................mm..        .               hwwwwww   hmmmmm
========  .       ==               hhhhhhhhhh.....................1wwwwhh   hmmmm
=====================              mhhhhhhhh     .               hwwwwwhh   hmmmm
======================            mm.     h      .               hwwwwhh    hmmmm
======================          mmm..            . hh             wwwwh      hmmm
========== ==========         hmmmm.             . hhh            hwwh       hmmm
=======h   ==========        hmmmtt.t            .hhhh            hww        hmmm
=====hh     ==========      hmmmttt.tttt         .hh               wh         hmm
======mm    ===========    hhmmmttt.tttttt       .                            hmm
======tttmm A==========   hmmmmmttt.ttttttt      .                             hm
======ttt=mm=========     hmmmmsttt.tttttttt     .          sssssss             m
=======t============    hhmmmmsspss.tttttttt     .      sssssssssssssssssssssssmm
=================tttttthmmmmmsspssp.ssp         .. ssssssssssssssssssssssssssmmmm
===============tttttttthmm mmssssss.ssssssssssss.sssssssssssssssssssssssssmmmmmmm
==============tttttttt ttmhmmssssss.ssssssssssss.sssssssssssssssssss.....mmmmmmmm
==========  tttttttttt ttmhmmssssss...............p.............p....mmmhmmmmmmmm
========       tttttttt thmmmsssssssssssssssmmms.sssssssssssssssssssmmmmhmmmmmmmm
======= ttttttt tttttt t tmmmmsssssssssspssmmmmm.ssssssssssssssssssmmmmhmm   mmmm
=====  ttttttttt tttt ttthmmmmssssssssssssmm.....sssssspssssssssssmmmmhmm   mmmmm
==   ttttt  tttt tttt ttmmhh mmmssssssssssmmmmmmsssssssssssssssssmmmmmhmm   mmmmm
=   t       ttttt tt tttmmmmmmmmmmmssssssmmmmmmmmssssssmmmmmmmmmmmmmmmmhm  mmmmmm
=   tttttttttttttt  tttmmmmmmmmmmmmmmmmmmmmmmmmmsssmmmmmmmmmmmmmmmmmmmmmhh mmmmmm
ttttttttttttttttttttttmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm]]