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

--Hedrachi's "If You Don't Hate Orcs Now, You'll Hate Them After This" vault contest submission.

startx = 0
starty = 6

setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('u', mod.class.Grid.new{
	define_as = "DOOR_OPENING_FLOOR",
	type = "floor", subtype = "trapped_floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local g = game.zone:makeEntityByName(game.level, "terrain", "DOOR_OPEN")
		game.zone:addEntity(game.level, g, "terrain", x - 4, y - 4)
		game.zone:addEntity(game.level, g, "terrain", x + 4, y - 4)
		game.zone:addEntity(game.level, g, "terrain", x + 4, y + 4)
		game.zone:addEntity(game.level, g, "terrain", x - 4, y + 4)
		game.nicer_tiles:updateAround(game.level, x - 4, y - 4)
		game.nicer_tiles:updateAround(game.level, x + 4, y - 4)
		game.nicer_tiles:updateAround(game.level, x + 4, y + 4)
		game.nicer_tiles:updateAround(game.level, x - 4, y + 4)
		game.logPlayer(actor, "Something in the floor clicks ominously.")
		local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		game.zone:addEntity(game.level, g, "terrain", x, y)
	end,
},
{random_filter={add_levels=10, tome_mod="gvault"}}
)

defineTile('+', mod.class.Grid.new{
	define_as = "TRIGGERED_DOOR",
	name = "sealed door", image = "terrain/sealed_door.png",
	type = "door", subtype = 1,
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}
)

defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('X', "DOOR_VAULT")
defineTile('&', "LAVA_FLOOR")

defineTile('a', "FLOOR", {random_filter={add_levels=10, tome_mod="gvault"}}, {random_filter={add_levels=15, subtype = "orc", name = "orc cryomancer"}})
defineTile('b', "FLOOR", {random_filter={add_levels=10, tome_mod="gvault"}}, {random_filter={add_levels=10, subtype = "orc", name = "orc pyromancer"}})
defineTile('o', "FLOOR", nil, {random_filter={add_levels=3, subtype = "orc"}})
defineTile('p', "FLOOR", {random_filter={add_levels=10, type = "money"}}, {random_filter={add_levels=5, subtype = "orc", name = "orc grand master assassin"}})
defineTile('q', "FLOOR", nil, {random_filter={add_levels=5, subtype = "orc", name = "orc archer"}})
defineTile('r', "FLOOR", nil, {random_filter={add_levels=5, subtype = "orc", name = "icy orc wyrmic"}})
defineTile('s', "FLOOR", nil, {random_filter={add_levels=5, subtype = "orc", name = "fiery orc wyrmic"}})


return {
[[#############]],
[[#a#...q...#b#]],
[[##+.......+##]],
[[#...r.o.s...#]],
[[#...........#]],
[[#....&&&o..p#]],
[[X....&u&o..p#]],
[[#....&&&o..p#]],
[[#...........#]],
[[#...s.o..r..#]],
[[##+.......+##]],
[[#b#...q...#a#]],
[[#############]],
}
