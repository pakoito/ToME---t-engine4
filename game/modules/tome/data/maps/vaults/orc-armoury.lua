-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 0
starty = 5

defineTile(' ', "FLOOR")
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=5}})
defineTile('+', "DOOR")
defineTile('!', "DOOR_VAULT")
defineTile('#', "HARDWALL")

defineTile('a', 'FLOOR', nil, {random_filter={name='hill orc archer', add_levels=15}})
defineTile('i', 'FLOOR', nil, {random_filter={name='icy orc wyrmic', add_levels=10}}) -- will be generated with escorts, so leave some space free
defineTile('f', 'FLOOR', nil, {random_filter={name='fiery orc wyrmic', add_levels=10}}) -- will be generated with escorts, so leave some space free
defineTile('o', 'FLOOR', nil, {random_filter={name='orc', add_levels=10}})
defineTile('O', 'FLOOR', nil, {random_filter={name='orc', add_levels=20}})
defineTile('n', 'FLOOR', nil, {random_filter={name='orc master assassin', add_levels=10}})
defineTile('N', 'FLOOR', nil, {random_filter={name='orc grand master assassin', add_levels=15}})

defineTile('m', 'FLOOR', {random_filter={type='weapon', subtype='mace', add_levels=10, tome_mod="gvault"}})
defineTile('M', 'FLOOR', {random_filter={type='weapon', subtype='greatmaul', add_levels=10, tome_mod="gvault"}})

defineTile('x', 'FLOOR', {random_filter={type='weapon', subtype='axe', add_levels=10, tome_mod="gvault"}})
defineTile('X', 'FLOOR', {random_filter={type='weapon', subtype='battleaxe', add_levels=10, tome_mod="gvault"}})

defineTile('s', 'FLOOR', {random_filter={type='weapon', subtype='sword', add_levels=10, tome_mod="gvault"}})
defineTile('S', 'FLOOR', {random_filter={type='weapon', subtype='greatsword', add_levels=10, tome_mod="gvault"}})

defineTile('b', 'FLOOR', {random_filter={type='weapon', subtype='longbow', add_levels=10, tome_mod="gvault"}})
defineTile('B', 'FLOOR', {random_filter={type='ammo', subtype='arrow', add_levels=10, tome_mod="gvault"}})

defineTile('w', 'FLOOR', {random_filter={type='weapon', subtype='sling', add_levels=10, tome_mod="gvault"}})
defineTile('W', 'FLOOR', {random_filter={type='ammo', subtype='shot', add_levels=10, tome_mod="gvault"}})

defineTile('k', 'FLOOR', {random_filter={type='weapon', subtype='knife', add_levels=10, tome_mod="gvault"}})

defineTile('t', 'FLOOR', {random_filter={type='weapon', subtype='mace', add_levels=10, tome_mod="gvault"}}, {random_filter={type='giant', subtype='troll', add_levels=10}})
defineTile('T', 'FLOOR', {random_filter={type='weapon', subtype='greatmaul', add_levels=10, tome_mod="gvault"}}, {random_filter={type='giant', subtype='troll', add_levels=15}})

return {

[[#########################]],
[[##aa#ooo+xx#BBBB#OOO#knk#]],
[[##  #oOo#xx###bb+ f #nNn#]],
[[##  #oOo#XXXX#bb#   #knk#]],
[[##^^##+###########+###+##]],
[[!                      ^#]],
[[##^^##+###########+###+##]],
[[##  #OoO#SSSS#ww#   #TtT#]],
[[##  #ooo#ss###ww+ i #ttt#]],
[[##aa#ooo+ss#WWWW#OOO#TtT#]],
[[#########################]],

}
