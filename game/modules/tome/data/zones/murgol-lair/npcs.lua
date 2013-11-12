-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

load("/data/general/npcs/yaech.lua", function(e) if e.name then e.inc_damage.all = -35 end end)
load("/data/general/npcs/aquatic_critter.lua", rarity(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_YAECH", define_as = "MURGOL",
	unique = true,
	name = "Murgol, the Yaech Lord",
	color=colors.VIOLET,
	desc = [[You can feel the psionic waves of power come from this yaech.]],
	killer_message = "and flushed out to sea",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 100, life_rating = 13, fixed_rating = true,
	psi_regen = 10,
	infravision = 10,
	stats = { str=10, dex=10, cun=15, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	rank = 4,
	tier1 = true,

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1, MAINHAND=1 },

	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
		{type="armor", subtype="light", defined="EEL_SKIN", random_art_replace={chance=65}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_PYROKINESIS]=2,
		[Talents.T_REACH]=2,
		[Talents.T_MINDLASH]=2,
		[Talents.T_MINDHOOK]=2,
		[Talents.T_KINETIC_SHIELD]=3,
		[Talents.T_THERMAL_SHIELD]=3,
	},
	resolvers.sustains_at_birth(),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
	end,
}

if currentZone.is_invaded then

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

	faction = "vargh-republic",
	life_rating = 11,
	rank = 2,
	size_category = 3,

	inc_damage = {all = -35},

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=15, mag=15, con=10 },
	ingredient_on_death = "NAGA_TONGUE",
}

newEntity{ base = "BASE_NPC_NAGA", define_as = "NAGA_TIDEWARDEN",
	name = "naga tidewarden", color=colors.DARK_UMBER,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidewarden.png", display_h=2, display_y=-1}}},
	level_range = {1, nil}, exp_worth = 3,
	rarity = 1,
	max_life = resolvers.rngavg(100,120), life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, force_drop=true, special_rarity="trident_rarity"},
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

newEntity{ base="BASE_NPC_NAGA", define_as = "NASHVA",
	unique = true,
	name = "Lady Nashva the Streambender",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_lady_zoisla_the_tidebringer.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET, female = true,
	desc = [[Water circles slowly on the ground around this naga's tail. Her dark tail is coiled tight, making her look short, but her calm and confident stare assure you that she will not be easily overcome. As the water begins to rise around her the air starts to simmer, and you feel her dark eyes are penetrating into you deeper than is comfortable.]],
	killer_message = "and brought back to Vargh for experimentations",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	tier1 = true,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="trident", defined="TRIDENT_STREAM", random_art_replace={chance=65}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=10, max=5},
		[Talents.T_CHARGE_LEECH]={base=2, every=10, max=5},
		[Talents.T_DISTORTION_BOLT]={base=2, every=10, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=8, max=6},
	},
	resolvers.inscriptions(1, {"movement infusion"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol-invaded")
	end,
}

end
