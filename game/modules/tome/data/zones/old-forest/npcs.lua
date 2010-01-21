load("/data/general/npcs/bear.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/wolf.lua")
load("/data/general/npcs/snake.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "OLD_MAN_WILLOW",
	type = "giant", subtype = "ent", unique = true,
	name = "Old Man Willow",
	display = "#", color=colors.OLIVE_DRAB,
	desc = [[The ancient grey willow tree, ruler of the Old Forest. He despises
	trespassers in his territory.  "...a huge willow-tree, old and hoary
	Enormous it looked, its sprawling branches going up like racing arms
	with may long-fingered hands, its knotted and twisted trunk gaping in
	wide fissures that creaked faintly as the boughs moved."]],
	level_range = {7, 10}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },

	resists = { [DamageType.FIRE] = -50 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="armor", subtype="shield", defined="OLD_MAN_WILLOW_SHIELD"}, },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	talents = resolvers.talents{
		[Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2,

		[Talents.T_MANA_POOL]=1,
		[Talents.T_ICE_STORM]=1,
		[Talents.T_TIDAL_WAVE]=1,
		[Talents.T_FREEZE]=2,
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
}
