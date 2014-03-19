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

-- defineTile section
defineTile(".", "CAVEFLOOR")
defineTile(',', "CAVEFLOOR", nil, nil, nil, {no_teleport=true})
defineTile(';', "CAVEFLOOR", nil, nil, nil, {lite=true, no_teleport=true})
defineTile("#", "CAVEWALL")
defineTile("+", "CAVE_DOOR")
defineTile("<", "CAVE_LADDER_UP")
defineTile("v", "CAVEFLOOR_VAULT_ENTRANCE")
defineTile("1", "CAVEFLOOR_VAULT_TRIGGER")
defineTile("d", "CAVEFLOOR_DOG_VAULT")
defineTile("W", "CAVEFLOOR", nil, "CORRUPTED_WAR_DOG")
defineTile("C", "CAVEFLOOR", nil, "SHADOW_CASTER")
defineTile("S", "CAVEFLOOR", nil, "SHADOW_STALKER")
defineTile("L", "CAVEFLOOR", nil, "SHADOW_CLAW")
defineTile('$', "CAVEFLOOR", {random_filter={add_levels=10,type="money"}}, nil, nil, {lite=true})
defineTile("*", "CAVEFLOOR", {random_filter={add_levels=10,ego_chance=70}}, nil, nil, {lite=true})
defineTile("K", "CAVEFLOOR", nil, "KYLESS", nil, {lite=true})

addSpot({11, 4}, "vault1", "encounter")
addSpot({4, 5}, "vault1", "encounter")
addSpot({3, 7}, "vault1", "encounter")
addSpot({14, 7}, "vault1", "encounter")
addSpot({8, 9}, "vault1", "encounter")
addSpot({13, 10}, "vault1", "encounter")
addSpot({11, 11}, "vault1", "encounter")

startx = 2
starty = 23

-- addSpot section

-- addZone section

-- ASCII map section
return [[
####################################
####################################
#############...####################
######........#..d#,,,,,W..W,,######
######..#######..d+,,,,,,,W,,,,#####
#####....#...###.d#,,W,,,,,,W,,#####
###...$.......#########,############
###.....1111..$.#######,############
##..$...1**1....#######,############
#.......11*1.$#######,,#############
##..$....111...####,,,,,,###########
###............###,,################
######+###....###,,#,,,,############
######v###########,,,,#+#;;;########
#####...###############;#;;;########
####.....#########;;;;;;;;;;;;######
####.......######;;#;;;#;;;;#;;#####
#####.....######;;;;;;;#;;;;;;;#####
###.......####;;;;#;;;;;;;#;;;######
####......######;;;;;;;;;;;;;;;#####
#####...#########;;;;;;;;;#;;#######
######....######;;;;#;;K;;;;;;;#####
####L#..########;;;;;;;;;;;;;;;#####
##<....#########;;;;;;#;;;;#;;;;####
#####L##############;;;;;#;;;;;#####
########################;;;;;#######
####################################
####################################
####################################
####################################]]