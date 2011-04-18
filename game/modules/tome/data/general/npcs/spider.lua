-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SPIDER",
	type = "spiderkin", subtype = "spider",
	display = "S", color=colors.WHITE,
	desc = [[Arachnophobia...]],

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.NATURE, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 20,
	size_category = 2,
	rank = 1,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
	global_speed = 1.2,
	stats = { str=15, dex=15, mag=8, con=10 },

	resolvers.inscriptions(2, "infusion"),

	resolvers.tmasteries{ ["technique/other"]=0.3 },
	resolvers.sustains_at_birth(),

	poison_immune = 0.9,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20 },
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "giant spider", color=colors.LIGHT_DARK,
	desc = [[A huge arachnid, it produces even bigger webs.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 10,

	combat_armor = 5, combat_def = 5,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=1, every=10, max=5},
		[Talents.T_LAY_WEB]={base=1, every=10, max=5},
	},
	on_die = function(self, who)
		local part = "SPIDER_SPINNERET"
		if game.player:hasQuest("brotherhood-of-alchemists") then
			game.player:hasQuest("brotherhood-of-alchemists"):need_part(who, part, self)
		end
	end,
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "spitting spider", color=colors.DARK_UMBER,
	desc = [[A huge arachnid, it sprays venom at its prey.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 60,
	life_rating = 10,

	combat_armor = 5, combat_def = 10,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_SPIT_POISON]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "chitinous spider", color=colors.LIGHT_GREEN,
	desc = [[A huge arachnid with a massive exoskeleton.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 70,
	life_rating = 10,

	combat_armor = 10, combat_def = 14,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "gaeramarth", color=colors.LIGHT_DARK,  -- dreadful fate
	desc = [[These cunning spiders terrorize those who enter the ever-growing borders of their lairs.  Those who encounter them rarely return.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,

	combat_armor = 7, combat_def = 17,

	rank = 2,

	resolvers.tmasteries{ ["cunning/stealth"]=0.3},

	resolvers.talents{
		[Talents.T_RUSH]={base=4, every=6, max=7},
		[Talents.T_SPIDER_WEB]={base=4, every=6, max=7},
		[Talents.T_LAY_WEB]={base=4, every=6, max=7},
		[Talents.T_STEALTH]={base=4, every=6, max=7},
		[Talents.T_SHADOWSTRIKE]={base=4, every=6, max=7},
		[Talents.T_STUN]={base=2, every=6, max=5},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "ninurlhing", color=colors.DARK_GREEN,  -- water burn spider (acidic)
	desc = [[The air reeks with noxious fumes and the ground around it decays.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,
	rank = 2,

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["wild-gift/slime"]=0.3, ["spell/water"]=0.3 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_ACIDIC_SKIN]={base=5, every=6, max=8},
		[Talents.T_CORROSIVE_VAPOUR]={base=5, every=6, max=8},
		[Talents.T_CRAWL_ACID]={base=3, every=6, max=6},
		[Talents.T_STUN]={base=2, every=6, max=7},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "faerlhing", color=colors.PURPLE,  -- spirit spider (arcane)
	desc = [[This spider seems to command the flow of mana, which pulses freely through its body.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	max_mana = 380,
	life_rating = 12,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/phantasm"]=0.3, ["spell/water"]=0.3, ["spell/arcane"]=0.3 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_PHANTASMAL_SHIELD]={base=5, every=6, max=8},
		[Talents.T_PHASE_DOOR]={base=5, every=6, max=8},
		[Talents.T_MANATHRUST]={base=5, every=6, max=8},
		[Talents.T_MANAFLOW]={base=5, every=6, max=8},
		[Talents.T_DISRUPTION_SHIELD]={base=3, every=6, max=6},
		[Talents.T_ARCANE_POWER]={base=3, every=6, max=6},
	},
	on_die = function(self, who)
		local part = "FAERLHING_FANG"
		if game.player:hasQuest("brotherhood-of-alchemists") then
			game.player:hasQuest("brotherhood-of-alchemists"):need_part(who, part, self)
		end
	end,

}

-- the brethren of Ungoliant :D  tough and deadly, probably too tough, but meh <evil laughter>
newEntity{ base = "BASE_NPC_SPIDER",
	name = "ungolmor", color={0,0,0},  -- spider night, don't change the color
	desc = [[Largest of all the spiderkin, its folds of skin seem nigh impenetrable.]],
	level_range = {38, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 75, combat_def = 12,  -- perhaps too impenetrable?  though at this level people should be doing over 100 damage each hit, so it could be more :D

	resolvers.tmasteries{ ["spell/nature"]=0.9 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_REGENERATION]={base=5, every=6, max=8},
		[Talents.T_BITE_POISON]={base=5, every=6, max=8},
		[Talents.T_DARKNESS]={base=5, every=6, max=8},
		[Talents.T_RUSH]=5,
		[Talents.T_STUN]={base=3, every=6, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "losselhing", color=colors.LIGHT_BLUE,  -- snow star spider
	desc = [[The air seems to freeze solid around this frigid spider.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 14,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/enhancement"]=0.7, ["wild-gift/cold-drake"]=0.7, ["spell/water"]=0.7 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_FREEZE]={base=5, every=6, max=8},
		[Talents.T_ICY_SKIN]={base=5, every=6, max=8},
		[Talents.T_TIDAL_WAVE]={base=3, every=6, max=6},
		[Talents.T_ICE_STORM]={base=2, every=6, max=6},
		[Talents.T_FROST_HANDS]={base=5, every=6, max=8},
	},

}
