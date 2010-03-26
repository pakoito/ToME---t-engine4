load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/ghoul.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Tol Falas, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "THE_MASTER",
	type = "undead", subtype = "vampire", unique = true,
	name = "The Master",
	display = "V", color=colors.VIOLET,
	desc = [[This elder vampire seems to be in control here and does not seem very happy about you.]],
	level_range = {23, 35}, exp_worth = 2,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_mana = 145,
	max_stamina = 145,
	stats = { str=19, dex=19, cun=34, mag=25, con=16 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatsword", ego_chance=100},
		{type="armor", subtype="heavy", ego_chance=50},
		{type="jewelry", subtype="amulet", defined="AMULET_DREAD"},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {type="weapon", subtype="staff", defined="STAFF_ABSORPTION"} },

	summon = {
		{type="undead", number=2, hasxp=true},
	},

	blind_immune = 1,
	stun_immone = 0.7,
	see_invisible = 20,
	undead = 1,

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_MANA_POOL]=1,
			[Talents.T_CONGEAL_TIME]=2,
			[Talents.T_MANATHRUST]=4,
			[Talents.T_FREEZE]=4,
			[Talents.T_PHASE_DOOR]=2,
			[Talents.T_STRIKE]=3,
		[Talents.T_STAMINA_POOL]=1,
			[Talents.T_SWORD_MASTERY]=3,
			[Talents.T_STUNNING_BLOW]=1,
			[Talents.T_RUSH]=4,
			[Talents.T_SPELL_SHIELD]=4,
			[Talents.T_BLINDING_SPEED]=4,
			[Talents.T_PERFECT_STRIKE]=3,
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },

	on_die = function(self, who)
		who:resolveSource():setQuestStatus("tol-falas", engine.Quest.DONE)
	end,
}
