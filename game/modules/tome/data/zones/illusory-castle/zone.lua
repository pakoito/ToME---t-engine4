return {
	name = "Illusory Castle",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
--			class = "engine.generator.map.Rooms",
			class = "engine.generator.map.TileSet",
			tileset = "dungeon",
			['.'] = "FLOOR",
			['#'] = "WALL",
			['+'] = "DOOR",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {0, 0},
--			guardian = "SHADE_OF_ANGMAR", -- The gardian is set in the static map
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {type="potion" }, {type="potion" }, {type="potion" }, {type="scroll" }, {}, {} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
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
