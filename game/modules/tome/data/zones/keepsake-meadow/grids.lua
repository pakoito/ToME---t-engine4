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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/cave.lua")

newEntity{
	define_as = "STEW",
	type = "wall", subtype = "grass",
	name = "troll stew", image = "terrain/grass.png", add_mos={{image="terrain/troll_stew.png"}},
	display = '~', color=colors.LIGHT_RED, back_color=colors.RED,
	does_block_move = true,
	pass_projectile = true,
	nice_editer = grass_editer,
}

-- don't use "GRASS" as a base for event grids; nicer_tile replaces the override
newEntity{
	define_as = "GRASS_EVENT",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_editer = grass_editer,
}

newEntity{
	base = "GRASS_EVENT", define_as = "GRASS_MEADOW",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		-- meadow starts the quest
		who:grantQuest("keepsake")
		game.party:learnLore("keepsake-meadow")
	end,
}

newEntity{
	base = "GRASS_EVENT", define_as = "GRASS_DREAM",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		who:hasQuest("keepsake"):on_start_dream(who)
	end,
}

newEntity{
	base = "GRASS_EVENT", define_as = "GRASS_INCHATE",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if (self.triggered or 0) >= 10 then return end
		self.triggered = (self.triggered or 0) + 1
		
		who:incHate(15)
		if rng.percent(66) then
			game:playSound("creatures/stomp")
		else
			game:playSound("creatures/stomp2")
		end
	end,
}

newEntity{
	base = "GRASS_EVENT", define_as = "GRASS_CARAVAN",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		who:hasQuest("keepsake"):on_find_caravan(who)
	end,
}

newEntity{ base = "GRASS_UP2", define_as = "GRASS_UP2_UP2",
	change_level = -2,
}

newEntity{
	define_as = "CAVEFLOOR_EVENT",
	type = "floor", subtype = "dirt",
	name = "cave floor", image = "terrain/cave/cave_floor_1_01.png",
	display = '.', color=colors.SANDY_BROWN, back_color=colors.DARK_UMBER,
	always_remember = true,
	notice = true,
}

newEntity{
	define_as = "CAVEFLOOR_CAVE_MARKER",
	name = "cave marker", image = "terrain/cave/cave_floor_1_01.png",
	display = '_', color=colors.SANDY_BROWN, back_color=colors.DARK_UMBER,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		
		who:hasQuest("keepsake"):on_cave_marker(who)
	end,
}

newEntity{
	base = "CAVEFLOOR_EVENT", define_as = "CAVEFLOOR_CAVE_ENTRANCE",
	on_move = function(self, x, y, who)
		if not who.player then return end
		if force then return end
		if game.level.cave_entrance_triggered then return end
		game.level.cave_entrance_triggered = true
		
		who:hasQuest("keepsake"):on_cave_entrance(who)
	end,
}

newEntity{
	base = "CAVEFLOOR_EVENT", define_as = "CAVEFLOOR_CAVE_DESCRIPTION",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		who:hasQuest("keepsake"):on_cave_description(who)
	end,
}

newEntity{
	base = "CAVEFLOOR_EVENT", define_as = "CAVEFLOOR_VAULT_ENTRANCE",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		who:hasQuest("keepsake"):on_vault_entrance(who)
	end,
}

newEntity{
	base = "CAVEFLOOR_EVENT", define_as = "CAVEFLOOR_VAULT_TRIGGER",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if self.triggered then return end
		self.triggered = true
		
		who:hasQuest("keepsake"):on_vault_trigger(who)
	end,
}

newEntity{
	base = "CAVEFLOOR_EVENT", define_as = "CAVEFLOOR_DOG_VAULT",
	on_move = function(self, x, y, who, force)
		if not who.player then return end
		if force then return end
		if game.level.dog_vault_triggered then return end
		game.level.dog_vault_triggered = true
		
		who:hasQuest("keepsake"):on_dog_vault(who)
	end,
}

-----------------------------------------
-- Doors added to cave
-----------------------------------------
newEntity{
	define_as = "CAVE_DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/cave/cave_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="CAVE_DOOR_VERT", west_east="CAVE_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "CAVE_DOOR_OPEN",
	dig = "CAVEFLOOR",
}
newEntity{
	define_as = "CAVE_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/cave/cave_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "CAVE_DOOR",
}
newEntity{ base = "CAVE_DOOR", define_as = "CAVE_DOOR_HORIZ", image = "terrain/cave/cave_door1.png", add_displays = {class.new{image="terrain/cave/cavewall_8_1.png", z=18, display_y=-1}}, door_opened = "CAVE_DOOR_HORIZ_OPEN"}
newEntity{ base = "CAVE_DOOR_OPEN", define_as = "CAVE_DOOR_HORIZ_OPEN", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_door1_open.png", z=17}, class.new{image="terrain/cave/cavewall_8_1.png", z=18, display_y=-1}}, door_closed = "CAVE_DOOR_HORIZ"}
newEntity{ base = "CAVE_DOOR", define_as = "CAVE_DOOR_VERT", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_door1_vert.png", z=17}, class.new{image="terrain/cave/cave_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "CAVE_DOOR_OPEN_VERT", dig = "CAVE_DOOR_OPEN_VERT"}
newEntity{ base = "CAVE_DOOR_OPEN", define_as = "CAVE_DOOR_OPEN_VERT", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_door1_open_vert.png", z=17}, class.new{image="terrain/cave/cave_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "CAVE_DOOR_VERT"}
