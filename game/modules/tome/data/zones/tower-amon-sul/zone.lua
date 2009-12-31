return {
	name = "Tower of Amon Sûl",
	level_range = {40, 50},
	level_scheme = "player",
	max_level = 5,
	width = 50, height = 50,
	all_remembered = true,
--	all_lited = true,
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
			nb_npc = {0, 0},
			ood = {chance=5, range={1, 10}},
			adjust_level = {-1, 2},
			guardian = "SHADE_OF_ANGMAR",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {200, 300},
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
