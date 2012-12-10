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

-- Horror Chamber

setStatusAll{no_teleport=true, vault_only_door_open=true}

startx = 2
starty = 1

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

-- tiles
defineTile('.', "OLD_FLOOR")
defineTile('#', "OLD_WALL")
defineTile(' ', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('+', "DOOR")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})

-- monsters
defineTile('o', 'FLOOR', nil, {random_filter={subtype='orc', add_levels=10}})
defineTile('h', 'OLD_FLOOR', nil, {random_filter={subtype='eldritch', add_levels=20}})
defineTile('c', 'OLD_FLOOR', nil, {random_filter={subtype='temporal', add_levels=20}})
defineTile('b', 'OLD_FLOOR', nil, {random_filter={name="bloated horror", add_levels=20}})

-- loots
defineTile('a', "OLD_FLOOR", {random_filter={type="armor", add_levels=10, tome_mod="vault"}}, nil)
defineTile('w', "OLD_FLOOR", {random_filter={type="weapon", add_levels=10, tome_mod="vault"}}, nil)
defineTile('r', 'OLD_FLOOR', {random_filter={add_levels=20, tome_mod="vault"}})
defineTile('t', 'OLD_FLOOR', {random_filter={add_levels=20, tome_mod="gvault"}})

-- monster + loots
defineTile('l', 'OLD_FLOOR', {random_filter={add_levels=20, tome_mod="vault"}}, {random_filter={subtype='eldritch', add_levels=20}})
defineTile('H', 'OLD_FLOOR', {random_filter={add_levels=20, tome_mod="gvault"}}, {random_filter={name="headless horror", add_levels=20}})
defineTile('R', 'OLD_FLOOR', {random_filter={add_levels=20, tome_mod="gvault"}}, {random_filter={name="radiant horror", add_levels=20}})

return {
[[                    ]],
[[XX!XXXXXXXXXXXXXXXXX]],
[[Xo oX o   oX.a.wXooX]],
[[Xo  +  o   +....+  X]],
[[X o Xo  o  Xa.wwX  X]],
[[X############..####X]],
[[Xhc.#h.l##h##ab#.hrX]],
[[Xr.r..h.#crc#..#.l#X]],
[[Xl#..#..#....bw..##X]],
[[Xl..h...#.####...h.X]],
[[X###..######.r..h##X]],
[[X##..##....c..#####X]],
[[X###.r..#######tltlX]],
[[X##c..####rrhr.r.rcX]],
[[X####.##lth.#..R..tX]],
[[XtHt#..#tt.rl...r.lX]],
[[Xttt##.###b....#...X]],
[[X.####.#####.##b...X]],
[[Xr..#..r.r#...###.lX]],
[[Xr.l..#...c.#..h.r#X]],
[[XXXXXXXXXXXXXXXXXXXX]],
}
