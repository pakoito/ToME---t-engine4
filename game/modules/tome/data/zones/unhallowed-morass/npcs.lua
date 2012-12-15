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
	define_as = "BASE_NPC_SPIDER",
	type = "spiderkin", subtype = "spider",
	display = "S", color=colors.WHITE,
	desc = [[Arachnophobia...]],
	body = { INVEN = 10 },

	max_stamina = 150,
	rank = 1,
	size_category = 2,
	infravision = 10,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	global_speed_base = 1.2,
	stats = { str=10, dex=17, mag=3, con=7 },
	combat = { dammod={dex=0.8} },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb spinner", color=colors.UMBER,
	desc = [[A large brownish arachnid, it's fangs drip with a strange fluid.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=15, apr=3, damtype=DamageType.CLOCK, },
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb weaver", color=colors.DARK_UMBER,
	desc = [[A large brownish arachnid spinning it's web.  It doesn't look pleased that you've disturbed it's work.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,60),
	combat_armor =2, combat_def = 4,
	combat = { dam=resolvers.levelup(6, 1, 0.8), atk=15, apr=3, damtype=DamageType.TEMPORAL, },
	resolvers.talents{
		[Talents.T_LAY_WEB]=1,
		[Talents.T_DIMENSIONAL_STEP]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate spinner", color=colors.SLATE,
	desc = [[Easily as big as a horse, this giant spider menaces at you with claws and fangs.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	size_category = 4,
	max_life = resolvers.rngavg(60,70),
	combat_armor = 3, combat_def = 5,
	combat = { dam=resolvers.levelup(9, 1, 0.9), atk=15, apr=4, damtype=DamageType.CLOCK, },
	resolvers.talents{
		[Talents.T_LAY_WEB]=1,
		[Talents.T_SPIDER_WEB]=1,
		[Talents.T_DIMENSIONAL_STEP]=1,
		[Talents.T_TURN_BACK_THE_CLOCK]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate weaver", color=colors.WHITE,
	desc = [[A large white spider.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3, damtype=DamageType.WASTING, },

	talent_cd_reduction = {[Talents.T_RETHREAD]=-10},

	resolvers.talents{
		[Talents.T_SPIN_FATE]=2,
		[Talents.T_BANISH]=2,
		[Talents.T_RETHREAD]=2,
		[Talents.T_STATIC_HISTORY]=2,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver queen", color=colors.WHITE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_weaver_queen.png", display_h=2, display_y=-1}}},
	desc = [[A large white spider.]],
	level_range = {7, nil}, exp_worth = 1,
	unique = true,
	rarity = false,
	max_life = 150, life_rating = 10, fixed_rating = true,
	rank = 4,
	tier1 = true,
	size_category = 4,
	instakill_immune = 1,

	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3, damtype=DamageType.CLOCK, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="TIMESHARD"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	talent_cd_reduction = {[Talents.T_RETHREAD]=-10},

	resolvers.talents{
		[Talents.T_SPIN_FATE]=2,
		[Talents.T_BANISH]=2,
		[Talents.T_RETHREAD]=2,
		[Talents.T_STATIC_HISTORY]=2,
		[Talents.T_FADE_FROM_TIME]=3,
		[Talents.T_BODY_REVERSION]=1,
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-point-zero", engine.Quest.COMPLETED, "morass")
		require("engine.ui.Dialog"):simplePopup("As you vanquish the queen you notice a temporal thread that seems to have been controlling her. It seems to go through a rift.")
		local rift = game.zone:makeEntityByName(game.level, "terrain", "RIFT_HOME")
		game.zone:addEntity(game.level, rift, "terrain", self.x, self.y)
	end,
}

--[=[
newEntity{ base="BASE_NPC_LOSGOROTH", define_as = "SPACIAL_DISTURBANCE",
	unique = true,
	name = "Spacial Disturbance",
	color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png"},
	resolvers.generic(function(e) if engine.Map.tiles.nicer_tiles then e:addParticles(engine.Particles.new("wormhole", 1, {image="shockbolt/npc/elemental_losgoroth_space_disturbance", speed=1})) end end),
	desc = [[A hole in the fabric of space, it seems to be the source of the expanse unstability.]],
	killer_message = "and folded out of existence",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 10, fixed_rating = true,
	mana_regen = 7,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	tier1 = true,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	can_pass = {pass_void=0},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="VOID_STAR"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_VOID_BLAST]={base=1, every=7, max=7},
		[Talents.T_MANATHRUST]={base=1, every=7, max=7},
		[Talents.T_PHASE_DOOR]=2,
	},
	resolvers.inscriptions(1, {"manasurge rune"}),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		local q = game.player:hasQuest("start-archmage")
		if q then q:stabilized() end
		game.player:resolveSource():setQuestStatus("start-archmage", engine.Quest.COMPLETED, "abashed")
	end,
}
]=]
