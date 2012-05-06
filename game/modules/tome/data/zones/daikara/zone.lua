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

return {
	name = "Daikara",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "World of Ice.ogg",
	min_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	max_material_level = function() return game.state:isAdvanced() and 5 or 3 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {2,8},
			rooms = {"forest_clearing", "rocky_snowy_trees", {"lesser_vault",7}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{}}}},
			lesser_vaults_list = {"snow-giant-camp"},
			['.'] = "ROCKY_GROUND",
			['T'] = "ROCKY_SNOWY_TREE",
			['#'] = "MOUNTAIN_WALL",
			up = "ROCKY_UP2",
			down = "ROCKY_DOWN8",
			door = "ROCKY_GROUND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "RANTHA_THE_WORM",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "ROCKY_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", "daikara", level.level)

		-- Temporal rift on level 4
		local p = game.party:findMember{main=true}
		if level.level == 3 then
			if p.descriptor.subclass == "Temporal Warden" then
				local x, y = util.findFreeGrid(level.default_up.x, level.default_up.y, 10, true, {[engine.Map.ACTOR]=true})
				if x and y then
					p:grantQuest("paradoxology")
					p:hasQuest("paradoxology"):generate(p, x, y)
				end
			-- Normal time rift for others
			else
				local g = game.zone:makeEntityByName(game.level, "terrain", "RIFT")
				local x, y = rng.range(0, game.level.map.w-1), rng.range(0, game.level.map.h-1)
				local tries = 0
					while (game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") or game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "change_level")) and tries < 100 do
					x, y = rng.range(0, game.level.map.w-1), rng.range(0, game.level.map.h-1)
					tries = tries + 1
				end
				if tries < 100 then
					game.zone:addEntity(game.level, g, "terrain", x, y)
				end
			end
		end

		game.state:makeWeather(level, 6, {max_nb=7, chance=1, dir=120, speed={0.1, 0.9}, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})
	end,
}
