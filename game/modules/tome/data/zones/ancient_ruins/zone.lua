return {
	name = "ancient ruins",
	level_range = {1, 5},
	max_level = 5,
	width = 50, height = 30,
	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = "dungeon",
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			['+'] = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {40, 40},
			ood = {chance=5, range={1, 10}},
			adjust_level_to_player = {-1, 2},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {10, 10},
			ood = {chance=5, range={1, 10}},
		},
	}
}
