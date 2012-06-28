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

local kind = rng.table{"fire", "fire", "cold", "cold", "storm", "storm", "multihued"}

local id = kind.."-dragon-cave-"..game.turn

local changer = function(id, kind)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/"..kind.."-drake.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = mod.class.Grid:loadList("/data/general/grids/cave.lua")
	terrains.CAVE_LADDER_UP_WILDERNESS.change_level_shift_back = true
	terrains.CAVE_LADDER_UP_WILDERNESS.change_zone_auto_stairs = true
	local zone = mod.class.Zone.new(id, {
		name = "Intimidating Cave",
		level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = "Swashing the buck.ogg",
		reload_lists = false,
		persistent = "zone",
		min_material_level = game.zone.min_material_level,
		max_material_level = game.zone.max_material_level,
		generator =  {
			map = {
				class = "engine.generator.map.Cavern",
				zoom = 6,
				min_floor = 1200,
				floor = "CAVEFLOOR",
				wall = "CAVEWALL",
				up = "CAVE_LADDER_UP_WILDERNESS",
				door = "CAVEFLOOR",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {25, 25},
				guardian = {special=function(e) return e.rank and e.rank >= 2 end, random_elite={life_rating=function(v) return v * 1.5 + 4 end, nb_rares=3}},
			},
			object = {
				class = "engine.generator.object.Random",
				filters = {{type="gem"}},
				nb_object = {25, 35},
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
		trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "intimidating cave"
g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id g.glow=true
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/crystal_ladder_down.png", z=5}
g.nice_tiler = nil
g:initGlow()
g.dragon_kind = kind
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone, self.dragon_kind), {temporary_zone_shift=true})
	self.change_level_check = nil
	self.real_change = nil
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

local i, j = util.findFreeGrid(x, y, 10, true, {[engine.Map.ACTOR]=true})
if not i then return end

-- Pop hatchlings at the stairs
local npcs = mod.class.NPC:loadList{"/data/general/npcs/"..kind.."-drake.lua"}
local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs, special=function(e) return e.rank and e.rank == 1 end}, nil, true)
if m then
	game.zone:addEntity(game.level, m, "actor", i, j)
end

return true
