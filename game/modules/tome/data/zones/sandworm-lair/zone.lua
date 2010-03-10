return {
	name = "Sandworm lair",
	level_range = {7, 18},
	level_scheme = "player",
	max_level = 7,
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			no_tunnels = true,
			nb_rooms = 10,
			lite_room_chance = 0,
			rooms = {"forest_clearing"},
			['.'] = "SAND",
			['#'] = "SANDWALL",
			up = "UP",
			down = "DOWN",
			door = "SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Sandworm",
			nb_npc = {20, 30},
			guardian = "SANDWORM_QUEEN",
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
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
	},
}
