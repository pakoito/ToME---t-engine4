if game.state.has_poosh then return end
game.state.has_poosh = true

game:onLevelLoad("wilderness-1", function(wzone, level)
	local changer = function()
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/feline.lua","/data/general/npcs/fire-drake.lua","/data/general/npcs/wild-drake.lua","/data/general/npcs/telugoroth.lua"}
	local DamageType = engine.DamageType
	local Talents = engine.interface.ActorTalents
	npcs.KELAD = mod.class.NPC.new{
		name="Kelad, the One Who Stole Poosh", image="npc/jawa_01.png",
		type = "unknown", subtype = "unknown", unique = true,
		display = "p", color=colors.VIOLET,
		desc = [[This small creature is covered by a cloak and hood, only a pair of yellow eyes are visible.]],
		level_range = {19, nil}, exp_worth = 1,
		max_life = 230, life_rating = 17, fixed_rating = true,
		stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
		rank = 3.5,
		size_category = 2,
		combat_armor = 4, combat_def = 20,
		infravision = 10,
		instakill_immune = 1,
		stun_immune = 0.6,
		move_others=true,
		combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },
		resists = { [DamageType.DARKNESS] = 20, [DamageType.LIGHT] = 20, [DamageType.TEMPORAL] = 20 },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		resolvers.drops{chance=100, nb=1, {defined="HEART_POOSH"}, },
		resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
		resolvers.talents{
			[Talents.T_DUST_TO_DUST]={base=3, every=7},
			[Talents.T_TURN_BACK_THE_CLOCK]={base=5, every=7},
			[Talents.T_ECHOES_FROM_THE_PAST]={base=4, every=7},
			[Talents.T_RETHREAD]={base=3, every=7},
			[Talents.T_TEMPORAL_FUGUE]={base=3, every=7},
			[Talents.T_BODY_REVERSION]={base=3, every=7},
			[Talents.T_ENERGY_DECOMPOSITION]={base=3, every=7},
			[Talents.T_ENERGY_ABSORPTION]={base=3, every=7},
			[Talents.T_REPULSION_FIELD]={base=3, every=7},
		},
		resolvers.sustains_at_birth(),

		autolevel = "dexmage",
		ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
		resolvers.inscriptions(1, "rune"),

		on_die = function(self, who)
			game.log("#VIOLET#As Kelad dies you can feel the whole area starting to fade. It seems that without him the zone will soon cease to have ever existed.")
		end,
	}

	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	objects.HEART_POOSH = mod.class.Object.new{
		power_source = {nature=true},
		unique = true,
		type = "misc", subtype="land",
		unided_name = "glowing rock",
		name = "Heart of Poosh", image = "object/lava_boulder.png",
		level_range = {20, 35},
		display = "*", color=colors.RED,
		encumber = 5,
		desc = [[The very heart of the lost land of Poosh. What did Kelad need with it?]],

		carrier = {
			inc_damage = {all=2},
		},
		max_power = 100, power_regen = 1,
		use_power = { name = "natural balance", power = 100, use = function(self, who)
			who:incEquilibrium(-30)
			if who.life < who.max_life / 2 then who:heal(who.max_life / 2) end
			return {id=true, used=true}
		end },
	}

	local zone = engine.Zone.new("lost-land-poosh", {
		name = "Lost land of Poosh",
		level_range = {15, 35},
		level_scheme = "player",
		max_level = 2,
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
				floor = "JUNGLE_GRASS",
				wall = "JUNGLE_TREE",
				up = "JUNGLE_GRASS_UP4",
				down = "JUNGLE_GRASS_DOWN6",
				door = "JUNGLE_GRASS",
				do_ponds =  {
					nb = {0, 2},
					size = {w=25, h=25},
					pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
				},
			},
			actor = {
				class = "engine.generator.actor.Random",
				nb_npc = {20, 30},
				guardian = "KELAD",
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
		levels = { [1] = { generator = { map = { up = "JUNGLE_GRASS", }, }, }, },
		npc_list = npcs,
		grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/jungle.lua", "/data/general/grids/water.lua"},
		object_list = objects,
		trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
		all_lited=true,
		foreground = function(level, x, y, nb_keyframes)
			if nb_keyframes > 10 then return end
			local Map = require "engine.Map"
			if not level.bird then
				if nb_keyframes > 0 and rng.chance(500 / nb_keyframes) then
					local dir = -math.rad(rng.float(310, 340))
					local dirv = math.rad(rng.float(-0.1, 0.1))
					local y = rng.range(0, level.map.w / 2 * Map.tile_w)
					local size = rng.range(32, 64)
					level.bird = require("engine.Particles").new("eagle", 1, {x=0, y=y, dir=dir, dirv=dirv, size=size, life=800, vel=7, image="particles_images/birds_tropical_01"})
					level.bird_s = require("engine.Particles").new("eagle", 1, {x=0, y=y, shadow=true, dir=dir, dirv=dirv, size=size, life=800, vel=7, image="particles_images/birds_tropical_shadow_01"})
				end
			else
				local dx, dy = level.map:getScreenUpperCorner()
				if level.bird then level.bird.ps:toScreen(dx, dy, true, 1) end
				if level.bird_s then level.bird_s.ps:toScreen(dx + 100, dy + 120, true, 1) end
				if level.bird and not level.bird.ps:isAlive() then level.bird = nil end
				if level.bird_s and not level.bird_s.ps:isAlive() then level.bird_s = nil end
			end
		end,
	})
	return zone
	end

	local find = {type="world-encounter", subtype="maj-eyal"}
	local where = game.level:pickSpotRemove(find)
	while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
	local x, y = mod.class.Encounter:findSpot(where)
	print("Poosh at ", x, y)
	if not x then return end

	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.name = "Portal to the lost land of Poosh"
	g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
	g.change_level=1 g.change_zone="lost-land-poosh" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/demon_portal4.png", z=5}
	g.nice_tiler = nil
	g:initGlow()
	g.real_change = changer
	g.change_level_check = function(self)
		if game.visited_zones["lost-land-poosh"] then game.log("#VIOLET#The portal seems to be inactive now.")
		else game:changeLevel(1, self.real_change()) end
		return true
	end
	game.zone:addEntity(game.level, g, "terrain", x, y)
	print("Poosh portal added")
end)
local msg = "Message from #GOLD#DarkGod#WHITE#: Today we celebrate hum .. something. Well I just wanted to give an other round of the fabled .... LOST LAND OF POOSH! Enjoy!"
game.log(msg)
require("engine.ui.Dialog"):simpleLongPopup("Poosh?!", msg, 500)
