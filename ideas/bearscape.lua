if game.state.has_bearscape then return end
game.state.has_bearscape = true

game:onLevelLoad("wilderness-1", function(wzone, level)
	local changer = function()
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/bear.lua"}
	local DamageType = engine.DamageType
	local Talents = engine.interface.ActorTalents
	npcs.BORIUS = mod.class.NPC.new{
		name="Borius, Avatar of Bearness",
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_bear_norgos_the_guardian.png", display_h=2, display_y=-1}}},
		type = "animal", subtype = "bear", unique = true,
		display = "q", color=colors.VIOLET,
		desc = [[This creature has the form of a bear, only times bigger. It represents all that is bear in the bearscape!]],
		level_range = {15, nil}, exp_worth = 1,
		max_life = 230, life_rating = 22, fixed_rating = true,
		stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=35 },
		rank = 3.5,
		size_category = 4,
		combat_armor = 25, combat_def = 6,
		infravision = 10,
		instakill_immune = 1,
		stun_immune = 1,
		move_others=true,
		combat = { dam=resolvers.levelup(resolvers.rngavg(30,190), 1, 2), atk=resolvers.rngavg(25,70), apr=35, dammod={str=1.1} },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		resolvers.drops{chance=100, nb=1, {defined="BEAR_PAW"}, },
		resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
		resolvers.talents{
			[Talents.T_CRUSHING_HOLD]={base=3, every=7},
			[Talents.T_CLINCH]={base=5, every=7},
			[Talents.T_MAIM]={base=4, every=7},
			[Talents.T_TAKE_DOWN]={base=3, every=7},
			[Talents.T_UPPERCUT]={base=3, every=7},
			[Talents.T_VICIOUS_STRIKES]={base=3, every=7},
			[Talents.T_UNARMED_MASTERY]={base=3, every=7},
			[Talents.T_COMBO_STRING]={base=3, every=7},
			[Talents.T_SHATTERING_SHOUT]={base=3, every=7},
		},
		resolvers.sustains_at_birth(),

		autolevel = "warrior",
		ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
		resolvers.inscriptions(2, "infusion"),
	}

	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	objects.BEAR_PAW = mod.class.Object.new{
		power_source = {nature=true},
		unique = true,
		slot = "TOOL",
		type = "misc", subtype="animal",
		unided_name = "bear paw",
		name = "Essence of Bearness", image = "object/bear_paw.png",
		level_range = {20, 35},
		display = "*", color=colors.GREEN,
		encumber = 3,
		desc = [[The very essence of bearness!]],

		max_power = 100, power_regen = 1,
		use_power = { name = "invoke your inner bearness", power = 100, use = function(self, who)
			who:setEmote(require("engine.Emote").new("GROOOOOWWWLLLLL!!!!", 80))
			who:setEffect(who.EFF_PAIN_SUPPRESSION, 5, {power=25})
			return {id=true, used=true}
		end },
	}

	local zone = mod.class.Zone.new("bearscape", {
		name = "Bearscape",
		level_range = {12, 35},
		level_scheme = "player",
		max_level = 3,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = "Rainy Day.ogg",
		reload_lists = false,
		generator =  {
			map = {
				class = "engine.generator.map.Forest",
				edge_entrances = {4,6},
				zoom = 4,
				sqrt_percent = 30,
				noise = "fbm_perlin",
				floor = "GRASS",
				wall = "TREE",
				up = "GRASS",
				down = "GRASS_DOWN6",
				door = "GRASS",
				do_ponds =  {
					nb = {0, 2},
					size = {w=25, h=25},
					pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
				},
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {35, 45},
				guardian = "BORIUS",
				randelite = 3,
			},
			object = {
				class = "engine.generator.object.Random",
				nb_object = {6, 9},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {6, 9},
			},
		},
		levels = { [1] = { generator = { map = { up = "GRASS", }, }, }, },
		npc_list = npcs,
		grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua", "/data/general/grids/water.lua"},
		object_list = objects,
		trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
		all_lited=true,

		post_process = function(level)
			if not config.settings.tome.weather_effects then return end

			local Map = require "engine.Map"
			level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})

			game.state:makeWeather(level, 6, {max_nb=3, chance=1, dir=110, speed={0.1, 0.6}, alpha={0.3, 0.5}, particle_name="weather/dark_cloud_%02d"})

			game.state:makeAmbientSounds(level, {
				wind={ chance=120, volume_mod=1.9, pitch=2, random_pos={rad=10}, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
				creature={ chance=2500, volume_mod=0.6, pitch=0.5, random_pos={rad=10}, files={"creatures/bears/bear_growl_2", "creatures/bears/bear_growl_3", "creatures/bears/bear_moan_2"}},
			})
		end,
		foreground = function(level, x, y, nb_keyframes)
			if not config.settings.tome.weather_effects or not level.foreground_particle then return end
			level.foreground_particle.ps:toScreen(x, y, true, 1)
		end,
	})
	return zone
	end

	local find = {type="world-encounter", subtype="maj-eyal"}
	local where = game.level:pickSpotRemove(find)
	while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
	local x, y = mod.class.Encounter:findSpot(where)
	print("Bearscape at ", x, y)
	if not x then return end

	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.name = "Portal to the Bearscape"
	g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
	g.change_level=1 g.change_zone="bearscape" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/demon_portal4.png", z=5}
	g.nice_tiler = nil
	g:initGlow()
	g.real_change = changer
	g.change_level_check = function(self)
		if game.visited_zones["bearscape"] then game.log("#VIOLET#The portal seems to be inactive now.")
		else game:changeLevel(1, self.real_change()) end
		return true
	end
	game.zone:addEntity(game.level, g, "terrain", x, y)
	print("Bearscape portal added")
end)
local msg = "Message from #GOLD#DarkGod#WHITE#: Grooooowwwlll. The Bearscape has come!\nThis is an event you got to enjoy because you were logged in at the right time, look for a portal on your worldmap!\nBeware, Bears are cute but this zone might not be that easy! Level 15 recommended."
game.log(msg)
require("engine.ui.Dialog"):simpleLongPopup("Bears?!", msg, 500)
