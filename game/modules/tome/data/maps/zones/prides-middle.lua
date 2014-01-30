-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

startx = 15
starty = 8
endx = 0
endy = 8

-- defineTile section
defineTile("#", "HARDWALL")
defineTile("o", "FLOOR", nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.pride end}})
quickEntity("g", 'o')
defineTile("+", "DOOR")
if level.level == 1 then defineTile("<", "UNDERGROUND_LADDER_UP_WILDERNESS") else defineTile("<", data.up) end
defineTile(">", data.down, nil, nil, nil, {no_teleport=true})
if level.level == 1 then defineTile("O", "FLOOR", nil, {random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.pride end, random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, rank=3.5,}}})
else quickEntity('O', 'o') end
defineTile(".", "FLOOR")
defineTile(";", "FLOOR", nil, nil, nil, {no_teleport=true})
defineTile(" ", "FLOOR", nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.pride end, random_boss={nb_classes=1, loot_quality="store", loot_quantity=1, no_loot_randart=true, rank=3}}}, nil, {no_teleport=true})

defineTile('*', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_action=2, lever_action_value=0, lever_action_kind="pride-doors"}, {type="lever", subtype="door"})
defineTile('&', "GENERIC_LEVER", nil, nil, nil, {lever=1, lever_kind="pride-doors", lever_spot={type="lever", subtype="door"}})


-- addSpot section

-- addZone section

-- ASCII map section
return [[
################
################
####&.....oo####
####......oo####
######....######
####........####
###..........###
###..#o.. #..###
>O*...o.. .....<
###..#o.. #..###
###..........###
####........####
######....######
####......oo####
####&.....oo####
################]]