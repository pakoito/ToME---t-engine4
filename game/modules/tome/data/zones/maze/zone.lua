return {
	name = "The Maze",
	level_range = {7, 18},
	level_scheme = "player",
	max_level = 7,
	width = 40, height = 40,
--	all_remembered = true,
--	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Maze",
			up = "UP",
			down = "DOWN",
			wall = "MAZE_WALL",
			floor = "MAZE_FLOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			ood = {chance=5, range={1, 10}},
			adjust_level = {-1, 2},
			guardian = "TROLL_BILL",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 6},
			ood = {chance=5, range={1, 10}},
			filters = { {type="potion" }, {type="potion" }, {type="potion" }, {type="scroll" }, {}, {} }
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[7] = {
			generator = { map = {
				force_last_stair = true,
				down = "QUICK_EXIT",
			}, },
		},
	},
}
