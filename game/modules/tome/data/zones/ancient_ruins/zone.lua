return {
	name = "ancient ruins",
	max_level = 5,
	width = 100, height = 100,
	all_remembered = true,
	all_lited = true,
	level_npcs = {5, 10},
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
			nb_npc = {200, 200},
		},
	}
}
