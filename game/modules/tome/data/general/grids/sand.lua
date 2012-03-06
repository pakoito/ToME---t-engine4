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

local sand_editer = { method="borders_def", def="sand"}
local sand_wall_editer = { method="sandWalls_def", def="sandwall"}

newEntity{
	define_as = "SAND",
	type = "floor", subtype = "sand",
	name = "sand", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	nice_editer = sand_editer,
	grow = "SANDWALL_STABLE",
}

newEntity{
	define_as = "UNDERGROUND_SAND",
	type = "floor", subtype = "sand",
	name = "sand", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	grow = "SANDWALL_STABLE",
	nice_tiler = { method="replace", base={"UNDERGROUND_SAND", 10, 1, 11}},
}
for i = 1, 11 do newEntity{ base = "UNDERGROUND_SAND", define_as = "UNDERGROUND_SAND"..i, image = "terrain/sand_"..i..".png"} end

newEntity{
	define_as = "SANDWALL",
	type = "wall", subtype = "sand",
	name = "sandwall", image = "terrain/sand/sand_V3_5_01.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	-- Dig only makes unstable tunnels
	dig = function(src, x, y, old)
		local sand = require("engine.Object").new{
			name = "unstable sand tunnel", image = "terrain/sand.png",
			display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
			canAct = false,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.logSeen(self, "The unstable sand tunnel collapses!")
					game.nicer_tiles:updateAround(game.level, self.x, self.y)

					local a = game.level.map(self.x, self.y, engine.Map.ACTOR)
					if a then
						game.logPlayer(a, "You are crushed by the collapsing tunnel! You suffocate!")
						a:suffocate(30, self, "was buried alive")
						engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self, self.x, self.y, engine.DamageType.PHYSICAL, a.life / 2)
					end
				end
			end,
			tunneler_dig = 1,
			dig = function(src, x, y, old)
				old.temporary = 20
				return nil, old, true
			end,
		}
		sand.summoner_gain_exp = true
		sand.summoner = src
		sand.old_feat = old
		sand.temporary = 20
		sand.x = x
		sand.y = y
		game.level:addEntity(sand)
		return nil, sand, true
	end,
	nice_editer = sand_wall_editer,
	nice_tiler = { method="replace", base={"SANDWALL", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "SANDWALL", define_as = "SANDWALL"..i, image = "terrain/sand/sandwall_5_"..i..".png"} end


newEntity{
	define_as = "SANDWALL_STABLE",
	type = "wall", subtype = "sand",
	name = "sandwall", image = "terrain/sand/sand_V3_5_01.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "UNDERGROUND_SAND",
	nice_editer = sand_wall_editer,
	nice_tiler = { method="replace", base={"SANDWALL_STABLE", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "SANDWALL_STABLE", define_as = "SANDWALL_STABLE"..i, image = "terrain/sand/sandwall_5_"..i..".png"} end

newEntity{
	define_as = "PALMTREE",
	type = "wall", subtype = "sand",
	name = "tree", image = "terrain/palmtree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "SAND",
	nice_tiler = { method="replace", base={"PALMTREE", 100, 1, 20}},
	nice_editer = sand_editer,
}
for i = 1, 20 do newEntity{ base="PALMTREE", define_as = "PALMTREE"..i, image = "terrain/sandfloor.png", add_displays = class:makeTrees("terrain/palmtree_alpha", 8, 5) } end

-----------------------------------------
-- Sandy exits
-----------------------------------------
newEntity{
	define_as = "SAND_UP_WILDERNESS",
	type = "floor", subtype = "sand",
	name = "exit to the worldmap", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = sand_editer,
}

newEntity{
	define_as = "SAND_UP8",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_UP2",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_UP4",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_UP6",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "SAND_DOWN8",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_DOWN2",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_DOWN4",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_DOWN6",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "SAND_LADDER_DOWN",
	type = "floor", subtype = "sand",
	name = "ladder to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_down.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_LADDER_UP",
	type = "floor", subtype = "sand",
	name = "ladder to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_up.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "SAND_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "sand",
	name = "ladder to worldmap", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_up_wild.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = sand_editer,
}
