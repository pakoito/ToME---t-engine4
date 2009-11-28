return {
	name = "ancient ruins",
	max_level = 5,
	width = 40, height = 30,
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
			nb_npc = {400, 400},
			levelup = {5, 10},
		},
	}
}
