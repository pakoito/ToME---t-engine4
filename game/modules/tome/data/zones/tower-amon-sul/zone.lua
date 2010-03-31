return {
	name = "Tower of Amon Sûl",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistant = "zone",
--	ambiant_music = "10_23.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"simple", "pilar", {"money_vault",5}},
			lite_room_chance = 100,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
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
		[5] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/tower-amon-sul-last",
			}, },
		},
	},
}
