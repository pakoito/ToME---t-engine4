-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	define_as = "BASE_NPC_TROLL",
	type = "giant", subtype = "troll",
	display = "T", color=colors.UMBER,

	combat = { dam=resolvers.levelup(resolvers.mbonus(45, 10), 1, 1), atk=2, apr=6, physspeed=2, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 15,
	life_regen = 2,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },

	open_door = true,

	resolvers.tmasteries{ ["technique/other"]=0.3 },

	resists = { [DamageType.FIRE] = -50 },
	fear_immune = 1,
	on_die = function(self, who)
		local part = "TROLL_INTESTINE"
		if game.player:hasQuest("brotherhood-of-alchemists") then
			game.player:hasQuest("brotherhood-of-alchemists"):need_part(who, part, self)
		end
	end,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "forest troll", color=colors.YELLOW_GREEN, image="npc/troll_f.png",
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 4, combat_def = 0,
}


newEntity{ base = "BASE_NPC_TROLL",
	name = "stone troll", color=colors.DARK_SLATE_GRAY, image="npc/troll_s.png",
	desc = [[A giant troll with scabrous black skin. With a shudder, you notice the belt of dwarf skulls around his massive waist.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 7, combat_def = 0,
	resolvers.talents{ [Talents.T_STUN]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=1, every=7, max=5}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "cave troll", color=colors.SLATE, image="npc/troll_c.png",
	desc = [[This huge troll wields a massive spear and has a disturbingly intelligent look in its piggy eyes.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 9, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=1, every=7, max=5}, [Talents.T_KNOCKBACK]={base=2, every=7, max=5}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll", color=colors.UMBER, image="npc/troll_m.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 12, combat_def = 4,
	resolvers.talents{ [Talents.T_STUN]={base=3, every=7, max=8}, [Talents.T_KNOCKBACK]={base=3, every=7, max=8}, [Talents.T_RUSH]={base=3, every=7, max=8}, [Talents.T_DISARM]={base=3, every=7, max=8}, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll thunderer", color=colors.AQUAMARINE, image="npc/troll_mt.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(120,140),
	mana_regen = 20,
	combat_armor = 8, combat_def = 4,
	autolevel = "warriormage",
	ai = "tactical",
	resolvers.inscriptions(1, "rune"),
	resolvers.talents{
		[Talents.T_STUN]={base=4, every=6, max=8},
		[Talents.T_KNOCKBACK]={base=3, every=7, max=8},
		[Talents.T_LIGHTNING]={base=4, every=7, max=8},
		[Talents.T_THUNDERSTORM]={base=3, every=7, max=8},
	},
}
