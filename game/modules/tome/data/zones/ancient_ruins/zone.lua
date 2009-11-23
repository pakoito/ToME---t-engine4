return {
	name = "ancient ruins",
	max_level = 5,
	width = 26, height = 5,
	all_remembered = true,
	all_lited = true,
	generator =  {
		map = {
			class= "engine.generator.map.Empty",
			floor = "FLOOR",
			wall = "WALL",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {6, 6},
		},
	}
}
