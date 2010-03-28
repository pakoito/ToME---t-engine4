return {
	name = "Ambush!",
	level_range = {20, 50},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level + 20 end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	persistant = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/tol-falas-ambush",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},

	on_leave = function(lev, old_lev, newzone)
		game.logPlayer(game.player
	end,
}
