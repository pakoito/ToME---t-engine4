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

startx = 7
starty = 12

setStatusAll{no_teleport=true}

specialList("terrain", {
	"/data/general/grids/basic.lua",
	"/data/general/grids/lava.lua",
})

defineTile('#', "HARDWALL")
defineTile('O', "GLASSWALL")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {block = true})
defineTile('X', "HARDWALL", nil, nil, nil, {block = true})
defineTile('.', "FLOOR")
defineTile('%', "LAVA")
defineTile('m', "FLOOR", nil, {random_filter={add_levels=10}})
defineTile('M', "FLOOR", nil, {random_filter={add_levels=20}})
defineTile('*', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}})
defineTile('?', "FLOOR", {random_filter={name = "teleportation rune"}})
defineTile('S', "HARDWALL", nil, nil, nil, {on_block_change="DOOR", on_block_change_msg="You've discovered a secret door!"})

defineTile('1', "GENERIC_LEVER", nil, nil, nil, {lever=1,  lever_kind = {a = true, b = true, x = true}, lever_radius=100, lever_block="block"})
defineTile('2', "GENERIC_LEVER", nil, nil, nil, {lever=1,  lever_kind = {a = true, b = true, c = true, d = true}, lever_radius=100, lever_block="block"})
defineTile('3', "GENERIC_LEVER", nil, nil, nil, {lever=1,  lever_kind = {x = true, y = true, a = true}, lever_radius=100, lever_block="block"})
defineTile('4', "GENERIC_LEVER", nil, nil, nil, {lever=1,  lever_kind = {x = true, y = true, z = true, d = true}, lever_radius=100, lever_block="block"})
defineTile('T', "GENERIC_LEVER", nil, nil, nil, {lever=1, lever_kind= {teleporter = true}, lever_radius=100, lever_block="block"})

local num_closed_at_start = 1
local closed, opened = {}, {'a', 'x'}
for i = 1, num_closed_at_start do closed[#closed+1] = rng.tableRemove(opened) end
opened = table.reverse(opened)

defineTile('a', opened.a and "GENERIC_LEVER_DOOR_OPEN" or "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="a"})
defineTile('b', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="b"})
defineTile('c', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="c"})
defineTile('d', "GENERIC_LEVER_DOOR_OPEN", nil, nil, nil, {lever_toggle=true, lever_action_kind="d"})

defineTile('x', opened.x and "GENERIC_LEVER_DOOR_OPEN" or "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="x"})
defineTile('y', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="y"})
defineTile('z', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="z"})

defineTile('t', mod.class.Grid.new{
	define_as = "TELEPORT_FLOOR_1",
	type = "floor", subtype = "floor",
	name = "runed floor", image = "terrain/marble_floor.png", add_displays={mod.class.Grid.new{z=5, image = "trap/trap_teleport_01.png"}},
	display = '^', color_r=255, color_g=0, color_b=255, back_color=colors.DARK_GREY,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not self.activated then return end
		local fx, fy = util.findFreeGrid(x, y - 3, 1, true, {[engine.Map.ACTOR]=true})
		if not fx then
			return
		end
		actor:move(fx, fy, true)
		game.level.map:particleEmitter(x, y, 1, "teleport")
		game.level.map:particleEmitter(fx, fy, 1, "teleport")

		game.logPlayer(actor, "#YELLOW#The world spins around you!")
	end,
},
nil, nil, nil, {lever_action_value=0, lever_action_only_once=true, lever_action_kind="teleporter", lever_action_custom=function(i, j, who, val, old)
	if val == 2 then
		game.logPlayer(who, "#YELLOW#The air comes alive with terrible magics!")
		local g = game.level.map(i, j, game.level.map.TERRAIN)
		g.activated = true
		local m = game.zone:makeEntity(game.level, "actor", {type = "demon", subtype = "major", random_boss={nb_classes=2, rank=3.5, loot_quantity = 3}})
		if m then
			game.zone:addEntity(game.level, m, "actor", i, j)
		end
		return true
	end
end}
)

defineTile('u', mod.class.Grid.new{
	define_as = "TELEPORT_FLOOR_2",
	type = "floor", subtype = "floor",
	name = "runed floor", image = "terrain/marble_floor.png", add_displays={mod.class.Grid.new{z=5, image = "trap/trap_teleport_01.png"}},
	display = '^', color_r=255, color_g=0, color_b=255, back_color=colors.DARK_GREY,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not self.activated then return end
		local fx, fy = util.findFreeGrid(x, y + 3, 1, true, {[engine.Map.ACTOR]=true})
		if not fx then
			return
		end
		actor:move(fx, fy, true)
		game.level.map:particleEmitter(x, y, 1, "teleport")
		game.level.map:particleEmitter(fx, fy, 1, "teleport")

		game.logPlayer(actor, "#YELLOW#The world spins around you!")
	end,
},
nil, nil, nil, {lever_action_value=0, lever_action_only_once=true, lever_action_kind="teleporter", lever_action_custom=function(i, j, who, val, old)
	if val == 2 then
		local g = game.level.map(i, j, game.level.map.TERRAIN)
		g.activated = true
		return true
	end
end}
)

return {
[[XXXXXXXXXXXXXXXXX]],
[[X.....O*O......TX]],
[[X..##.#*#..#.###X]],
[[XT*#..#*#.*#....X]],
[[X###c##u#######zX]],
[[Xm...O%%%O*..SmmX]],
[[X.m..#%%%#####..X]],
[[X.m.2##t##...#4.X]],
[[Xb#####d##.#.##yX]],
[[X..m1#..m#.#m...X]],
[[X..###.m.#.#..m.X]],
[[X.m..a...x.#m..3X]],
[[XXXXXXX!XXXXXXXXX]],
}
