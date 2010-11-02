-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=22, dex=10, mag=20, con=13 },
	energy = { mod=1 },
	combat_armor = 1, combat_def = 1,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 20,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "dolleg", color=colors.GREEN, -- Dark thorn
	desc = "A monstrous demon, covered in acidic thorns.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	autolevel = "warrior",
	combat_armor = 26, combat_def = 0,
	combat = { dam=resolvers.mbonus(56, 30), atk=35, apr=18, dammod={str=1}, damtype=DamageType.ACID },

	resists={[DamageType.ACID] = resolvers.mbonus(30, 20)},

	confusion_immune = 1,
	stun_immune = 1,

	resolvers.talents{
		[Talents.T_ACIDIC_SKIN]=5,
		[Talents.T_SLIME_SPIT]=4,
	},
}


newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "dúathedlen", color=colors.GREY, -- Darkness exiled
	desc = "Under a shroud of darkness you discern an evil shape.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	autolevel = "warrior",
	combat_armor = 0, combat_def = 26,
	combat = { dam=resolvers.mbonus(46, 30), atk=35, apr=18, dammod={str=1}, damtype=DamageType.DARKNESS },

	resists={[DamageType.DARKNESS] = resolvers.mbonus(30, 20)},

	poison_immune = 1,
	disease_immune = 1,

	resolvers.talents{
		[Talents.T_DARKNESS]=3,
		[Talents.T_BLOOD_GRASP]=5,
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "uruivellas", color=colors.LIGHT_RED, -- Hot strength
	desc = [[This demon would look like a minautor, if minautors had a fiery aura surrounding them and horns all over the body.
Oh and it is twice as big too.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	energy = {mod=1.4},
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 20,
	combat_armor = 26, combat_def = 0,

	resolvers.equip{ {type="weapon", subtype="battleaxe", autoreq=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(15, 10), [DamageType.FIRE] = resolvers.mbonus(15, 10)},

	stun_immune = 1,

	resolvers.talents{
		[Talents.T_DISARM]=3,
		[Talents.T_RUSH]=5,
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_WEAPON_COMBAT]=8,
		[Talents.T_WEAPONS_MASTERY]=10,
		[Talents.T_FIRE_STORM]=5,
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "thaurhereg", color=colors.RED, -- Terrible blood
	desc = [[This terrible demon is covered in blood, it flows *on* its skin in ever changing patterns that disturb you simply by looking at it.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	energy = {mod=1.2},
	size_category = 3,
	autolevel = "caster",
	life_rating = 6,
	combat_armor = 0, combat_def = 10,

	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true}, },

	silence_immune = 1,
	blind_immune = 1,

	resolvers.talents{
		[Talents.T_MANATHRUST]=5,
		[Talents.T_ICE_STORM]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_SHRIEK]=5,
		[Talents.T_SILENCE]=2,
		[Talents.T_BONE_SHIELD]=4,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "daelach", color=colors.PURPLE, -- Shadow flame
	desc = [[You can only discern the real shape of this demon, its body is surrounded by a cloud of fiery darkness.
It moves switftly toward you, casting terrible spells and swinging its weapons at you.]],
	level_range = {39, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	energy = {mod=1.3},
	size_category = 4,
	autolevel = "warriormage",
	life_rating = 25,
	combat_armor = 12, combat_def = 20,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100,

	resolvers.equip{ {type="weapon", subtype="longsword", autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="waraxe", autoreq=true}, },

	resists={all = resolvers.mbonus(25, 20)},

	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,

	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]=5,
		[Talents.T_DISARM]=5,
		[Talents.T_RUSH]=8,
		[Talents.T_WEAPON_COMBAT]=8,
		[Talents.T_WEAPONS_MASTERY]=7,
		[Talents.T_FIRE_STORM]=5,
		[Talents.T_FIREBEAM]=5,
		[Talents.T_SHADOW_BLAST]=5,
		[Talents.T_TWILIGHT_SURGE]=5,
	},
}
