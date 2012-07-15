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
	define_as = "BASE_NPC_BONE_GIANT",
	type = "undead", subtype = "giant",
	blood_color = colors.GREY,
	display = "K", color=colors.WHITE,

	combat = { dam=resolvers.levelup(resolvers.mbonus(45, 20), 1, 1), atk=15, apr=10, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 12,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	stats = { str=20, dex=52, mag=16, con=16 },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.BLIGHT] = 20, [DamageType.COLD] = 50, },

	open_door = 1,
	no_breath = 1,
	confusion_immune = 1,
	poison_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	stun_immune = 1,
	see_invisible = resolvers.mbonus(15, 5),
	undead = 1,
	ingredient_on_death = "BONE_GOLEM_DUST",
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_BONE_GIANT",
	name = "bone giant", color=colors.WHITE,
	desc = [[A towering creature, made from the bones of dozens of dead bodies. It is covered by an unholy aura.]],
	level_range = {25, nil}, exp_worth = 1,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_bone_giant.png", display_h=2, display_y=-1}}},
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 20, combat_def = 0,
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_BONE_ARMOUR]={base=3, every=10, max=5}, [Talents.T_STUN]={base=3, every=10, max=5}, },
}

newEntity{ base = "BASE_NPC_BONE_GIANT",
	name = "eternal bone giant", color=colors.GREY,
	desc = [[A towering creature, made from the bones of hundreds of dead bodies. It is covered by an unholy aura.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_eternal_bone_giant.png", display_h=2, display_y=-1}}},
	level_range = {33, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 40, combat_def = 20,
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	autolevel = "warriormage",
	resists = {all = 50},
	resolvers.talents{ [Talents.T_BONE_ARMOUR]={base=5, every=10, max=7}, [Talents.T_STUN]={base=3, every=10, max=5}, [Talents.T_SKELETON_REASSEMBLE]=5, },
}

newEntity{ base = "BASE_NPC_BONE_GIANT",
	name = "heavy bone giant", color=colors.LIGHT_UMBER,
	desc = [[A towering creature, made from the bones of hundreds of dead bodies. It is covered by an unholy aura.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_heavy_bone_giant.png", display_h=2, display_y=-1}}},
	level_range = {35, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 20, combat_def = 0,
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_BONE_ARMOUR]={base=3, every=10, max=5}, [Talents.T_THROW_BONES]={base=4, every=10, max=7}, [Talents.T_STUN]={base=3, every=10, max=5}, },
}

newEntity{ base = "BASE_NPC_BONE_GIANT",
	name = "runed bone giant", color=colors.RED,
	desc = [[A towering creature, made from the bones of hundreds of dead bodies, rune-etched and infused with hateful sorceries.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_runed_bone_giant.png", display_h=2, display_y=-1}}},
	level_range = {40, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	ai = "tactical",
	max_life = resolvers.rngavg(100,120),
	combat_armor = 20, combat_def = 40,
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 15)},
	autolevel = "warriormage",
	resists = {all = 30},
	resolvers.talents{
		[Talents.T_BONE_ARMOUR]={base=5, every=10, max=7},
		[Talents.T_STUN]={base=3, every=10, max=5},
		[Talents.T_SKELETON_REASSEMBLE]=5,
		[Talents.T_ARCANE_POWER]={base=4, every=5, max = 8},
		[Talents.T_MANATHRUST]={base=4, every=5, max = 10},
		[Talents.T_MANAFLOW]={base=5, every=5, max = 10},
		[Talents.T_STRIKE]={base=4, every=5, max = 12},
		[Talents.T_INNER_POWER]={base=4, every=5, max = 10},
		[Talents.T_EARTHEN_MISSILES]={base=5, every=5, max = 10},
	},
	resolvers.sustains_at_birth(),
}

--Heavy Sentinel, flaming bone giant.
newEntity{ base = "BASE_NPC_BONE_GIANT", define_as = "HEAVY_SENTINEL",
	name = "Heavy Sentinel", color=colors.ORANGE, unique=true,
	desc = [[A towering creature, made from the bones of countless bodies. An aura of flame bellows from within its chest.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_heavy_sentinel.png", display_h=2, display_y=-1}}},
	level_range = {45, nil}, exp_worth = 2,
	rarity = 50,
	rank = 3.5,
	ai = "tactical",
	size=5,
	max_life = resolvers.rngavg(110,125),
	combat_armor = 20, combat_def = 35,
	life_rating = 28,
	
	combat_atk=30,
	combat_spellpower=15,
	
	stats = { str=28, dex=60, mag=20, con=20 },
	
	combat = { dam=resolvers.levelup(60, 1, 2), atk=resolvers.levelup(70, 1, 1), apr=20, dammod={str=1.2}, damtype=engine.DamageType.FIRE, convert_damage={[engine.DamageType.PHYSICAL]=50}},
	
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(15, 25)},
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(15, 5)},
	autolevel = "warriormage",
	resists = {all = 10, [DamageType.FIRE]=100, [DamageType.COLD]=-75},
	resolvers.talents{
		[Talents.T_BONE_ARMOUR]={base=5, every=10, max=7},
		[Talents.T_STUN]={base=3, every=10, max=5},
		[Talents.T_SKELETON_REASSEMBLE]=5,
		[Talents.T_ARCANE_POWER]={base=3, every=3, max = 6},
		[Talents.T_FLAME]={base=3, every=4, max = 8},
		[Talents.T_FLAMESHOCK]={base=2, every=6, max = 7},
		[Talents.T_MANAFLOW]={base=5, every=5, max = 10},
		[Talents.T_INFERNO]={base=2, every=5, max = 6},
		[Talents.T_BURNING_WAKE]={base=1, every=4, max = 5},
		[Talents.T_WILDFIRE]={base=3, every=7, max=5},
		--[Talents.T_GOLEM_MOLTEN_SKIN]={base=3, every=6, max=6},
		[Talents.T_CLEANSING_FLAMES]={base=2, every=6, max = 5},
		[Talents.T_ARCANE_COMBAT]=3,
		[Talents.T_SPELLCRAFT]={base=3, every=7, max=7},
		[Talents.T_FIERY_HANDS]={base=3, every=7, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ARMOR_MOLTEN"} },
}
