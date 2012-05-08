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
	define_as = "BASE_NPC_MULTIHUED_DRAKE",
	type = "dragon", subtype = "multihued",
	display = "D", color=colors.PURPLE,
	shader = "quad_hue", resolvers.nice_tile{shader = false},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 18,
	rank = 2,
	size_category = 5,

	autolevel = "drake",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=20, dex=20, mag=30, con=16 },

	knockback_immune = 1,
	stun_immune = 0.8,
	blind_immune = 0.8,
	poison_immune = 0.5,
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	name = "multi-hued drake hatchling", color=colors.PURPLE, display="d",
	desc = [[A drake hatchling. Not too powerful by itself, but it usually comes with its brothers and sisters.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	rank = 1, size_category = 2,
	max_life = resolvers.rngavg(60,80),
	combat_armor = 5, combat_def = 0,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(7, 3), [DamageType.COLD]=resolvers.mbonus(7, 3)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,70), 1, 0.6), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.FIRE] = 20, [DamageType.COLD] = 20, [DamageType.ACID] = 20, [DamageType.LIGHTNING] = 20, },

	make_escort = {
		{type="dragon", subtype="multihued", name="multi-hued drake hatchling", number=3, no_subescort=true},
	},
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=1, every=10},
	}
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	name = "multi-hued drake", color=colors.PURPLE, display="D",
	desc = [[A mature multi-hued drake, armed with many deadly breath weapons and nasty claws.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(150,170),
	combat_armor = 12, combat_def = 0,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(10, 5), [DamageType.COLD]=resolvers.mbonus(10, 5)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 1.2), atk=resolvers.rngavg(25,100), apr=25, dammod={str=1.1} },
	stats_per_level = 4,
	lite = 1,

	resists = { [DamageType.PHYSICAL] = 30, [DamageType.FIRE] = 30, [DamageType.COLD] = 30, [DamageType.ACID] = 30, [DamageType.LIGHTNING] = 30, },

	make_escort = {
		{type="dragon", name="multi-hued drake hatchling", number=1},
	},

	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=3, every=6, max=6},
		[Talents.T_WING_BUFFET]={base=2, every=7, max=5},

		[Talents.T_FIRE_BREATH]={base=4, every=4, max=11},
		[Talents.T_ICE_BREATH]={base=4, every=4, max=11},
		[Talents.T_SAND_BREATH]={base=4, every=4, max=11},
		[Talents.T_POISON_BREATH]={base=4, every=4, max=11},
		[Talents.T_LIGHTNING_BREATH]={base=4, every=4, max=11},
		[Talents.T_ACID_BREATH]={base=4, every=4, max=11},
	},
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE", define_as = "GREATER_MULTI_HUED_WYRM",
	name = "greater multi-hued wyrm", color=colors.PURPLE, display="D",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_multihued_greater_multi_hued_wyrm.png", display_h=2, display_y=-1}}},
	desc = [[An old and powerful multi-hued drake, armed with many deadly breath weapons and nasty claws.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	max_life = resolvers.rngavg(220,250),
	combat_armor = 30, combat_def = 30,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(10, 5), [DamageType.COLD]=resolvers.mbonus(10, 5), [DamageType.LIGHTNING]=resolvers.mbonus(10, 5), [DamageType.ACID]=resolvers.mbonus(10, 5)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,150), 1, 2.2), atk=resolvers.rngavg(25,130), apr=25, dammod={str=1.1} },
	stats_per_level = 5,
	lite = 1,
	stun_immune = 1,
	blind_immune = 1,

	resists = { [DamageType.PHYSICAL] = 40, [DamageType.FIRE] = 40, [DamageType.COLD] = 40, [DamageType.ACID] = 40, [DamageType.LIGHTNING] = 40, },

	ai = "tactical",

	make_escort = {
		{type="dragon", name="multi-hued drake", number=1},
		{type="dragon", name="multi-hued drake", number=1, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_SILENCE]={base=3, every=6},
		[Talents.T_DISARM]={base=3, every=6},
		[Talents.T_ICE_CLAW]={base=3, every=6},
		[Talents.T_WING_BUFFET]={base=2, every=7},

		[Talents.T_FIRE_BREATH]={base=9, every=4},
		[Talents.T_ICE_BREATH]={base=9, every=4},
		[Talents.T_SAND_BREATH]={base=9, every=4},
		[Talents.T_POISON_BREATH]={base=9, every=4},
		[Talents.T_LIGHTNING_BREATH]={base=9, every=4},
		[Talents.T_ACID_BREATH]={base=9, every=4},
	},
	ingredient_on_death = "MULTIHUED_WYRM_SCALE",
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	unique = true,
	name = "Ureslak the Prismatic", color=colors.VIOLET, display="D",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/drake_multi_ureslak.png", display_h=2, display_y=-1}}},
	desc = [[A huge multi-hued drake. It seems to shift color rapidly.]],
	level_range = {35, nil}, exp_worth = 4,
	rarity = 50,
	rank = 3.5,
	max_life = resolvers.rngavg(320,350), life_rating = 22,
	combat_armor = 33, combat_def = 40,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(10, 5), [DamageType.COLD]=resolvers.mbonus(10, 5), [DamageType.LIGHTNING]=resolvers.mbonus(10, 5), [DamageType.ACID]=resolvers.mbonus(10, 5)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,150), 1, 2.2), atk=resolvers.rngavg(25,130), apr=32, dammod={str=1.1} },
	lite = 1,
	stun_immune = 1,
	blind_immune = 1,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	ai_status = {ally_compassion = 0},

	make_escort = {
		{type="dragon", name="greater multi-hued wyrm", number=2, no_subescort=true},
	},

	no_auto_resists = true,
	color_switch = 2,
	resists = { all=50, [DamageType.FIRE] = 100, [DamageType.COLD] = -100 },
	resolvers.talents{ [Talents.T_FIRE_BREATH]=15, [Talents.T_FLAME]=7 },

	stats = { str=20, dex=20, mag=80, con=16 },

	talent_cd_reduction={[Talents.T_MANATHRUST]=4},

	colors = {
		{"red", {
			resists = { all=50, [DamageType.FIRE] = 100, [DamageType.COLD] = -100 },
			talents = { [Talents.T_EQUILIBRIUM_POOL]=1, [Talents.T_MANA_POOL]=1, [Talents.T_FIRE_BREATH]=15, [Talents.T_FLAME]=7 },
		}},
		{"white", {
			resists = { all=50, [DamageType.COLD] = 100, [DamageType.FIRE] = -100 },
			talents = { [Talents.T_EQUILIBRIUM_POOL]=1, [Talents.T_MANA_POOL]=1, [Talents.T_ICE_BREATH]=15, [Talents.T_ICE_SHARDS]=7 },
		}},
		{"blue", {
			resists = { all=50, [DamageType.LIGHTNING] = 100, [DamageType.PHYSICAL] = -100 },
			talents = { [Talents.T_EQUILIBRIUM_POOL]=1, [Talents.T_MANA_POOL]=1, [Talents.T_LIGHTNING_BREATH]=15, [Talents.T_SHOCK]=7 },
		}},
		{"green", {
			resists = { all=50, [DamageType.NATURE] = 100, [DamageType.BLIGHT] = -100 },
			talents = { [Talents.T_EQUILIBRIUM_POOL]=1, [Talents.T_MANA_POOL]=1, [Talents.T_POISON_BREATH]=15, [Talents.T_SPIT_POISON]=7 },
		}},
		{"dark", {
			resists = { all=50, [DamageType.DARKNESS] = 100, [DamageType.LIGHT] = -100 },
			talents = { [Talents.T_NEGATIVE_POOL]=1, [Talents.T_STARFALL]=7, [Talents.T_MOONLIGHT_RAY]=7 },
		}},
		{"violet", {
			resists = { all=-50 },
			talents = { [Talents.T_MANA_POOL]=1, [Talents.T_MANATHRUST]=12 },
		}},
	},

	on_act = function(self)
		self.color_switch = self.color_switch - 1
		if self.color_switch <= 0 then
			self.color_switch = 2
			-- Reset cooldowns
			self.talents_cd = {}
			self:incEquilibrium(-100)
			self:incMana(100)
			self:incNegative(100)

			-- Assign talents & resists
			local t = rng.table(self.colors)
			self.resists = t[2].resists
			self.talents = t[2].talents
			self.changed = true
			game.logSeen(self, "#YELLOW#%s's skin turns %s!", self.name:capitalize(), t[1])
		end
	end,
}
