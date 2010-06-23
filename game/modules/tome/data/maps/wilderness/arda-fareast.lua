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
quickEntity('=', {always_remember = true, show_tooltip=true, name='the great sea', display='~', color=colors.DARK_BLUE, back_color=colors.BLUE, image="terrain/river.png", block_move=true, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity(' ', {always_remember = true, show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/grass.png", can_encounter="plain", equilibrium_level=-10})
quickEntity('~', {always_remember = true, show_tooltip=true, name='river', display='~', color={r=0, g=80, b=255}, back_color=colors.BLUE, image="terrain/river.png", can_encounter="plain", equilibrium_level=-10, shader = "water", textures = { function() return _3DNoise, true end }, })
quickEntity('s', {always_remember = true, show_tooltip=true, name='desert', display='.', color={r=203,g=189,b=72}, back_color={r=163,g=149,b=42}, image="terrain/sand.png", can_encounter="desert", equilibrium_level=-10})
quickEntity('t', {always_remember = true, show_tooltip=true, name='forest', display='#', color=colors.LIGHT_GREEN, back_color=colors.DARK_GREEN, image="terrain/tree.png", block_move=true})
quickEntity('p', {always_remember = true, show_tooltip=true, name='oasis', display='#', color=colors.LIGHT_GREEN, back_color={r=163,g=149,b=42}, image="terrain/palmtree.png", block_move=true})
quickEntity('m', {always_remember = true, show_tooltip=true, name='mountains', display='^', color=colors.LIGHT_UMBER, back_color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('h', {always_remember = true, show_tooltip=true, name='low hills', display='^', color=colors.GREEN, back_color=colors.DARK_GREEN, image="terrain/hills.png", can_encounter="plain", equilibrium_level=-10})

quickEntity('A', {always_remember = true, show_tooltip=true, name="Sun Wall Outpost (Town)", display='*', color=colors.GOLD, notice = true, change_level=1, change_zone="town-sunwall-outpost"})
quickEntity('B', {always_remember = true, show_tooltip=true, name="Rak'shor Pride", display='>', color=colors.YELLOW, notice = true, change_level=1, change_zone="rakshor-pride"})
quickEntity('C', {always_remember = true, show_tooltip=true, name="Gorbat Pride", display='>', color=colors.YELLOW, notice = true, change_level=1, change_zone="gorbat-pride"})

quickEntity('1', {always_remember = true, show_tooltip=true, name="Gates of Morning", desc="A massive hole in the Sun Wall", display='*', color=colors.GOLD, back_color=colors.CRIMSON, image="terrain/gate-morning.png", tint=colors.GOLD, notice = true, change_level=1, change_zone="town-gates-of-morning"})

-- The shield protecting the istari hideout
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
=================================================================================
=================================================================================
===========       ========================    ===================================
========             ===================       ==================================
=======               ================          =================================
=====                 ================              =============================
====                  ===============                 ===========================
===                    ==========               hh    ===========================
==t  tttt           =============           hhhhhh          =====================
==t ttttt         ~==  ==========           hhhhh                ================
==ttttttt         ~    ===========                              =================
==ttttttt        ~~    ==========~~~                            =================
==ttttttt       ~~     ===  ===    ~~~                         ==================
==ttttt         ~       =            ~~~~~~                   ===================
===tt           ~                         ~~~                   =================
====            ~~~                                  tt            ==============
=====             ~~~~                             ttt              =============
======               ~                           tttt                  ==========
=======              ~~                       tttttt                    =========
========              ~~                     tttttt                      ========
=========     hhh      ~~ tt       ttttttt   tttttt             hh        =======
==========   hhhh       ~~ tttttttttttttmmmmmtttttt           hhh         =======
==========   hhhh        ~~ttttttttttttmmmmmmmmttttt        hhhhh         =======
=========    hhh          ~~ttttttttttmmmmmmmmmmtttt        hhh           =======
=========                  ~ttttttttttmmmmmmmmmmttt                      ========
========                ~~~~~~~~tttttt~~mmmmmmmmttt                     =========
=======              ~~~~      ~~~~~~~~ttmmmmmmmtttt                   ==========
======            ~~~~             tttttttmmmmmmtttt                   ==========
=====           ~~~                ttttttmmmmmmttttt                  ===========
=====        ~~~~                    ttttmmmmttttttt               w  ===========
====~~~~~~~~~~                         mmmmtttttttt               www============
=====                                  mmtttttttt                 www============
=====                                                             www============
=====                                                             www============
======                                                            www============
========          =======              hhhhhh                     1ww============
==============================       hhhhhhh                      www============
================================         h                        www============
=================================                  hh             www============
========== ======================                  hhh            www============
=======h   ======================tttt             hhhh            www============
=====hh     ====================tttttttt          hh               w  ===========
======mm    ====================tttttttttt                            ===========
======tttmm A===================ttttttttttt                            ==========
======ttt=mm===================stttttttttttt                sssssss    ==========
=======t======================sspssstttttttt            sssssssssssssss==========
=============================sspssppssp            ssssssssssssssssssss==========
=============================ssssssssssssssssssssssssssssssssssssssssss==========
=============================sssssssssssssssssssssssssssssssssssssssss===========
=============================ssssssssssssssssssssspssssssssssssspssss============
=============================sssssssssssssssssssssssssssssssssssssss=============
==============================sssssssssspssssssssssssssssssssssssss==============
==============================ssssssssssssssssssssssssspssssssssss===============
================================sssssssssssssssssssssssssssssssss================
===================================ssssssssssssssssssss==========================
============================================sssssss==============================
=================================================================================]]
