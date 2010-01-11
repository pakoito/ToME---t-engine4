return {
	name = "Trollshaws",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"simple", "pilar"},
			['.'] = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			['#'] = "TREE",
			up = "UP",
			down = "DOWN",
			door = "GRASS",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			adjust_level = {-1, 2},
			guardian = "TROLL_BILL",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {400, 600},
			filters = { {type="potion" }, {type="potion" }, {type="potion" }, {type="scroll" }, {}, {} }
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
