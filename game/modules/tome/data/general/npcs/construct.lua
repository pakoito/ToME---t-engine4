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
	define_as = "BASE_NPC_CONSTRUCT",
	type = "construct", subtype = "golem",
	display = "g", color=colors.UMBER,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=30, nb=1, {type="gem"} },
	infravision = 10,

	life_rating = 20,
	rank = 2,
	size_category = 4,

	open_door = true,
	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 1,
	disease_immune = 1,
	stone_immune = 1,
	see_invisible = 30,
	no_breath = 1,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	stats = { str=20, mag=16, con=22 },
	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1, [Talents.T_MANA_POOL]=1,
		[Talents.T_ARMOUR_TRAINING]={base=4, every=5, max=10},
	},
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_CONSTRUCT",
	name = "broken golem", color=colors.LIGHT_UMBER,
	desc = [[This golem is badly damaged.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.inscriptions(1, "rune"),
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_GOLEM_KNOCKBACK]={base=1, every=6, max=5},
	},
}

newEntity{ base = "BASE_NPC_CONSTRUCT",
	name = "golem", color=colors.BLUE,
	desc = [[This golem's eyes glow with magical energies.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	resolvers.equip{
		{type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.inscriptions(2, "rune"),
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_GOLEM_KNOCKBACK]={base=2, every=6, max=5},
		[Talents.T_GOLEM_BEAM]={base=1, every=6, max=5},
	},
}

newEntity{ base = "BASE_NPC_CONSTRUCT",
	name = "alchemist golem", color=colors.YELLOW,
	desc = [[This golem's eyes glow with magical energies.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(90,100),
	resolvers.equip{
		{type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.inscriptions(2, "rune"),
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_GOLEM_KNOCKBACK]={base=3, every=6, max=5},
		[Talents.T_GOLEM_CRUSH]={base=3, every=6, max=5},
		[Talents.T_GOLEM_BEAM]={base=3, every=6, max=5},
		[Talents.T_GOLEM_ARCANE_PULL]={base=3, every=6, max=5},
	},
}
