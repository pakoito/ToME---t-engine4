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
	define_as = "BASE_NPC_TROLL",
	type = "giant", subtype = "troll",
	display = "T", color=colors.UMBER,
	sound_moam = {"creatures/trolls/troll_moan_%d", 1, 2},
	sound_die = {"creatures/trolls/troll_die_%d", 1, 2},
	sound_random = {"creatures/trolls/troll_growl_%d", 1, 4},

	combat = { dam=resolvers.levelup(resolvers.mbonus(45, 10), 1, 1), atk=2, apr=6, physspeed=2, dammod={str=0.8}, sound="creatures/trolls/stomp" },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 15,
	life_regen = 2,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },

	open_door = true,

	resists = { [DamageType.FIRE] = -50 },
	fear_immune = 1,
	ingredient_on_death = "TROLL_INTESTINE",
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "forest troll", color=colors.YELLOW_GREEN, image="npc/troll_f.png",
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 4, combat_def = 0,
}


newEntity{ base = "BASE_NPC_TROLL",
	name = "stone troll", color=colors.DARK_SLATE_GRAY, image="npc/troll_s.png",
	desc = [[A giant troll with scabrous black skin. With a shudder, you notice the belt of dwarf skulls around his massive waist.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 7, combat_def = 0,
	resolvers.talents{[Talents.T_STUN]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=1, every=7, max=5}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "cave troll", color=colors.SLATE, image="npc/troll_c.png",
	desc = [[This huge troll wields a massive spear and has a disturbingly intelligent look in its piggy eyes.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 9, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=2, every=7, max=5}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll", color=colors.UMBER, image="npc/troll_m.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 12, combat_def = 4,
	resolvers.talents{ [Talents.T_STUN]={base=3, every=7, max=8}, [Talents.T_KNOCKBACK]={base=3, every=7, max=8}, [Talents.T_RUSH]={base=3, every=7, max=8}, [Talents.T_DISARM]={base=3, every=7, max=8}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll thunderer", color=colors.AQUAMARINE, image="npc/troll_mt.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(120,140),
	mana_regen = 20,
	combat_armor = 8, combat_def = 4,
	autolevel = "warriormage",
	ai = "tactical",
	resolvers.inscriptions(1, "rune"),
	resolvers.talents{
		[Talents.T_STUN]={base=4, every=6, max=8},
		[Talents.T_KNOCKBACK]={base=3, every=7, max=8},
		[Talents.T_LIGHTNING]={base=4, every=7, max=8},
		[Talents.T_THUNDERSTORM]={base=3, every=7, max=8},
	},
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "patchwork troll", color=colors.PURPLE,
	desc = [[A disgusting and mismatched construct of necromantically-enhanced troll bits and shattered weapons. Confused and furious, it rends and shatters its surroundings with impossible strength, moving with speed found nowhere in nature.]],
	resolvers.nice_tile{tall=1},
	level_range = {38, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	global_speed_base = 1.6,
	life_rating = 25,
	max_life = resolvers.rngavg(220,240),

	combat_armor = 60, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=15, dammod={str=1.5} },
	autolevel = "warrior",
	ai = "tactical",
	stamina_regen = 100,
	stun_immune = 1,
	knockback_immune = 1,
	blind_immune = 1,

	resolvers.talents{
		[Talents.T_STUN]={base=5, every=6, max=12},
		[Talents.T_RUSH]=8,
		[Talents.T_BLINDING_SPEED]={base=4, every=7, max=10},
		[Talents.T_FAST_METABOLISM]={base=5, every=5, max=30},
		[Talents.T_UNFLINCHING_RESOLVE]={base=5, every=5, max=10},
		[Talents.T_JUGGERNAUT]={base=5, every=5, max=10},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_TROLL", unique=true,
	name = "Forest Troll Hedge-Wizard", color=colors.YELLOW_GREEN, 
	resolvers.nice_tile{tall=1},
	desc = [[This old looking troll glares at you with malice. His muscles appear atrophied, but a certain power surrounds him nonetheless.]],
	level_range = {3, nil}, exp_worth = 2,
	rank=3.5,
	rarity = 40,
	max_life = resolvers.rngavg(50,70),
	life_rating=18,
	combat_armor = 4, combat_def = 0,
	
	resolvers.tmasteries{ ["spell/arcane"]=-0.8, ["spell/aegis"]=0.4,["spell/fire"]=-0.8, },
	autolevel = "caster",
	stats = { str=8, dex=8, mag=20, con=12, cun=12, },
	ai = "tactical",
	
	on_added_to_level = function(self)
		self.inc_damage={[DamageType.FIRE]=math.min(self.level*2,50),}
	end,
	
	resolvers.talents{
		[Talents.T_SHIELDING]={base=1, every=5, max=5},
		[Talents.T_MANATHRUST]={base=1, every=1, max=50},
		[Talents.T_FLAME]={base=1, every=2, max=15},
	},
	
	resolvers.sustains_at_birth(),
	
	resolvers.inscription("RUNE:_REFLECTION_SHIELD", {cooldown=14,}),
	resolvers.drops{chance=100, nb=1, {defined="RUNE_REFLECT", random_art_replace={chance=50}} },
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },
}
