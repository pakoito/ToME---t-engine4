return {
	name = "Tranquil Meadow",
	level_range = {15, 25},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 6,
	persistent = "zone",
	no_worldport = true,
	day_night = true,
	width = 45, height = 45,
	
	min_material_level = 2,
	max_material_level = 3,

	ambient_music = "Woods of Eremae.ogg",

	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 600,
			floor = "CAVEFLOOR",
			wall = "CAVEWALL",
			up = "CAVE_LADDER_UP",
			down = "CAVE_LADDER_DOWN",
			door = "CAVEFLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = {{special_rarity="cave_rarity"}},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {10, 14},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {30, 30},
		},
	},
		
	levels =
	{
		-- Meadow
		[1] = {
			no_worldport = true,
			ambient_music = "Woods of Eremae.ogg",
			width = 24, height = 24,
			all_remembered = true,
			all_lited = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/keepsake-meadow",
				},
				trap = { nb_trap = {0, 0} },
				object = { nb_object = {0, 0} },
				actor = { nb_npc = {0, 0} },
			},
		},
		-- Dream
		[2] = {
			no_worldport = true,
			ambient_music = "Inside a dream.ogg",
			width = 24, height = 24,
			all_lited = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/keepsake-dream",
				},
				trap = { nb_trap = {0, 0} },
				object = { nb_object = {0, 0} },
				actor = { nb_npc = {0, 0} },
			},
		},
		-- Cave Entrance
		[3] = {
			no_worldport = true,
			ambient_music = "Suspicion.ogg",
			width = 24, height = 24,
			all_lited = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/keepsake-cave-entrance",
				},
				trap = { nb_trap = {0, 0} },
				object = { nb_object = {0, 0} },
				actor = { nb_npc = {0, 0} },
			},
		},
		-- Cave Last
		[6] = {
			no_worldport = true,
			ambient_music = "Suspicion.ogg",
			width = 36, height = 30,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/keepsake-cave-last",
				},
				trap = { nb_trap = {0, 0} },
				object = { nb_object = {0, 0} },
				actor = { nb_npc = {0, 0} },
			},
		}
	},

	post_process = function(level)
		if level.level == 3 then
			-- make sure you land in the right spot
			local spot = game.level:pickSpot{type="level", subtype="up"}
			level.default_up.x = spot.x
			level.default_up.y = spot.y
			local spot = game.level:pickSpot{type="level", subtype="down"}
			level.default_down.x = spot.x
			level.default_down.y = spot.y
		elseif level.level == 4 then
			game:placeRandomLoreObject("KYLESS_JOURNAL_1")
			game:placeRandomLoreObject("KYLESS_JOURNAL_2")
		elseif level.level == 5 then
			game:placeRandomLoreObject("KYLESS_JOURNAL_3")
			game:placeRandomLoreObject("KYLESS_JOURNAL_4")
		end
	end,

	foreground = function(level, x, y, nb_keyframes)
	end,
	
	on_enter = function(lev, old_lev, zone)
		if lev == 1 then
			local q = game.player:hasQuest("keepsake")
			if q then
				q:on_enter_meadow(game.player)
			end
		elseif lev == 3 then
			local q = game.player:hasQuest("keepsake")
			if q then
				q:on_enter_cave_entrance(game.player)
			end
		end
	end,

	on_leave = function(lev, old_lev, newzone)
	end,
}
