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
	define_as = "BASE_NPC_UNDEAD_RAT",
	type = "undead", subtype = "rodent",
	display = "r", color=colors.WHITE,

	mana_regen=12,

	body = { INVEN = 10 },

	infravision = 10,
	life_rating = 8,
	rank = 2,
	size_category = 1,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	stats = { str=10, dex=8, mag=10, con=8 },

	poison_immune = 0.5,
	undead=1,
	not_power_source = {nature=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT",
	name = "skeletal rat", color=colors.WHITE,
	desc = [[A skeletal rat, teeth and claws ground to a sharp point. It glares at you menacingly.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(25,45),
	combat_armor = 12, combat_def = 0,

	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 1,

	combat = { dam=resolvers.levelup(resolvers.rngavg(20,30), 1, 0.6), atk=resolvers.rngavg(25,50), apr=20, dammod={str=1.1} },
	resolvers.tmasteries{ ["undead/skeleton"]=-0.5},

	resolvers.talents{
		[Talents.T_SKELETON_REASSEMBLE]={base=1, every=5, max=4},
	},

	emote_random = {chance=1, "*squeak*", "Squeak!", "Squeak??", "SQUEAK!!!!!"},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT",
	name = "ghoulish rat", color=colors.TAN,
	desc = [[Layers of rotting skin are peeling off of this rat. One of the eye sockets appears empty.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(34,56),
	combat_armor = 4, combat_def = 10,
	life_rating = 10,

	autolevel="ghoul",

	combat = { dam=resolvers.levelup(resolvers.rngavg(16,24), 1, 0.6), atk=resolvers.rngavg(25,50), apr=25, dammod={str=1} },

	poison_immune = 0.5,
	disease_immune = 0.5,

	resists = {[DamageType.BLIGHT] = 15},

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=1, every=7, max=4},
		[Talents.T_GHOULISH_LEAP]={base=2, every=8, max=4},
	},
	emote_random = {chance=1, "*s.q.u.e.a.k*", "Squeeeeeeak!", "Squeakkkkkkk??"},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT",
	name = "spectral rat", color=colors.GREY,
	desc = [[An eerie haze surrounds this translucent rat.]],
	level_range = {9, nil}, exp_worth = 1,
	rarity = 3,
	rank = 2,
	max_life = resolvers.rngavg(18,25),
	combat_armor = 0, combat_def = 15,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,50), apr=25, dammod={str=1} },

	can_pass = {pass_wall=70},
	resists = {all = 20, [DamageType.LIGHT] = -40, [DamageType.DARKNESS] = 45},

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

	resolvers.talents{
		[Talents.T_PHASE_DOOR]={base=1, every=6, max=4},
		[Talents.T_BLUR_SIGHT]={base=3, every=6, max=6},
	},

	resolvers.sustains_at_birth(),

	emote_random = {chance=1, "Eerie Squeak!", "Frightening Squeak??", "SQUEAK!!!!!"},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT",
	name = "vampire rat", color=colors.WHITE,
	desc = [[Looks much like a normal rat. That is, other than the very large fangs.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(45,60),
	life_rating=11,
	combat_armor = 8, combat_def = 18,

	fear_immune = 1,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,35), 1, 0.6), atk=resolvers.rngavg(25,50), apr=22, dammod={str=1.1} },

	resolvers.talents{
		[Talents.T_VAMPIRIC_GIFT]={base=1, every=5, max=4},
		[Talents.T_INVOKE_DARKNESS]={base=1, every=8, max=5},
		[Talents.T_COLD_FLAMES]={base=1, every=9, max=5},
	},

	emote_random = {chance=1, "Squeak! Blood!", "Squeak??", "SQUEAK!!!!!"},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT",
	name = "gigantic bone rat", color=colors.LIGHTGREY,
	desc = [[This massive beast appears to be a rat composed of countless bones fused together.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_rodent_gigantic_bone_rat.png", display_h=2, display_y=-1}}},
	level_range = {14, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(60,80),
	life_rating=14,
	combat_armor = 25, combat_def = 10,

	rank = 3,
	size_category = 3,

	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 1,

	stats = { str=20, dex=15, mag=10, con=8 },

	combat = { dam=resolvers.levelup(resolvers.rngavg(48,56), 1, 0.6), atk=resolvers.rngavg(32,60), apr=24, dammod={str=1.2} },
	resolvers.tmasteries{ ["undead/skeleton"]=-0.2},

	resolvers.talents{
		[Talents.T_SKELETON_REASSEMBLE]={base=2, every=7, max=4},
		[Talents.T_BONE_ARMOUR]={base=1, every=10, max=4},
		[Talents.T_STUN]={base=1, every=9, max=6},
		[Talents.T_KNOCKBACK]={base=1, every=7, max=4},
	},

	emote_random = {chance=1, "*SQUEAK*", "SQUEAK!!!!!"},
}

newEntity{ base = "BASE_NPC_UNDEAD_RAT", define_as="RATLICH",
	name = "Rat Lich", color=colors.BLACK,
	desc = [[The master of the pit is before you. It squeaks with menace as it and a horde of minions approach you.]],
	level_range = {16, nil}, exp_worth = 2,
	rarity = false,
	rank=3.5,
	max_life = resolvers.rngavg(50,80),
	life_rating=10,
	combat_armor = 20, combat_def = 15,

	self_resurrect = 1,

	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	instakill_immune = 1,
	poison_immune = 1,

	hate_regen=1,
 	mana_regen=3,
 	negative_regen=3,

	combat_spellpower = resolvers.mbonus(20, 10),
	combat_spellcrit = resolvers.mbonus(5, 5),

	combat_mindpower = resolvers.mbonus(20, 10),
	combat_mindcrit = resolvers.mbonus(5, 5),

	autolevel="caster",
	ai = "tactical", ai_state = { talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",

	combat = { dam=resolvers.rngavg(12,20), atk=20, apr=9, damtype=DamageType.DARKSTUN, dammod={mag=0.9} },

	summon = {
		{type="undead", subtype="rodent", number=2, hasxp=false},
	},
	make_escort = {
		{type="undead", subtype="rodent", number=4, hasxp=false},
	},

	on_resurrect = function(self, type)
			self.max_life = self.max_life * 1.8
			self.life = self.max_life
			self.combat_spellcrit = self.combat_spellcrit + 5
			self:learnTalent(self.T_ARCANE_POWER, true, 3)
			self:forceUseTalent(self.T_ARCANE_POWER, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})

			self:learnTalent(self.T_FROSTDUSK, true, 2)
			self:forceUseTalent(self.T_FROSTDUSK, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})

			self:forceUseTalent(self.T_CALL_SHADOWS, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})

			self.summon = {
				{type="undead", subtype="rodent", number=3, hasxp=false},
			}

			game.logSeen(self, "#RED#Rising again, the Rat Lich's eyes glow with renewed energy!")

			self.desc = self.desc.."\nThe Rat Lich's true power has been unveiled! Swirling with arcane energy, it stalks towards you uttering warsqueaks at its minions!"

			self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
			self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end,

	resolvers.talents{
		[Talents.T_SUMMON]=1,

		--Doomed
		[Talents.T_CALL_SHADOWS]={base=1, every=6, max=6},
		[Talents.T_SHADOW_WARRIORS]={base=1, every=6, max=6},
		[Talents.T_CREEPING_DARKNESS]={base=4, every=8, max=7},
		[Talents.T_DARK_TENDRILS]={base=1, every=6, max=6},
		[Talents.T_DARK_VISION]={base=4, every=8, max=6},
		--Magic
		[Talents.T_INVOKE_DARKNESS]={base=3, every=6, max=7},
		[Talents.T_MANATHRUST]={base=3, every=8, max=6},
		[Talents.T_FEAR_THE_NIGHT]={base=2, every=7, max=5},
		--Anorithil
		[Talents.T_MOONLIGHT_RAY]={base=2, every=6, max=7},
		[Talents.T_SHADOW_BLAST]={base=1, every=7, max=5},
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="RATLICH_SKULL"} },

	emote_random = {chance=1, "*squeak*", "Squeak!", "Squeak??", "SQUEAK!!!!!", '"Squeak" I say, yes .. "Squeak!"'},

	on_die = function(self) world:gainAchievement("EVENT_RATLICH", game:getPlayer(true)) end,
}
