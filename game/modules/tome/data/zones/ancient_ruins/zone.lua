return {
	name = "ancient ruins",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"simple", "pilar"},
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			ood = {chance=5, range={1, 10}},
			adjust_level = {-1, 2},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {100, 100},
			ood = {chance=5, range={1, 10}},
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
