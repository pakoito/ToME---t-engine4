local Talents = require("engine.interface.ActorTalents")

newEntity{
	group = "dragon",
	name = "dragon of death",
	display = "D", color_r=255,
	level_range = {3, 10}, exp_worth = 1,
	rarity = 4,
	autolevel = "warrior",
	ai = "simple",
	max_life = 100,
	life_rating = 10,
	max_mana = 1000,
	max_stamina = 1000,
	energy = { mod=0.5 },
	has_blood = true,
	stats = { str=15, dex=8, mag=12, con=14 },
	combat = { dam=8, atk=10, apr=2, def=4, armor=6},
}
--[[
newEntity{
	group = "dragon",
	name = "baby dragon",
	display = "d", color_r=128,
--	faction = "poorsods",
	level_range = {1, 4}, exp_worth = 100,
	rarity = 2,
	autolevel = "caster",
	ai = "simple",
	max_life = resolvers.rngavg(20,30),
	max_mana = 1000,
	max_stamina = 1000,
	energy = { mod=0.3 },
	has_blood = {nb=3, color={50,255,120}},
	combat = { dam=5, atk=6, def=2, apr=1, armor=2},
}
]]
newEntity{
	group = "icky things",
	name = "white icky",
	display = "i", color=colors.YELLOW,
	level_range = {1, 7}, exp_worth = 1,
	rarity = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple",
	ai_state = { talent_in=12, },
	max_life = resolvers.rngavg(10,20),
	max_mana = resolvers.rngavg(50,60),
	energy = { mod=0.3 },
	has_blood = {nb=3, color={50,255,120}},
	combat = { dam=5, atk=6, def=2, apr=1, armor=2 },
	stats = { str=10, dex=7, mag=14, con=10 },
	talents = { Talents.T_MANATHRUST, Talents.T_FREEZE, Talents.T_FLAME }
}
newEntity{
	group = "goblin",
	name = "small goblin",
	display = "g", color=colors.GREEN,
	level_range = {1, 7}, exp_worth = 1,
	rarity = 1,
	autolevel = "warrior",
	ai = "dumb_talented_simple",
	ai_state = { talent_in=6, },
	max_life = resolvers.rngavg(10,20),
	max_stamina = resolvers.rngavg(50,60),
	energy = { mod=0.3 },
	has_blood = true,

	body = {
		INVEN = 1000, MAINHAND = 1, OFFHAND = 1,
		FINGER = 2, NECK = 1, LITE = 1,
		BODY = 1, HEAD = 1, HANDS = 1, FEET = 1,
		TOOL = 1,
	},
	equipment = resolvers.equip{ {type="weapon", subtype="longsword"}, {type="armor", subtype="massive"}, {type="armor", subtype="shield"}, },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	stats = { str=14, dex=12, mag=8, con=13 },
	talents = { },
}
