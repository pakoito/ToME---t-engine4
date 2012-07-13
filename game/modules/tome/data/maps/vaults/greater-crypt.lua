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

--greater crypt
startx = 0
starty = 17

setStatusAll{no_teleport=true}

specialList("terrain", {
	"/data/general/grids/basic.lua",
	"/data/general/grids/mountain.lua",
	"/data/general/grids/water.lua",
	"/data/general/grids/lava.lua",
	"/data/general/grids/.lua",
})

defineTile('%', "WALL")
defineTile('.', "FLOOR")
defineTile('r', "ROCKY_GROUND")
defineTile('#', "HARDWALL")
defineTile('M', "HARDMOUNTAIN_WALL")
defineTile('X', "DOOR_VAULT")
defineTile(',', "LAVA_FLOOR")
defineTile('%', "LAVA")
defineTile('+', "DOOR")
defineTile('~', "DEEP_WATER")

defineTile('a', "FLOOR", nil, {random_filter={name="skeleton master archer", add_levels=5}})
defineTile('s', "FLOOR", nil, {random_filter={type = "undead", subtype = "skeleton", add_levels=10}})
defineTile('V', "FLOOR", nil, {random_filter={type = "undead", subtype = "vampire", add_levels=10}})
defineTile('g', "FLOOR", nil, {random_filter={type = "undead", subtype = "ghost", name = "dreadmaster"}})
defineTile('G', "FLOOR", nil, {random_filter={type = "undead", subtype = "ghost", name = "ruin banshee"}})
defineTile('z', "FLOOR", nil, {random_filter={type = "undead", subtype = "ghoul", name = "ghoulking", add_levels=10}})
defineTile('u', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={type = "undead", add_levels=10}})
defineTile('U', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={type = "undead", add_levels=20}})
defineTile('l', "ROCKY_GROUND", nil, {random_filter={type = "undead", subtype = "lich", add_levels=10}})
--defineTile('L', "ROCKY_GROUND", nil, {random_filter={type = "undead", subtype = "lich", random_boss={nb_classes=2, loot_quality="store", loot_quantity=3, rank=3.5,}}})
defineTile('L', "ROCKY_GROUND", nil, {random_filter={add_levels=8, name="lich", random_boss={nb_classes=2, rank=3.5, loot_quantity = 3}}})
defineTile('-', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}})
defineTile('/', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}})
defineTile('|', "ROCKY_GROUND", {random_filter={add_levels=15, tome_mod="uvault"}})
defineTile('*', "ROCKY_GROUND", {random_filter={type="gem"}})

defineTile('S', "FLOOR", nil, nil, {random_filter={name="summoning alarm"}})

defineTile('D', "FLOOR", nil, {random_filter={name="greater multi-hued wyrm", add_levels=30}})
defineTile('c', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={add_levels=20}})
defineTile('=', "HARDWALL", nil, nil, nil, {on_block_change="DOOR", on_block_change_msg="You've discovered a secret door!"})
defineTile('_', "HARDMOUNTAIN_WALL", nil, nil, nil, {on_block_change="FLOOR", on_block_change_msg="You've discovered a secret passage!"})

defineTile('1', mod.class.Grid.new{
	define_as = "TELEPORT_FLOOR_1",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local fx, fy = util.findFreeGrid(x + 11, y - 3, 1, true, {[engine.Map.ACTOR]=true})
		if not fx then
			return
		end
		actor:move(fx, fy, true)

		game.logPlayer(actor, "Something in the floor clicks ominously, and suddenly the world spins around you!")
		local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		if not g then return end
		game.zone:addEntity(game.level, g, "terrain", x, y)
	end,
}
)

defineTile('2', mod.class.Grid.new{
	define_as = "WALL_UP_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local g = game.zone:makeEntityByName(game.level, "terrain", "HARDWALL")
		local f = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		if not g or not f then return end
		game.zone:addEntity(game.level, g, "terrain", x - 1, y)
		game.nicer_tiles:updateAround(game.level, x - 1, y)
		game.zone:addEntity(game.level, f, "terrain", x, y + 1)
		game.nicer_tiles:updateAround(game.level, x, y + 1)
		game.zone:addEntity(game.level, f, "terrain", x + 1, y + 1)
		game.nicer_tiles:updateAround(game.level, x + 1, y + 1)
		game.zone:addEntity(game.level, f, "terrain", x + 2, y + 1)
		game.nicer_tiles:updateAround(game.level, x + 2, y + 1)
		game.zone:addEntity(game.level, f, "terrain", x, y)
		game.nicer_tiles:updateAround(game.level, x, y)


		game.logPlayer(actor, "Something in the floor clicks ominously, and the crypt rearranges itself around you!")

	end,
}
)

defineTile('3', mod.class.Grid.new{
	define_as = "WALL_DOWN_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		if not g then return end
		game.zone:addEntity(game.level, g, "terrain", x + 1, y)
		game.nicer_tiles:updateAround(game.level, x + 1, y)

		game.logPlayer(actor, "Something in the floor clicks ominously.")
	end,
}
)

defineTile('4', mod.class.Grid.new{
	define_as = "WALL_UP_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local g = game.zone:makeEntityByName(game.level, "terrain", "HARDMOUNTAIN_WALL")
		local f = game.zone:makeEntityByName(game.level, "terrain", "ROCKY_GROUND")
		if not g or not f then return end
		game.zone:addEntity(game.level, g, "terrain", x + 1, y)
		game.nicer_tiles:updateAround(game.level, x + 1, y)
		game.zone:addEntity(game.level, f, "terrain", x, y + 1)
		game.nicer_tiles:updateAround(game.level, x, y + 1)
		game.zone:addEntity(game.level, f, "terrain", x, y - 1)
		game.nicer_tiles:updateAround(game.level, x, y - 1)
		game.zone:addEntity(game.level, f, "terrain", x - 1, y)
		game.nicer_tiles:updateAround(game.level, x - 1, y)
		game.zone:addEntity(game.level, f, "terrain", x - 1, y + 1)
		game.nicer_tiles:updateAround(game.level, x - 1, y + 1)
		game.zone:addEntity(game.level, f, "terrain", x - 1, y - 1)
		game.nicer_tiles:updateAround(game.level, x - 1, y - 1)
		game.zone:addEntity(game.level, f, "terrain", x, y)
		game.nicer_tiles:updateAround(game.level, x, y)

		game.logPlayer(actor, "Something underfoot clicks ominously, and the crypt rearranges itself around you!")

	end,
}
)

defineTile('5', mod.class.Grid.new{
	define_as = "WALL_DOWN_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "WALL",
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local g = game.zone:makeEntityByName(game.level, "terrain", "ROCKY_GROUND")
		if not g then return end
		game.zone:addEntity(game.level, g, "terrain", x - 1, y)
		game.nicer_tiles:updateAround(game.level, x - 1, y)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.nicer_tiles:updateAround(game.level, x, y)

		game.logPlayer(actor, "Something beneath you clicks ominously.")
	end,
}
)


return {

[[###############################MMM#]],
[[#..+.#..z.S+...#......u....z.,MMMMM]],
[[#..#.#.~~~.###.#..V....z.....,MMMM#]],
[[#zs#.#.~,~a#...#.............,,,,,#]],
[[#VV#.+.~,~a#.###...u...u.MM...V.,,#]],
[[#aa#.#.~~~.#.#...,M,,.s.....u.z...#]],
[[#=##.#...V.#.#z..MMM,..........s..#]],
[[#g/#+#######.#...,MM.s..V..,..u...#]],
[[#/-#...#.u...##.....z......MMM....#]],
[[####+#.#u..V.1+...s....u...,M,....#]],
[[#z.V.#.#.U...##...u......s.....V..#]],
[[#..z.#.#.s.u.#..V.....MM...u......#]],
[[#.u.u#+#######.....MMMMMMMMMM.....#]],
[[#....#z....s.#....MM|rrrr|MMMM....#]],
[[#.V..#..u....####MMMrrrrrrrrMMM*aa#]],
[[#U..U#...z...#....MMrrrrrrrrr*M**g#]],
[[######.....V.#...MM*rLr,,,rrrMMM*/#]],
[[X....+s.U..z.+...M5rrrr,,,rrrrMMM|#]],
[[######..V....####MM*rrr,,lrrrrMMMMM]],
[[#uuUU#....u..#////MMMrrrrrrrrr+4rrM]],
[[#uuuU#u.s....#.....MMMrrrrrrrrMMM_M]],
[[#....#......s#...G..#M###M***MMMMU#]],
[[#=####+#######......#.=.#MMMMM.z..#]],
[[#.......3.2..#......+.#.+S..#U..g.#]],
[[############+##########.###.#...U.#]],
[[#aa#.z...sVzVz.....#....#-#.#V.aa.#]],
[[#%%#.....s.G.....s.#.####+#.#.g.V.#]],
[[#..#.V.............#.#UU#...#..z..#]],
[[#..+...#.a.#..a#...#.#..#.####..U.#]],
[[#u.#...#...#...#...#.#+##.+.U#..g.#]],
[[#..#U.u#Uu.#u.U#Uu.#.#....#.U#U.VV#]],
[[#.u#################+###.#######+##]],
[[#..#.......U.........%a#.#..#~~~~~#]],
[[#..+..U........UU....%a#.+.~=~~~~~#]],
[[###################################]],

}
