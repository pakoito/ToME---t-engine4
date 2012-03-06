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

load("/data/general/npcs/sandworm.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "BRIAGH",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "sand", unique = true,
	name = "Briagh, Great Sand Wyrm",
	display = "D", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_sand_briagh__great_sand_wyrm.png", display_h=2, display_y=-1}}},
	desc = [[A towering sand-drake stands before you. This wingless worm is mighty and could easily crush you.]],
	level_range = {35, nil}, exp_worth = 2,
	max_life = 350, life_rating = 29, fixed_rating = true,
	max_mana = 900, mana_regen=100,
	equilibrium_regen = -50,
	infravision = 10,
	stats = { str=25, dex=10, cun=8, mag=80, wil=20, con=20 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	rank = 4,
	size_category = 5,

	combat = { dam=140, atk=130, apr=25, dammod={str=1.1} },

	resists = { [DamageType.DARKNESS] = 70 },

	can_pass = {pass_wall=20},
	move_project = {[DamageType.DIG]=1},

	body = { INVEN = 10, BODY=1 },

	resolvers.drops{chance=100, nb=1, {defined="RESONATING_DIAMOND"}, },
	resolvers.drops{chance=100, nb=5, {type="gem"} },

	resolvers.talents{
		[Talents.T_PROBABILITY_TRAVEL]=10,
		[Talents.T_SUMMON]=1,
		[Talents.T_SAND_BREATH]={base=8, every=8, max=12},
		[Talents.T_STUN]={base=5, every=5, max=8},
		[Talents.T_KNOCKBACK]={base=5, every=5, max=8},
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="vermin", subtype="sandworm", number=8, hasxp=false},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_target="target_player_radius", sense_radius=400, talent_in=1, },
	resolvers.inscriptions(3, {"wild infusion", "healing infusion", "regeneration infusion", "heroism infusion"}),
}
