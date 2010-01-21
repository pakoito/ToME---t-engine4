return {
	name = "Old Forest",
	level_range = {7, 18},
	level_scheme = "player",
	max_level = 7,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {6,4},
			rooms = {"forest_clearing"},
			['.'] = "GRASS_DARK1",
			['#'] = "TREE_DARK1",
			up = "UP",
			down = "DOWN",
			door = "GRASS_DARK1",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			adjust_level = {-1, 2},
			guardian = "OLD_MAN_WILLOW",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {400, 600},
			filters = { {type="potion" }, {type="potion" }, {}, {}, {} }
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
