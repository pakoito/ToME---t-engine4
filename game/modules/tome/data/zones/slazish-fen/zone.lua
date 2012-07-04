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
	name = "Slazish Fens",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	no_worldport = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Valve.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 7,
			sqrt_percent = 30,
			sqrt_percent2 = 25,
			noise = "fbm_perlin",
			floor2 = function() if rng.chance(20) then return "BOGWATER_MISC" else return "BOGWATER" end end,
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			wall = "BOGTREE",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",

--			nb_rooms = {0,0,0,1},
--			rooms = {"lesser_vault"},
--			lesser_vaults_list = {"honey_glade", "forest-ruined-building1", "forest-ruined-building2", "forest-ruined-building3", "forest-snake-pit", "mage-hideout"},
--			lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {7, 10},
			filters = { {max_ood=2}, },
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "GATES_OF_MORNING",
			}, },
		},
		[3] = {
			generator = { map = {
				force_last_stair = true,
				end_road_room = "zones/zoisla",
				portal = "PORTAL",
				near_portal = "BOGWATER",
				down = "GRASS",
			}, },
		},
	},

	post_process = function(level)
		game.state:makeWeather(level, 7, {max_nb=1, speed={0.5, 1.6}, shadow=true, alpha={0.23, 0.35}, particle_name="weather/grey_cloud_%02d"})
		game.state:makeAmbientSounds(level, {
			wind={ chance=200, volume_mod=1.2, pitch=0.3, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
			bird={ chance=2000, volume_mod=0.75, pitch=0.4, files={"ambient/forest/bird1","ambient/forest/bird2","ambient/forest/bird3","ambient/forest/bird4","ambient/forest/bird5","ambient/forest/bird6","ambient/forest/bird7"}},
		})

		if level.level == 1 then
			local npc1 = game.zone:makeEntityByName(game.level, "actor", "NAGA_TIDEWARDEN")
			local npc2 = game.zone:makeEntityByName(game.level, "actor", "NAGA_TIDECALLER")
			local x, y = util.findFreeGrid(game.level.default_down.x, game.level.default_down.y, 20, true, {[engine.Map.ACTOR]=true})
			if x then game.zone:addEntity(game.level, npc1, "actor", x, y) end
			x, y = util.findFreeGrid(game.level.default_down.x, game.level.default_down.y, 20, true, {[engine.Map.ACTOR]=true})
			if x then game.zone:addEntity(game.level, npc2, "actor", x, y) end

			npc1.on_die = function(self)
				local n = game.zone:makeEntityByName(game.level, "object", "SLAZISH_NOTE1")
				if n then game.zone:addEntity(game.level, n, "object", self.x, self.y) end
			end
		elseif level.level == 2 then
			local npc = game.zone:makeEntityByName(game.level, "actor", "NAGA_TIDEWARDEN")
			local x, y = util.findFreeGrid(game.level.default_down.x, game.level.default_down.y, 20, true, {[engine.Map.ACTOR]=true})
			if x then game.zone:addEntity(game.level, npc, "actor", x, y) end

			npc.on_die = function(self)
				local n = game.zone:makeEntityByName(game.level, "object", "SLAZISH_NOTE2")
				if n then game.zone:addEntity(game.level, n, "object", self.x, self.y) end
			end
		end
	end,
}
