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

local sand_editer = { method="borders_def", def="sand"}
local bone_wall_editer = { method="sandWalls_def", def="bonewall"}

newEntity{
	define_as = "BONEFLOOR",
	type = "floor", subtype = "bone",
	name = "sand", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	nice_editer = sand_editer,
	grow = "BONEWALL",
}

newEntity{
	define_as = "BONEWALL",
	type = "wall", subtype = "bone",
	name = "bone walls", image = "terrain/bone/bonewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "BONEFLOOR",
	nice_editer = bone_wall_editer,
	nice_tiler = { method="replace", base={"BONEWALL", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "BONEWALL", define_as = "BONEWALL"..i, image = "terrain/bone/bonewall_5_"..i..".png"} end

newEntity{
	define_as = "HARDBONEWALL",
	type = "wall", subtype = "bone",
	name = "bone walls", image = "terrain/bone/bonewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -15,
	nice_editer = bone_wall_editer,
	nice_tiler = { method="replace", base={"HARDBONEWALL", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "HARDBONEWALL", define_as = "HARDBONEWALL"..i, image = "terrain/bone/bonewall_5_"..i..".png"} end

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "BONE_DOOR",
	type = "wall", subtype = "bone",
	name = "door", image="terrain/bone/bone_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="BONE_DOOR_VERT", west_east="BONE_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "BONE_DOOR_OPEN",
	dig = "BONEFLOOR",
}
newEntity{
	define_as = "BONE_DOOR_OPEN",
	type = "wall", subtype = "bone",
	name = "open door", image="terrain/bone/bone_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "BONE_DOOR",
}
newEntity{ base = "BONE_DOOR", define_as = "BONE_DOOR_HORIZ", z=3, image = "terrain/sandfloor.png", add_mos={{image="terrain/bone/bone_door1.png"}}, add_displays = {class.new{image="terrain/bone/bonewall_8_1.png", z=18, display_y=-1}}, door_opened = "BONE_DOOR_HORIZ_OPEN"}
newEntity{ base = "BONE_DOOR_OPEN", define_as = "BONE_DOOR_HORIZ_OPEN", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_open.png", z=17}, class.new{image="terrain/bone/bonewall_8_1.png", z=18, display_y=-1}}, door_closed = "BONE_DOOR_HORIZ"}
newEntity{ base = "BONE_DOOR", define_as = "BONE_DOOR_VERT", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_vert.png", z=17}, class.new{image="terrain/bone/bone_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "BONE_DOOR_OPEN_VERT", dig = "BONE_DOOR_OPEN_VERT"}
newEntity{ base = "BONE_DOOR_OPEN", define_as = "BONE_DOOR_OPEN_VERT", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_open_vert.png", z=17}, class.new{image="terrain/bone/bone_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "BONE_DOOR_VERT"}

-----------------------------------------
-- Levers & such tricky tings
-----------------------------------------
newEntity{
	define_as = "BONE_GENERIC_LEVER_DOOR",
	type = "wall", subtype = "bone",
	name = "sealed door", image="terrain/bone/bone_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="BONE_GENERIC_LEVER_DOOR_VERT", west_east="BONE_GENERIC_LEVER_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	force_clone = true,
	door_player_stop = "This door seems to have been sealed off. You need to find a way to open it.",
	is_door = true,
	door_opened = "BONE_GENERIC_LEVER_DOOR_OPEN",
	on_lever_change = function(self, x, y, who, val, oldval)
		local toggle = game.level.map.attrs(x, y, "lever_toggle")
		local trigger = game.level.map.attrs(x, y, "lever_action")
		if toggle or (val > oldval and val >= trigger) then
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened])
			game.log("#VIOLET#You hear a door opening.")
			return true
		end
	end,
}
newEntity{ base = "BONE_GENERIC_LEVER_DOOR", define_as = "BONE_GENERIC_LEVER_DOOR_HORIZ", z=3, image = "terrain/sandfloor.png", add_mos={{image="terrain/bone/bone_door1.png", add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}}, add_displays = {class.new{image="terrain/bone/bonewall_8_1.png", z=18, display_y=-1}}, door_opened = "BONE_DOOR_HORIZ_OPEN"}
newEntity{ base = "BONE_GENERIC_LEVER_DOOR", define_as = "BONE_GENERIC_LEVER_DOOR_VERT", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_vert.png", z=17, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}, class.new{image="terrain/bone/bone_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "BONE_DOOR_OPEN_VERT"}

newEntity{
	define_as = "BONE_GENERIC_LEVER_DOOR_OPEN",
	type = "wall", subtype = "bone",
	name = "open door", image="terrain/bone/bone_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	nice_tiler = { method="door3d", north_south="BONE_GENERIC_LEVER_DOOR_OPEN_VERT", west_east="BONE_GENERIC_LEVER_DOOR_HORIZ_OPEN" },
	always_remember = true,
	is_door = true,
	door_closed = "BONE_GENERIC_LEVER_DOOR",
	door_player_stop = "This door seems to have been sealed off. You need to find a way to close it.",
	on_lever_change = function(self, x, y, who, val, oldval)
		local toggle = game.level.map.attrs(x, y, "lever_toggle")
		local trigger = game.level.map.attrs(x, y, "lever_action")
		if toggle or (val < oldval and val < trigger) then
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_closed])
			game.log("#VIOLET#You hear a door closing.")
			return true
		end
	end,
}
newEntity{ base = "BONE_GENERIC_LEVER_DOOR_OPEN", define_as = "BONE_GENERIC_LEVER_DOOR_HORIZ_OPEN", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_open.png", z=17}, class.new{image="terrain/bone/bonewall_8_1.png", z=18, display_y=-1}}, door_closed = "BONE_GENERIC_LEVER_DOOR_HORIZ"}
newEntity{ base = "BONE_GENERIC_LEVER_DOOR_OPEN", define_as = "BONE_GENERIC_LEVER_DOOR_OPEN_VERT", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_door1_open_vert.png", z=17}, class.new{image="terrain/bone/bone_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "BONE_GENERIC_LEVER_DOOR_VERT"}

newEntity{
	define_as = "BONE_GENERIC_LEVER",
	type = "lever", subtype = "bone",
	name = "huge lever", image = "terrain/sandfloor.png", add_mos = {{image="terrain/lever1_state1.png"}},
	display = '&', color=colors.UMBER, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	lever = false,
	force_clone = true,
	block_move = function(self, x, y, e, act)
		if act and e.player then
			local spot = game.level.map.attrs(x, y, "lever_spot") or nil
			local block = game.level.map.attrs(x, y, "lever_block") or nil
			local radius = game.level.map.attrs(x, y, "lever_radius") or 10
			local val = game.level.map.attrs(x, y, "lever")
			local kind = game.level.map.attrs(x, y, "lever_kind")
			if type(kind) == "string" then kind = {[kind]=true} end
			if self.lever then
				self.color_r = colors.UMBER.r self.color_g = colors.UMBER.g self.color_b = colors.UMBER.b
				self.add_mos[1].image = "terrain/lever1_state1.png"
			else
				self.color_r = 255 self.color_g = 255 self.color_b = 255
				self.add_mos[1].image = "terrain/lever1_state2.png"
			end
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
			self.lever = not self.lever
			game.log("#VIOLET#You hear a mechanism clicking.")

			local apply = function(i, j)
				local akind = game.level.map.attrs(i, j, "lever_action_kind")
				if not akind then return end
				if type(akind) == "string" then akind = {[akind]=true} end
				for k, _ in pairs(kind) do if akind[k] then
					local old = game.level.map.attrs(i, j, "lever_action_value") or 0
					local newval = old + (self.lever and val or -val)
					game.level.map.attrs(i, j, "lever_action_value", newval)
					if game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "on_lever_change", e, newval, old) then
						if game.level.map.attrs(i, j, "lever_action_only_once") then game.level.map.attrs(i, j, "lever_action_kind", false) end
					end
					local fct = game.level.map.attrs(i, j, "lever_action_custom")
					if fct and fct(i, j, e, newval, old) then
						if game.level.map.attrs(i, j, "lever_action_only_once") then game.level.map.attrs(i, j, "lever_action_kind", false) end
					end
				end end
			end

			if spot then
				local spot = game.level:pickSpot(spot)
				if spot then apply(spot.x, spot.y) end
			else
				core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, radius, function(_, i, j)
					if block and game.level.map.attrs(i, j, block) then return true end
				end, function(_, i, j) apply(i, j) end, nil)
			end
		end
		return true
	end,
}

-----------------------------------------
-- Bony exits
-----------------------------------------
newEntity{
	define_as = "BONE_UP_WILDERNESS",
	type = "floor", subtype = "bone",
	name = "exit to the worldmap", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = sand_editer,
}

newEntity{
	define_as = "BONE_UP8",
	type = "floor", subtype = "bone",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_UP2",
	type = "floor", subtype = "bone",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_UP4",
	type = "floor", subtype = "bone",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_UP6",
	type = "floor", subtype = "bone",
	name = "way to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "BONE_DOWN8",
	type = "floor", subtype = "bone",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_DOWN2",
	type = "floor", subtype = "bone",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_DOWN4",
	type = "floor", subtype = "bone",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_DOWN6",
	type = "floor", subtype = "bone",
	name = "way to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "BONE_LADDER_DOWN",
	type = "floor", subtype = "bone",
	name = "ladder to the next level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_stairs_down_1_01.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_LADDER_UP",
	type = "floor", subtype = "bone",
	name = "ladder to the previous level", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_stairs_up_1_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}
newEntity{
	define_as = "BONE_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "bone",
	name = "ladder to worldmap", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/bone/bone_stairs_exit_1_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = sand_editer,
}
