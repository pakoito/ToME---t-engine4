-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

startx = 49
starty = 24

defineTile("&", "TREE", nil, nil, nil)
defineTile(")", "GRASS", {random_filter={name="ash longbow"}}, nil, nil)
defineTile("s", "GRASS", nil, "TUTORIAL_NPC_MAGE", nil)
defineTile(",", "GRASS", nil, nil, nil)
defineTile("S", "GRASS", nil, {random_filter={type="animal", subtype="snake", max_ood=2}}, nil)
defineTile("T", "GRASS", nil, "TUTORIAL_NPC_TROLL", nil)
defineTile("L", "GRASS", nil, "TUTORIAL_NPC_LONE_WOLF", nil)
defineTile("1", "GRASS", nil, nil, "TUTORIAL_MELEE")
defineTile("|", "GRASS", {random_filter={name="quiver of elm arrows"}}, nil, nil)
defineTile("2", "GRASS", {random_filter={name="regeneration infusion"}}, nil, "TUTORIAL_OBJECTS")
defineTile("3", "GRASS", nil, nil, "TUTORIAL_TALENTS")
defineTile("4", "GRASS", nil, nil, "TUTORIAL_LEVELUP")
defineTile("~", "DEEP_WATER", nil, nil, nil)
defineTile("5", "DEEP_WATER", nil, nil, "TUTORIAL_TERRAIN")
defineTile("6", "GRASS", nil, nil, "TUTORIAL_TACTICS1")
defineTile("7", "GRASS", nil, nil, "TUTORIAL_TACTICS2")
defineTile("8", "GRASS", nil, nil, "TUTORIAL_RANGED")
defineTile("9", "GRASS", nil, nil, "TUTORIAL_QUESTS")
defineTile("j", "GRASS", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile(" ", "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("!", "GRASS", {random_filter={name="healing infusion"}}, nil, nil)
defineTile('"', "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("#", "DEEP_WATER", {random_filter={name="shielding rune"}}, nil, nil)

return [[
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~~&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~~&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~~&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~~&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&~~~,,,&&&&&&&&
&&&&&&&&&,,,,,&&&&&&&&&&&&&&&&&&~~&&~~~&&,,,&&&&&&
&&&&&&&&,T,,,,,,,,,,,,&&&&&&&&&&~~~~~~~&&&&,&&&&&&
&&&&&&&&,T,,,,,,,,,,,,,&&&&&&&&&~~~~~~&&&&&,&&&&&&
&&&&&&&&,T,,T,,,,,,,,,,&&&&&&&&&~~~&~~&&&&&,&&&&&&
&&&&&&&,,,,,T,,,,,,,,,,,&&&&&&&&&~~~~&&&s&,,&&&&&&
&&&&&&&,,T,,T,,,,,,,,,,,,,,&&&&&,~&~~&&&,,,,&&&&&&
&&&&&&&&,T,,,,,,,,,,,,,,,&,&&&,,,~~~~&&,,,,,!&&&&&
&&&&&&&&,T,,,,,,,,,,,,,,&&,|)8,&&&~~&&&&,,,,,&&&&&
&&&&&&&&,,,,,,,,,,,,,,,&&&&&&&&&&&&&&&&&,,,,,&&&&&
&&&&&&&&&,,,,,,,,,,,,,&&&&&&&&&&,,,,,,,,7,,,&&&&&&
&&&&&&&&&&&&&&,,,,,&&&&&&&&&&&&,,&&&&&&&,,,,&&&&&&
&&&&&&&&&&&&&&&,&&&&&&&&&&&&&&,,&&&&&&&&,,,&&&&&&&
&&&&&&&&&&&&&&&,&&&&&&&&&&&&&,,&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&,&&&&&&&&&&&&&,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&9&&&&&&&&&&&&&,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&,,&&&&&&&&&&&&,,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&,,&&&&&&&&&&&&&,&&&&&&&&,,,,,,,&&&&&&
&&&&&&&&&&&&&,&&&&&&&&&&&&&&,&&&&&&&,,j,,,,,,&&&&&
&&&&&&&&&&&&&,&&&&&&&&&&&&&&,&&&&&&,,,2,,,,,,1,,,,
&&&&&&&&&,,,,,,&&&&&&&&&&&&&,&&&,,,,,,j,,,,,&&&&&&
&&&&&&&&,,,,,,,,&&&&&&&&&&&&,&&&,&&&,,,,,,,,&&&&&&
&&&&&&&&,,,,,&,,,&&&&&&&&&&&,&&&,&&&&,,,,,,&&&&&&&
&&&&&&&,,&,,,,,,,,&&&&&&&&&&,&&&,&&&&&&&&&&&&&&&&&
&&&&&,,,,,,,,,&&,&,,&&&&&&&,,&&&,,&&&&&&&&&&&&&&&&
&&&&&&,,&,,,,,,,,,&,,&&&&&&,&&&&&,,&&&&&&&&&&&&&&&
&&&&&,,,,,,&&,,,,&,,&&&&&SSS&&&&&&,,,&&&&&&&&&&&&&
&&&&&&,,,,,,,,,,&,&&&&&&SSSSSS&&&&&&,,,&&&&&&&&&&&
&&&&&&,,&,&,,&&,,,&&&&&&SSSSSSS&&&&&&&,,j,j3,,&&&&
&&&&&&&,,,,,,&&&,&&&&&&SSSSSSSS&&&&&&&&&&&&&&j,&&&
&&&&&&&&,L,,,,,,,,&&&&&SSSSSS,,&&&&&&&&&&&&&&&,&&&
&&&&&&&,,,,,,&&&&&&&&&&&SSS,,,,&&&&&&&&&&&&&&&,,&&
&&&&&&&&&&&&&&&&&&&&&&&SS,,,!,&&&&&&&&&&&&&&&&&4&&
&&&&&&&&&&&&&&&&&&&&&&&&,,,,,,&&&&&&&&&~~~&&&&&,,&
&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,&&&&&&&&&~~~~~&&&&j&
&&&&&&&&&&&&&&&&&&&&&&&&&&,,,&&&&&&&&~~~~&~~ &&,,&
&&&&&&&&&&&&&&&&&&&&&&&&&&&6&&&&&&&&&~~~&&&~~~5,&&
&&&&&&&&&&&&&&&&&&&&&&&&&,,,&&&&&&,,,,~~~&~~~~&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&&&,&&&~~~~~~"~&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&,,,&&&&&&,&&&&~~~~~~&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&&,,&&&&&&&~~~&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,,&&&&&&&&&~&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&&&&&&&~&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&]]
