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

load("/data/general/npcs/gwelgoroth.lua", function(e) if e.rarity then e.POINT_ZERO_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_POINT_ZERO_TOWN",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "point-zero-guardians",
	anger_emote = "Catch @himher@!",
	hates_antimagic = 1,

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN",
	name = "POINT_ZERO guard", color=colors.LIGHT_UMBER,
	desc = [[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN",
	name = "halfling slinger", color=colors.UMBER,
	subtype = "halfling",
	desc = [[A Halfling, with a sling. Beware.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "slinger",
	resolvers.equip{ {type="weapon", subtype="sling", autoreq=true}, {type="ammo", subtype="shot", autoreq=true} },
}

newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN",
	name = "human farmer", color=colors.WHITE,
	desc = [[A weather-worn Human farmer.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN",
	name = "halfling gardener", color=colors.WHITE,
	subtype = "halfling",
	desc = [[A Halfling, he seems to be looking for plants.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
}

newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN", define_as = "DEFENDER_OF_REALITY",
	name = "guardian of reality", color=colors.YELLOW,
	image = resolvers.rngtable{"npc/humanoid_elf_star_crusader.png", "npc/humanoid_elf_anorithil.png"},
	female = resolvers.rngtable{false, true},
	subtype = resolvers.rngtable{"human", "shalore"},
	shader = "moving_transparency", shader_args = {a_min=0.2, a_max=0.8},
	desc = [[A stern-looking guardian, ever vigilant from the threats of the paradox.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = false,
	max_life = 400,
	life_regen = 200,
	paradox_regen = -100,
	never_move = 1,
	cant_be_moved = 1,

	combat_spellpower = 300,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	talent_cd_reduction={[Talents.T_DUST_TO_DUST]=1},
	resolvers.talents{ [Talents.T_DUST_TO_DUST]=10, },
}

newEntity{
	define_as = "BASE_NPC_LOSGOROTH", -- lost goroth = void terror
	type = "elemental", subtype = "void",
	blood_color = colors.DARK_GREY,
	display = "E", color=colors.DARK_GREY,
	desc = [[Losgoroth are mighty void elementals, native to the void between the stars, they are rarely seen on the planet's surface.]],

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.ARCANE },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 8,
	life_regen = 0,
	rank = 2,
	size_category = 3,
	levitation = 1,
	can_pass = {pass_void=70},
	inc_damage = {all = -80},

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=10, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = -30, [DamageType.ARCANE] = 100 },

	no_breath = 1,
	poison_immune = 1,
	disease_immune = 1,
	cut_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
	power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_LOSGOROTH", define_as = "MONSTROUS_LOSGOROTH",
	name = "monstrous losgoroth", color=colors.GREY, image = "npc/elemental_void_losgoroth.png",
	level_range = {50, nil}, exp_worth = 1,
	rarity = false,
	max_life = 500,
	combat_armor = 0, combat_def = 20,

	faction = "point-zero-onslaught",

	talent_cd_reduction={[Talents.T_VOID_BLAST]=1},
	resolvers.talents{
		[Talents.T_VOID_BLAST]=1,
	},
}


newEntity{ base = "BASE_NPC_POINT_ZERO_TOWN", define_as = "ZEMEKKYS",
	name = "Zemekkys, Grand Keeper of Reality", color=colors.VIOLET,
	image = "npc/humanoid_elf_high_chronomancer_zemekkys.png",
	subtype = "shalore",
	desc = [[A timeless elf stands before you. Even though his age is impossible to sense you feel he has seen many things.]],
	level_range = {50, nil}, exp_worth = 1,
	rarity = false,
	max_life = 2000, life_rating = 20,
	life_regen = 50,
	paradox_regen = -10,
	never_move = 1,
	cant_be_moved = 1,

	faction = "keepers-of-reality",

	can_talk = "point-zero-zemekkys",

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(5, {}),
	resolvers.inscriptions(1, "rune"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	combat_spellcrit = 70,
	combat_spellpower = 60,
	inc_damage = {all=80},

	resists = {[DamageType.TEMPORAL]=100},

	combat_spellresist = 250,
	combat_mentalresist = 250,
	combat_physresist = 250,

	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true, forbid_power_source={antimagic=true}, tome_drops="boss"},
		{type="armor", subtype="cloth", autoreq=true, forbid_power_source={antimagic=true}, tome_drops="boss"},
	},

	talent_cd_reduction = {all=23},
	resolvers.talents{
		[Talents.T_TEMPORAL_FORM]=1,
		[Talents.T_DRACONIC_BODY]=1,
		[Talents.T_LUCKY_DAY]=1,
		[Talents.T_ENDLESS_WOES]=1,
		[Talents.T_EYE_OF_THE_TIGER]=1,
		[Talents.T_GATHER_THE_THREADS]=5,
		[Talents.T_RETHREAD]=5,
		[Talents.T_TEMPORAL_CLONE]=5,
		[Talents.T_STOP]=5,
		[Talents.T_SLOW]=5,
		[Talents.T_HASTE]=5,
		[Talents.T_BANISH]=5,
		[Talents.T_PARADOX_MASTERY]=5,
		[Talents.T_FADE_FROM_TIME]=5,
		[Talents.T_DUST_TO_DUST]=5,
		[Talents.T_QUANTUM_SPIKE]=5,
		[Talents.T_REPULSION_BLAST]=5,
		[Talents.T_GRAVITY_SPIKE]=5,
		[Talents.T_REPULSION_FIELD]=5,
		[Talents.T_GRAVITY_WELL]=5,
		[Talents.T_ENERGY_DECOMPOSITION]=5,
		[Talents.T_ENERGY_ABSORPTION]=5,
		[Talents.T_REDUX]=5,
		[Talents.T_TEMPORAL_FUGUE]=5,
		[Talents.T_BODY_REVERSION]=5,
	},
	resolvers.sustains_at_birth(),
}
