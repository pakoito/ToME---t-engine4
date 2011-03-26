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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_NAGA",
	type = "humanoid", subtype = "naga",
	display = "n", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	can_breath={water=1},

	life_rating = 11,
	rank = 2,
	size_category = 3,

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(1, "infusion"),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	energy = { mod=1.2 },
	stats = { str=15, dex=15, mag=15, con=10 },
	on_die = function(self, who)
		local part = "NAGA_TONGUE"
		if game.player:hasQuest("brotherhood-of-alchemists") then 
			game.player:hasQuest("brotherhood-of-alchemists"):need_part(who, part, self)
		end
	end,
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga myrmidon", color=colors.DARK_UMBER, image="npc/naga_myrmidon.png",
	desc = [[A naga warrior, wielding a menacing trident.
Myrmidons are the most devoted warriors of the nagas.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,150), life_rating = 16,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	combat_armor = 20, combat_def = 10,
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=5, every=10, max=9},
		[Talents.T_SUNDER_ARMOUR]={base=4, every=10, max=8},
		[Talents.T_STUNNING_BLOW]={base=3, every=10, max=7},
		[Talents.T_RUSH]=8,
		[Talents.T_WEAPON_COMBAT]={base=6, every=6, max=13},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=6, every=6, max=13},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga tide huntress", color=colors.RED, image="npc/naga_tide_huntress.png",
	desc = [[A naga hunter, wielding a long bow.
Tide huntresses wield both magic and hunting skills, making them terrible foes.]],
	level_range = {34, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(110,130), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
	combat_armor = 10, combat_def = 10,
	autolevel = "warriormage",
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=5, every=10, max=10},
		[Talents.T_WATER_JET]={base=6, every=10, max=11},
		[Talents.T_WATER_BOLT]={base=7, every=10, max=12},
		[Talents.T_SHOOT]=1,
		[Talents.T_WEAPON_COMBAT]={base=6, every=6, max=13},
		[Talents.T_BOW_MASTERY]={base=6, every=6, max=13},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga psyren", color=colors.YELLOW, image="npc/naga_psyren.png",
	desc = [[A naga psyren; she looks at you with great intensity.
Psyrens are dangerous nagas that can directly assault your mind.]],
	level_range = {36, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(100,110), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	combat_armor = 5, combat_def = 10,
	autolevel = "wildcaster",
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]={base=4, every=10, max=7},
		[Talents.T_MIND_SEAR]={base=5, every=10, max=8},
		[Talents.T_SILENCE]={base=4, every=10, max=7},
		[Talents.T_TELEKINETIC_BLAST]={base=4, every=10, max=7},
	},
}
