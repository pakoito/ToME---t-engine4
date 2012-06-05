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

--load("/data/general/npcs/rodent.lua", rarity(5))
--load("/data/general/npcs/vermin.lua", rarity(2))
--load("/data/general/npcs/canine.lua", rarity(0))
--load("/data/general/npcs/troll.lua", rarity(0))
--load("/data/general/npcs/snake.lua", rarity(3))
--load("/data/general/npcs/plant.lua", rarity(0))
--load("/data/general/npcs/swarm.lua", rarity(3))
--load("/data/general/npcs/bear.lua", rarity(2))
--
--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_NAGA",
	type = "humanoid", subtype = "naga",
	display = "n", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	can_breath={water=1},

	life_rating = 11,
	rank = 2,
	size_category = 3,

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=15, dex=15, mag=15, con=10 },
	ingredient_on_death = "NAGA_TONGUE",
}

newEntity{ base = "BASE_NPC_NAGA", define_as = "NAGA_TIDEWARDEN",
	name = "naga tidewarden", color=colors.DARK_UMBER,
	desc = [[Before you stands a tall figure, propped high by a serpent's tail in place of where his legs should rightly be. His torso is slim and muscular, and his face has an elven beauty to it, framed by locks of blonde hair. But there is a fierceness to this creature too, and his bright eyes veil a smouldering anger.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidewarden.png", display_h=2, display_y=-1}}},
	level_range = {1, nil}, exp_worth = 3,
	rarity = 1,
	max_life = resolvers.rngavg(100,120), life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_NAGA", define_as = "NAGA_TIDECALLER",
	name = "naga tidecaller", color=colors.BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidecaller.png", display_h=2, display_y=-1}}},
	desc = [[A slithering noise accompanies the movement of this strange creature, whose snake-like tail gives rise to the body of a beautiful elf-like woman. As she moves her delicate hands water rises from the ground, and you feel that here is no mere monster, but a creature of awe and power.]],
	level_range = {2, nil}, exp_worth = 3, female = true,
	rarity = 1,
	max_life = resolvers.rngavg(50,60), life_rating = 10,
	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=7, max=5},
		[Talents.T_WATER_JET]={base=2, every=7, max=5},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga nereid", color=colors.YELLOW,
	desc = [[Green eyes stare out from behind strands of long, golden hair, which falls down in waves over smooth, pale skin. Your eyes are drawn to the bare flesh, but as they look further they see dark scales stretching out into a long serpent's tail. You look up as she moves, her hair parting to reveal a slim and beautiful face with high cheekbones and full lips. Yet for all the allure of this wondrous creature the terror of the serpentine tail sends shivers down your spine.]],
	level_range = {2, nil}, exp_worth = 3, female = true,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=7, max=5},
		[Talents.T_MIND_SEAR]={base=2, every=7, max=5},
		[Talents.T_TELEKINETIC_BLAST]={base=2, every=7, max=5},
	},
}

newEntity{ base="BASE_NPC_NAGA", define_as = "ZOISLA",
	unique = true,
	name = "Lady Zoisla the Tidebringer",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_lady_zoisla_the_tidebringer.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET, female = true,
	desc = [[Water circles slowly on the ground around this naga's tail, some droplets leaping up now and then as if they are impatient to do their mistress' bidding. Her dark tail is coiled tight, making her look short, but her calm and confident stare assure you that she will not be easily overcome. As the water begins to rise around her the air starts to simmer, and you feel her dark eyes are penetrating into you deeper than is comfortable.]],
	killer_message = "and brougth back to Vargh for experimentations",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{defined="ROBES_DEFLECTION", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="SLAZISH_NOTE3"} },

	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=10, max=5},
		[Talents.T_WATER_BOLT]={base=2, every=10, max=5},
		[Talents.T_MIND_SEAR]={base=2, every=10, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=8, max=6},
	},
	resolvers.inscriptions(1, {"movement infusion"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish")
	end,
}
