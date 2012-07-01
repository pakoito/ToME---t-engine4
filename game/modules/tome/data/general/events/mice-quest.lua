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

-- Find a random spot
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 100 then return false end

local id = "mouse-quest-"..game.turn

local changer = function(id)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/thieve.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = mod.class.Grid:loadList("/data/general/grids/cave.lua")
	local zone = mod.class.Zone.new(id, {
		name = "Unknown cave",
		level_range = {1, 1},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 20, height = 20,
		ambient_music = "Suspicion.ogg",
		reload_lists = false,
		persistent = "zone",
		min_material_level = 1,
		max_material_level = 1,
		generator =  {
			map = {
				class = "engine.generator.map.Cavern",
				zoom = 4,
				min_floor = 120,
				floor = "CAVEFLOOR",
				wall = "CAVEWALL",
				up = "CAVE_LADDER_UP_WILDERNESS",
				door = "CAVEFLOOR",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {14, 14},
				guardian = {random_elite={life_rating=function(v) return v * 1.5 + 4 end, nb_rares=3}},
			},
			object = {
				class = "engine.generator.object.Random",
				filters = {{type="gem"}},
				nb_object = {6, 9},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {6, 9},
			},
		},
--		levels = { [1] = { generator = { map = { up = "CAVEFLOOR", }, }, }, },
		npc_list = npcs,
		grid_list = terrains,
		object_list = objects,
		trap_list = {}},
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = ""
g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/pedestal_heart.png", z=5}
g.nice_tiler = nil
g.real_change = changer
g.block_move = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true})
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

return true
