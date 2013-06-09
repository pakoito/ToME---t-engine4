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

local layout = game.state:alternateZone(short_name, {"BIGWORM", 2})
local is_bigworm = layout == "BIGWORM"

if layout == "DEFAULT" then

return {
	name = "Sandworm lair",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	no_level_connectivity = true,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	no_autoexplore = true,
	ambient_music = "Suspicion.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 2 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			no_tunnels = true,
			nb_rooms = 10,
			lite_room_chance = 0,
			rooms = {"forest_clearing"},
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Sandworm",
			nb_npc = {20, 30},
			guardian = "SANDWORM_QUEEN",
			guardian_no_connectivity = true,
			-- Number of tunnelers + 2 (one per stair)
			nb_tunnelers = 7,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "SAND_LADDER_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)
	end,
}

elseif layout == "BIGWORM" then

return {
	name = "Sandworm lair",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 350, height = 20,
	no_level_connectivity = true,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	no_autoexplore = true,
	ambient_music = "Suspicion.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 2 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			no_tunnels = true,
			nb_rooms = 30,
			lite_room_chance = 0,
			rooms = {"forest_clearing"},
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL",
			up = "UNDERGROUND_SAND",
			down = "UNDERGROUND_SAND",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {70, 80},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {18, 27},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[2] = {
			width = 50, height = 50,
			generator = {
				map = {
					class = "engine.generator.map.Roomer",
					no_tunnels = true,
					nb_rooms = 10,
					lite_room_chance = 0,
					rooms = {"forest_clearing"},
					['.'] = "UNDERGROUND_SAND",
					['#'] = "SANDWALL",
					up = "SAND_LADDER_UP",
					down = "SAND_LADDER_DOWN",
					door = "UNDERGROUND_SAND",
				},
				actor = {
					class = "mod.class.generator.actor.Sandworm",
					nb_npc = {20, 30},
					guardian = "SANDWORM_QUEEN",
					guardian_no_connectivity = true,
					-- Number of tunnelers + 2 (one per stair)
					nb_tunnelers = 7,
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {6, 9},
					filters = { {} }
				},
			},
		},
	},

	post_process = function(level)
		if level.level == 1 then
			for uid, e in pairs(level.entities) do e:setEffect(e.EFF_VAULTED, 1, {}) end

			local spots = {}
			for i, spot in ipairs(level.spots) do
				if spot.type == "room" and spot.subtype:find("^forest_clearing") then
					local _, _, w, h = spot.subtype:find("^forest_clearing([0-9]+)x([0-9]+)$")
					if w and h then spots[#spots+1] = {x=spot.x, y=spot.y, w=tonumber(w), h=tonumber(h)} end
				end
			end
			table.sort(spots, "x")
			level.ordered_spots = spots
			level.default_up = {x=spots[1].x, y=spots[1].y}
			level.default_down = {x=spots[#spots].x, y=spots[#spots].y}
			level.map(level.default_up.x, level.default_up.y, engine.Map.TERRAIN, game.zone.grid_list.SAND_LADDER_UP_WILDERNESS)
			level.map(level.default_down.x, level.default_down.y, engine.Map.TERRAIN, game.zone.grid_list.SAND_LADDER_DOWN)

			local tx, ty = util.findFreeGrid(level.default_up.x+2, level.default_up.y, 5, true, {[engine.Map.ACTOR]=true})
			if not tx then level.force_recreate = true return end
			local m = game.zone:makeEntityByName(level, "actor", "SANDWORM_TUNNELER_HUGE")
			if not m then level.force_recreate = true return end
			game.zone:addEntity(level, m, "actor", tx, ty)
		end
	end,

	last_worm_turn = 0,
	on_turn = function(self)
		if game.turn % 100 ~= 0 or game.level.level ~= 1 then return end
		if game.level.data.last_worm_turn > game.turn - 800 then return end

--		for uid, e in pairs(game.level.entities) do if e.define_as == "SANDWORM_TUNNELER_HUGE" then return end end

		local tx, ty = util.findFreeGrid(game.level.default_up.x+2, game.level.default_up.y, 5, true, {[engine.Map.ACTOR]=true})
		if not tx then return end
		local m = game.zone:makeEntityByName(game.level, "actor", "SANDWORM_TUNNELER_HUGE")
		if not m then return end
		game.zone:addEntity(game.level, m, "actor", tx, ty)
		game.log("#OLIVE_DRAB#You feel the ground shacking from the west.")
		game.level.data.last_worm_turn = game.turn
	end,
}

end