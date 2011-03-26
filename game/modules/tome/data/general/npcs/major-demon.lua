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
	blood_color = colors.GREEN,
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

	resolvers.inscriptions(1, "rune"),
	on_die = function(self, who)
		local part = "GREATER_DEMON_BILE"
		if game.player:hasQuest("brotherhood-of-alchemists") then 
			game.player:hasQuest("brotherhood-of-alchemists"):need_part(who, part, self)
		end
	end,
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "dolleg", color=colors.GREEN, -- Dark thorn
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
	desc = [[This demon would look like a minotaur, if a minotaur had a fiery aura surrounding it and horns all over the body.
Oh, and it is twice as big, too.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	energy = {mod=1.4},
	size_category = 5,
	autolevel = "warriormage",
	life_rating = 20,
	combat_armor = 26, combat_def = 0,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.equip{ {type="weapon", subtype="battleaxe", autoreq=true}, },

	resists={[DamageType.PHYSICAL] = resolvers.mbonus(15, 10), [DamageType.FIRE] = resolvers.mbonus(15, 10)},

	stun_immune = 1,

	resolvers.talents{
		[Talents.T_DISARM]={base=3, every=7, max=6},
		[Talents.T_RUSH]={base=5, every=15, max=7},
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_WEAPON_COMBAT]={base=8, every=8},
		[Talents.T_WEAPONS_MASTERY]={base=10, every=7},
		[Talents.T_FIRE_STORM]={base=5, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "thaurhereg", color=colors.RED, -- Terrible blood
	desc = [[This terrible demon is covered in blood, which flows *on* its skin in ever changing patterns that disturb you simply when looking at it.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	energy = {mod=1.2},
	size_category = 3,
	autolevel = "caster",
	life_rating = 6,
	combat_armor = 0, combat_def = 10,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true}, },

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
	desc = [[You can only guess at the real shape of this demon. Its body is surrounded by a cloud of fiery darkness.
It moves swiftly toward you, casting terrible spells and swinging its weapons at you.]],
	level_range = {39, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	energy = {mod=1.3},
	size_category = 4,
	autolevel = "warriormage",
	life_rating = 25,
	combat_armor = 12, combat_def = 20,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100,

	ai = "tactical",

	resolvers.equip{ {type="weapon", subtype="longsword", autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="waraxe", autoreq=true}, },

	resists={all = resolvers.mbonus(25, 20)},

	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,

	resolvers.talents{
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=8, max=8},
		[Talents.T_DISARM]={base=5, every=8, max=8},
		[Talents.T_RUSH]={base=8, every=8, max=12},
		[Talents.T_WEAPON_COMBAT]={base=8, every=5, max=12},
		[Talents.T_WEAPONS_MASTERY]={base=7, every=8, max=14},
		[Talents.T_FIRE_STORM]={base=5, every=8, max=8},
		[Talents.T_FIREBEAM]={base=5, every=8, max=8},
		[Talents.T_SHADOW_BLAST]={base=5, every=8, max=8},
		[Talents.T_TWILIGHT_SURGE]={base=5, every=8, max=8},
	},
}
