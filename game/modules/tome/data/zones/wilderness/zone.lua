return {
	name = "wilderness",
	level_range = {1, 1},
	max_level = 1,
	width = 200, height = 130,
	all_remembered = true,
	all_lited = true,
	persistant = "memory",
	generator =  {
		map = {
			class = "mod.class.generator.map.Wilderness",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0,0},
		},
	}
}
