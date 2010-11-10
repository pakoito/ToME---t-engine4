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
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },

	stats = { str=22, dex=20, wil=15, con=15 },
	energy = { mod=1 },
	combat_armor = 0, combat_def = 0,
	combat = { dam=5, atk=15, apr=7, dammod={str=0.6} },
	infravision = 20,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "worm that walks", color=colors.SANDY_BROWN, define_as="TEST",
	desc = [[A maggot filled robe with a vaguely humanoid shape.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,

	resists = { [DamageType.PHYSICAL] = 50, [DamageType.FIRE] = -50},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="sword", autoreq=true},
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="robe", autoreq=true}
	},

	resolvers.talents{
		[Talents.T_BONE_GRAB]=4,
		[Talents.T_DRAIN]=5,
		[Talents.T_CORRUPTED_STRENGTH]=3,
		[Talents.T_VIRULENT_DISEASE]=3,
		[Talents.T_CURSE_OF_DEATH]=5,
		[Talents.T_REND]=4,
		[Talents.T_BLOODLUST]=3,
		[Talents.T_RUIN]=2,

		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]=3,
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="vermin", subtype="worms", name="carrion worm mass", number=2, hasxp=false},
	},
	make_escort = {
		{type="vermin", subtype="worms", name="carrion worm mass", number=2},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "bloated horror", color=colors.WHITE,
	desc ="A bulbous humanoid form floats here. It's bald, child-like head is disproportionately large compared to it's body and its skin is pock-marked in nasty red sores.",
	level_range = {27, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 4,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {dam=resolvers.mbonus(25, 15), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,

	resists = {all = 35, [DamageType.LIGHT] = -30},

	resolvers.talents{
		[Talents.T_FEATHER_WIND]=5,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_MIND_DISRUPTION]=4,
		[Talents.T_MIND_SEAR]=4,
		[Talents.T_TELEKINETIC_BLAST]=4,
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "nightmare horror", color=colors.DARK_GREY,
	desc ="A shifting form of darkest night that seems to reflect your deepest fears.",
	level_range = {30, nil}, exp_worth = 1,
	negative_regen = 10,
	rarity = 7,
	rank = 3,
	life_rating = 7,
	autolevel = "warriormage",
	stats = { str=15, dex=20, mag=20, wil=20, con=15 },
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=20, apr=50, dammod={str=0.6}, damtype=DamageType.DARKNESS},

	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=40, talent_in=2, },

	can_pass = {pass_wall=70},
	resists = {all = 35, [DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},

	blind_immune = 1,
	see_invisible = 80,
	no_breath = 1,

	resolvers.talents{
		[Talents.T_STALK]=5,
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_TORMENT]=3,
		[Talents.T_DOMINATE]=3,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_LIFE_LEECH]=5,
		[Talents.T_SHADOW_BLAST]=4,
		[Talents.T_HYMN_OF_SHADOWS]=3,
	},

	resolvers.sustains_at_birth(),
}

------------------------------------------------------------------------
-- Uniques
------------------------------------------------------------------------

newEntity{ base="BASE_NPC_HORROR",
	name = "Grgglck the Devouring Darkness", unique = true,
	color = colors.DARK_GREY,
	rarity = 50,
	desc = [[An horror from the deepest pits of the earth. It looks like a huge pile of tentacles all trying to reach for you.
You can discern a huge ruond mouth covered in razor-sharp teeth.]],
	level_range = {20, nil}, exp_worth = 2,
	max_life = 300, life_rating = 25, fixed_rating = true,
	equilibrium_regen = -20,
	negative_regen = 20,
	rank = 3.5,
	no_breath = 1,
	size_category = 4,
	movement_speed = 0.5,

	stun_immune = 1,
	knockback_immune = 1,

	combat = { dam=resolvers.mbonus(100, 15), atk=500, apr=0, dammod={str=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		  resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resists = { all=500 },

	resolvers.talents{
		[Talents.T_STARFALL]=4,
		[Talents.T_MOONLIGHT_RAY]=4,
		[Talents.T_PACIFICATION_HEX]=4,
		[Talents.T_BURNING_HEX]=4,
		[Talents.T_INVOKE_TENTACLE]=1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
}

newEntity{ base="BASE_NPC_HORROR", define_as = "GRGGLCK_TENTACLE",
	name = "Grgglck's Tentacle",
	color = colors.GREY,
	desc = [[This is one of Grgglck's tentacle, it looks more vulnerable than the main body.]],
	level_range = {20, nil}, exp_worth = 0,
	max_life = 100, life_rating = 3, fixed_rating = true,
	equilibrium_regen = -20,
	rank = 3,
	no_breath = 1,
	size_category = 2,

	stun_immune = 1,
	knockback_immune = 1,
	teleport_immune = 1,

	resists = { all=50, [DamageType.DARKNESS] = 100 },

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	on_act = function(self)
		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#With Grgglck's death its tentacle also falls lifeless on the ground!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead then
			game.logSeen(self, "#AQUAMARINE#As %s falls you notice that %s seems to shudder in pain!", self.name, self.summoner.name)
			self.summoner:takeHit(self.max_life, who)
		end
	end,
}
