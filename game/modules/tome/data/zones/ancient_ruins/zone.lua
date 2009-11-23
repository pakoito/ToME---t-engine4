return {
	name = "ancient ruins",
	max_level = 5,
	width = 50, height = 30,
	all_remembered = true,
	all_lited = true,
	level_npcs = {5, 10},
	generator =  {
		map = {
			class= "engine.generator.map.Rooms",
			floor = "FLOOR",
			wall = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {10, 20},
		},
	}
}
