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

startx = 49
starty = 24

defineTile("&", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"}, nil, nil, nil)
defineTile("s", "GRASS", nil, "TUTORIAL_NPC_MAGE", nil)
defineTile(",", "GRASS", nil, nil, nil)
defineTile("S", "GRASS", nil, {random_filter={type="animal", subtype="snake", max_ood=2}}, nil)
defineTile("1", "GRASS", nil, nil, "TUTORIAL_MELEE")
defineTile("2", "GRASS", {random_filter={name="potion of lesser healing"}}, nil, "TUTORIAL_OBJECTS")
defineTile("3", "GRASS", nil, nil, "TUTORIAL_TALENTS")
defineTile("4", "GRASS", nil, nil, "TUTORIAL_LEVELUP")
defineTile("~", "DEEP_WATER", nil, nil, nil)
defineTile("5", "DEEP_WATER", nil, nil, "TUTORIAL_TERRAIN")
defineTile("6", "GRASS", nil, nil, "TUTORIAL_TACTICS1")
defineTile("7", "GRASS", nil, nil, "TUTORIAL_TACTICS2")
defineTile("?", nil, nil, nil, nil)
defineTile("j", "GRASS", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile(" ", "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("!", "GRASS", {random_filter={name="potion of lesser healing"}}, nil, nil)
defineTile('"', "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("#", "DEEP_WATER", {random_filter={name="potion of lesser healing"}}, nil, nil)

return [[
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&s&,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,!&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,,,,,,,7,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&&&&&,,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&&&&&&,,,&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&&&,,,,,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&!&&&&&&&,,j,,,,,,&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&&,,,2,,,,,,1,,,,
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&,,,,,,j,,,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&,&&&,,,,,,,,&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&,&&&&,,,,,,&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&,&&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&,,&&&,,&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&,&&&&&,,&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&&SSS&&&&&&,,,&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&SSSSSS&&&&&&,,,&&&&&&&&&&&
&&&&&&&&&&&&&&&&&&&&&&&&SSSSSSS&&&&&&&,,j,j3,,&&&&
&&&&&&&&&&&&&&&&&&&&&&&SSSSSSSS&&&&&&&&&&&&&&j,&&&
&&&&&&&&&&&&&&&&&&&&&&&SSSSSS,,&&&&&&&&&&&&&&&,&&&
&&&&&&&&&&&&&&&&&&&&&&&&SSS,,,,&&&&&&&&&&&&&&&,,&&
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
