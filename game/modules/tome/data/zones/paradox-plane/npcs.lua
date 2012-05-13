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

load("/data/general/npcs/telugoroth.lua", rarity(0))
load("/data/general/npcs/horror.lua", function(e) if e.rarity then e.horror_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "EPOCH",
	allow_infinite_dungeon = true,
	type = "elemental", subtype = "temporal", unique = true,
	name = "Epoch",
	display = "E", color=colors.VIOLET,
	desc = [[A huge being composed of sparking blue and yellow energy stands before you.  It shifts and flows as it moves; at once erratic and graceful.]],
	level_range = {12, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=10, dex=25, cun=20, mag=20, wil=20, con=20 },
	rank = 4,

	can_multiply = 2,

	no_breath = 1,
	poison_immune = 1,
	disease_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
	cut_immune = 1,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=20, apr=20, dammod={mag=1.2}, damtype=DamageType.TEMPORAL },

	resists = { [DamageType.TEMPORAL] = 100, [DamageType.PHYSICAL] = -50, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="EPOCH_CURVE"}},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	combat_armor = 0, combat_def = 10,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_MULTIPLY]=1,
		[Talents.T_TURN_BACK_THE_CLOCK]=3, -- TBTC gets an extra bolt at tl 4, very dangerous
		[Talents.T_CONGEAL_TIME]={base=3, every=7},
		[Talents.T_STATIC_HISTORY]=5,
		[Talents.T_BANISH]={base=3, every=7},
		[Talents.T_HASTE]={base=1, every=7},
		[Talents.T_SWAP]={base=1, every=7},
	},

	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(1, "rune"),

	talent_cd_reduction = {[Talents.T_MULTIPLY]=-40}, -- Negative 40 is right, so the player doesn't get swarmed with bosses

	on_multiply = function(self, src)
		self.on_die = nil
		self.talents.T_SWAP = nil
		self.talents.T_MULTIPLY = nil
	end,
	on_die = function(self, who)
		game.level.data.portal_next(self)
	end,
}
