return {
	name = "wilderness",
	level_range = {1, 1},
	max_level = 1,
	width = 40, height = 30,
	all_remembered = true,
	all_lited = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "wilderness/main",
		},
	}
}
