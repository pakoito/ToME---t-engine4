-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

newEntity{
	name = "Unmarked Cave",
	type = "harmless", subtype = "special", unique = true,
	level_range = {25, 35},
	rarity = 8,
	coords = {{ x=36, y=28, likelymap={
		[[    11111111   ]],
		[[ 1111111111111 ]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[ 1111111111111 ]],
		[[   111111111   ]],
	}}},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Entrance to an unmarked cave",
			display='>', color={r=0, g=255, b=255},
			notice = true,
			change_level=1, change_zone="unremarkable-cave"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to what seems to be a cave...")
		return true
	end,
}

---------------------------- Hostiles -----------------------------

-- Ambushed!
-- We construct a temporary zone on the fly
newEntity{
	name = "Orcs",
	type = "hostile", subtype = "ambush",
	level_range = {1, 50},
	rarity = 8,
	coords = {{ x=0, y=0, w=100, h=100}},
	special_filter = function(self)
		return game.player:reactionToward{faction="orc-pride"} < 0 and true or false
	end,
	on_encounter = function(self, who)
		local gen = { class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			sqrt_percent = 50,
			zoom = 10,
			floor = "GRASS",
			wall = "TREE",
			up = "UP",
			down = "DOWN",
			up = "UP_WILDERNESS_FAR_EAST",
		}
		local g = game.level.map(who.x, who.y, engine.Map.TERRAIN)
		if not g.can_encounter then return false end

		if g.can_encounter == "desert" then gen.floor = "SAND" gen.wall = "PALMTREE" end

		local zone = engine.Zone.new("ambush", {
			name = "Ambush!",
			level_range = {20, 50},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 20, height = 20,
			all_lited = true,
			ambiant_music = "last",
			generator =  {
				map = gen,
				actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
				trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
			},

			npc_list = mod.class.NPC:loadList("/data/general/npcs/orc.lua", nil, nil, function(e) e.make_escort=nil end),
			grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua", "/data/general/grids/sand.lua"},
			object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
			trap_list = {},
			post_process = function(level)
				-- Find a good starting location, on the opposite side of the exit
				local sx, sy = level.map.w-1, rng.range(0, level.map.h-1)
				level.spots[#level.spots+1] = {
					check_connectivity = "entrance",
					x = sx,
					y = sy,
				}
				level.default_down = level.default_up
				level.default_up = {x=sx, y=sy}
			end,
		})
		game.player:runStop()
		game.player.energy.value = game.energy_to_act
		game.paused = true
		game:changeLevel(1, zone)
		engine.Dialog:simplePopup("Ambush!", "You have been ambushed by a patrol of orcs!")
		return true
	end,
}
