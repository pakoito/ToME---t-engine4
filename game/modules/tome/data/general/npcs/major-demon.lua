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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MAJOR_DEMON",
	type = "demon", subtype = "major",
	display = "U", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=22, dex=10, mag=20, con=13 },
	combat_armor = 1, combat_def = 1,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",

	resolvers.inscriptions(1, "rune"),
	ingredient_on_death = "GREATER_DEMON_BILE",
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "dolleg", color=colors.GREEN, -- Dark thorn
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_dolleg.png", display_h=2, display_y=-1}}},
	desc = "A monstrous demon, covered in acidic thorns.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	autolevel = "warrior",
	combat_armor = 26, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(56, 30), 1, 1), atk=35, apr=18, dammod={str=1}, damtype=DamageType.ACID },

	resists={[DamageType.ACID] = resolvers.mbonus(30, 20)},

	confusion_immune = 1,
	stun_immune = 1,

	resolvers.talents{
		[Talents.T_ACIDIC_SKIN]={base=5, every=5, max=10},
		[Talents.T_SLIME_SPIT]={base=4, every=5, max=8},
	},
}


newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "dúathedlen", color=colors.GREY, -- Darkness exiled
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_duathedlen.png", display_h=2, display_y=-1}}},
	desc = "Under a shroud of darkness you discern an evil shape.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	autolevel = "warrior",
	combat_armor = 0, combat_def = 26,
	combat = { dam=resolvers.levelup(resolvers.mbonus(46, 30), 1, 1), atk=35, apr=18, dammod={str=1}, damtype=DamageType.DARKNESS },

	resists={[DamageType.DARKNESS] = resolvers.mbonus(30, 20)},

	poison_immune = 1,
	disease_immune = 1,

	resolvers.talents{
		[Talents.T_DARKNESS]={base=3, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=10},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "uruivellas", color=colors.LIGHT_RED, -- Hot strength
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_uruivellas.png", display_h=2, display_y=-1}}},
	desc = [[This demon would look like a minotaur, if a minotaur had a fiery aura surrounding it and horns all over the body.
Oh, and it is twice as big, too.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	global_speed_base = 1.4,
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 20,
	combat_armor = 26, combat_def = 0,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.equip{ {type="weapon", subtype="battleaxe", forbid_power_source={antimagic=true}, autoreq=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(15, 10), [DamageType.FIRE] = resolvers.mbonus(15, 10)},

	stun_immune = 1,

	resolvers.talents{
		[Talents.T_DISARM]={base=3, every=7, max=6},
		[Talents.T_RUSH]={base=5, every=15, max=7},
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_WEAPON_COMBAT]={base=4, every=10},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=10},
		[Talents.T_FIRE_STORM]={base=5, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "thaurhereg", color=colors.RED, -- Terrible blood
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_thaurhereg.png", display_h=2, display_y=-1}}},
	desc = [[This terrible demon is covered in blood, which flows *on* its skin in ever-changing patterns that disturb you simply when looking at it.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	global_speed_base = 1.2,
	size_category = 3,
	autolevel = "caster",
	life_rating = 6,
	combat_armor = 0, combat_def = 10,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true}, },

	silence_immune = 1,
	blind_immune = 1,

	resolvers.talents{
		[Talents.T_MANATHRUST]={base=5, every=8, max=8},
		[Talents.T_ICE_STORM]={base=5, every=8, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=8, max=8},
		[Talents.T_SOUL_ROT]={base=5, every=8, max=8},
		[Talents.T_SHRIEK]={base=5, every=8, max=8},
		[Talents.T_SILENCE]={base=2, every=12, max=5},
		[Talents.T_BONE_SHIELD]={base=4, every=8, max=8},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "daelach", color=colors.PURPLE, -- Shadow flame
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_daelach.png", display_h=2, display_y=-1}}},
	desc = [[You can only guess at the real shape of this demon. Its body is surrounded by a cloud of fiery darkness.
It moves swiftly toward you, casting terrible spells and swinging its weapons at you.]],
	level_range = {39, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	global_speed_base = 1.3,
	size_category = 4,
	autolevel = "warriormage",
	life_rating = 25,
	combat_armor = 12, combat_def = 20,
	max_mana = 1000,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="waraxe", forbid_power_source={antimagic=true}, autoreq=true}, },

	resists={all = resolvers.mbonus(25, 20)},

	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,

	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=8, max=8},
		[Talents.T_DISARM]={base=5, every=8, max=8},
		[Talents.T_RUSH]={base=8, every=8, max=12},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=7},
		[Talents.T_FIRE_STORM]={base=5, every=8, max=8},
		[Talents.T_FIREBEAM]={base=5, every=8, max=8},
		[Talents.T_SHADOW_BLAST]={base=5, every=8, max=8},
		[Talents.T_TWILIGHT_SURGE]={base=5, every=8, max=8},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "champion of Urh'Rok", color=colors.GREY,
	desc = [[One of Urh'Rok's own champions. A thousand nightmares made flesh and screaming steel towering before you in the form of a massive, armored humanoid.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_champion_of_urh_rok.png", display_h=2, display_y=-1}}},
	level_range = {43, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	global_speed_base = 1.3,
	size_category = 4,
	autolevel = "warrior",
	life_rating = 25,
	combat_armor = 90, combat_def = 60,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100, stamina_regen = 100,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true}, },

	resists={all = resolvers.mbonus(25, 20)},

	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,

	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=8, max=8},
		[Talents.T_DISARM]=5,
		[Talents.T_RUSH]={base=8, every=8, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_GHOULISH_LEAP]={base=1, every=8, max=5},
		[Talents.T_DEATH_DANCE]={base=5, every=8, max=10},
		[Talents.T_STUNNING_BLOW]={base=5, every=8, max=8},
		[Talents.T_SUNDER_ARMOUR]={base=5, every=8, max=10},
		[Talents.T_SUNDER_ARMS]={base=5, every=8, max=10},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "forge-giant", color=colors.RED,
	desc = [[A burning giant wielding a forge hammer of the underworld in each hand-- weapons imbued by Urh'Rok himself with the power to crush and shape felsteel. Enter their range at your peril.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_forge_giant.png", display_h=2, display_y=-1}}},
	level_range = {47, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	global_speed_base = 1,
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 30,
	combat_armor = 32, combat_def = 40,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100, stamina_regen = 100,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(15, 10), [DamageType.FIRE] = 100},
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(25, 35)},

	stun_immune = 1,
	knockback_immune = 1,


	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=8, max=8},
		[Talents.T_DUAL_WEAPON_TRAINING]={base=1, every=8, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=5, every=8, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=7},
		[Talents.T_THROW_BOULDER]={base=5, every=8, max=14},
		[Talents.T_FIREBEAM]={base=5, every=8, max=8},
		[Talents.T_WILDFIRE]={base=5, every=8, max=8},
		[Talents.T_INFERNO]={base=5, every=8, max=8},
		[Talents.T_FLAME]={base=5, every=8, max=10},
		[Talents.T_FLAMESHOCK]={base=5, every=8, max=10},
		[Talents.T_FIREFLASH]={base=5, every=8, max=10},
		[Talents.T_BURNING_WAKE]={base=5, every=8, max=10},
		[Talents.T_CLEANSING_FLAMES]={base=5, every=8, max=10},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "Khulmanar, General of Urh'Rok",
	color=colors.DARK_RED, unique=true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_general_of_urh_rok.png", display_h=2, display_y=-1}}},
	desc = [[This massive form, sheathed in dark flames, stands tall above a legion of lesser demons. In his hands he holds a massive blacked battleaxe, flames dancing around the blades.]],
	level_range = {40, nil}, exp_worth = 1,
	rarity = 50,
	rank = 3.5,
	global_speed_base = 1,
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 35,
	combat_armor = 50, combat_def = 40, combat_atk=50,
	mana_regen = 100, stamina_regen = 100,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="battleaxe", defined="KHULMANAR_WRATH", random_art_replace={chance=30}, autoreq=true, force_drop=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(8, 8), [DamageType.FIRE] = 100},
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(25, 35)},

	knockback_immune = 1,

	summon = {
		{type="demon", number=2, hasxp=false},
	},
	make_escort = {
		{type="demon", no_subescort=true, number=resolvers.mbonus(4, 4)},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
			--Melee
		[Talents.T_WEAPON_COMBAT]={base=8, every=5, max=12},
		[Talents.T_WEAPONS_MASTERY]={base=8, every=8, max=12},
		[Talents.T_RUSH]={base=5, every=7, max=8},
		[Talents.T_BATTLE_CRY]={base=4, every=5, max=9},
		[Talents.T_BATTLE_CALL]={base=2, every=3, max=8},
		[Talents.T_STUNNING_BLOW]={base=5, every=8, max=7},
		[Talents.T_KNOCKBACK]={base=4, every=4, max=8},
			--Magic
		[Talents.T_FIRE_STORM]={base=4, every=6, max=8},
		[Talents.T_WILDFIRE]={base=3, every=8, max=6},
		[Talents.T_FLAME]={base=5, every=8, max=10},
			--Special
		[Talents.T_INFERNAL_BREATH]={base=3, every=5, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}
