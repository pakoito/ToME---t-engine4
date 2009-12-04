return {
	name = "ancient ruins",
	max_level = 5,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class= "engine.generator.map.Empty",
			floor = "FLOOR",
			wall = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {40, 40},
			level_range = {5, 10},
			adjust_level_to_player = {-2, 2},
		},
	}
}
