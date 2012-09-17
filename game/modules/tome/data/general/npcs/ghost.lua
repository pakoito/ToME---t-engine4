-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	define_as = "BASE_NPC_GHOST",
	type = "undead", subtype = "ghost",
	blood_color = colors.GREY,
	display = "G", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1, sound={"creatures/ghost/attack%d", 1, 2} },

	sound_moam = {"creatures/ghost/on_hit%d", 1, 2},
	sound_die = {"creatures/ghost/death%d", 1, 1},
	sound_random = {"creatures/ghost/random%d", 1, 1},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=40, talent_in=2, },
	dont_pass_target = true,
	stats = { str=14, dex=18, mag=20, con=12 },
	rank = 2,
	size_category = 3,
	infravision = 10,

	can_pass = {pass_wall=70},
	resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},

	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	teleport_immune = 0.5,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	cut_immune = 1,
	see_invisible = 80,
	undead = 1,
	resolvers.sustains_at_birth(),
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "dread", color=colors.ORANGE, image="npc/dread.png",
	desc = [[It is a form that screams its presence against the eye. Death incarnate, its hideous black body seems to struggle against reality as the universe itself strives to banish it.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 10,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	stealth = resolvers.mbonus(40, 10),
	ai_state = { talent_in=4, },

	combat = { dam=resolvers.mbonus(45, 45), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },

	resolvers.talents{
		[Talents.T_BURNING_HEX]={base=3, every=5, max=7},
		[Talents.T_BLUR_SIGHT]={base=4, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "dreadmaster", color=colors.YELLOW, image="npc/dreadmaster.png",
	desc = [[It is an unlife of power almost unequalled. An affront to existence, its very touch abuses and disrupts the flow of life, and its unearthly limbs, of purest black, crumble rock and wither flesh with ease.]],
	level_range = {32, nil}, exp_worth = 1,
	rarity = 15,
	rank = 3,
	max_life = resolvers.rngavg(140,170),

	ai = "tactical",

	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	stealth = resolvers.mbonus(30, 20),

	combat = { dam=resolvers.mbonus(65, 65), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },

	summon = {{type="undead", subtype="ghost", name="dread", number=3, hasxp=false}, },
	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_BLUR_SIGHT]={base=4, every=6, max=8},
		[Talents.T_DISPERSE_MAGIC]={base=3, every=7, max=6},
		[Talents.T_SILENCE]={base=2, every=10, max=6},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "banshee", color=colors.BLUE, image="npc/banshee.png", female=1,
	desc = [[It is a ghostly woman's form that wails mournfully.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 8,
	max_life = resolvers.rngavg(40,50), life_rating = 6,

	combat_armor = 0, combat_def = resolvers.mbonus(10, 10),
	stealth = resolvers.mbonus(40, 10),

	combat = { dam=5, atk=5, apr=100, dammod={str=0.5, mag=0.5} },

	resolvers.talents{
		[Talents.T_SHRIEK]=4,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_BLUR_SIGHT]={base=3, every=6, max=6},
		[Talents.T_SILENCE]={base=2, every=10, max=5},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=6},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "ruin banshee", color=colors.GREY,
	desc = [[A vengeful, screaming soul given form with the breath of Urh'Rok himself. The vapors of the Fearscape seep from its dimension-bending form, withering and searing.]],
	level_range = {42, nil}, exp_worth = 1,
	rarity = 15,
	rank = 3,
	max_life = resolvers.rngavg(240,270),

	ai = "tactical",

	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(25, 25)},
	stealth = resolvers.mbonus(50, 20),

	combat = { dam=resolvers.mbonus(85, 85), atk=resolvers.mbonus(45, 45), apr=100, dammod={str=0.7, mag=0.7} },

	resolvers.talents{
		[Talents.T_PHASE_DOOR]=10,
		[Talents.T_SILENCE]={base=2, every=10, max=6},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=8},
		[Talents.T_CORRUPTED_NEGATION]={base=5, every=6, max=8},
		[Talents.T_CORROSIVE_WORM]={base=4, every=5, max=12},
		[Talents.T_POISON_STORM]={base=4, every=5, max=12},
		[Talents.T_CURSE_OF_DEATH]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_IMPOTENCE]={base=5, every=6, max=8},
	},
}