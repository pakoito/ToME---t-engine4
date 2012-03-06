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

newEntity{ define_as = "BEN_CRUTHDAR",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Ben Cruthdar, the Cursed",
	display = "p", color=colors.VIOLET,
	desc = [[This madman looks extremely dangerous. He wields a big axe and means to use it.
A gloomy aura emanates from him.]],
	level_range = {10, nil}, exp_worth = 2,
	max_life = 250, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=15, wil=18, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="battleaxe", tome_drops="boss", force_drop=true, autoreq=true}, },
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_DISMAY]=3,
		[Talents.T_UNNATURAL_BODY]=4,
		[Talents.T_DOMINATE]=1,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_SLASH]=3,
		[Talents.T_RECKLESS_CHARGE]=1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "healing infusion"),

	on_die = function(self, who)
		local Chat = require "engine.Chat"
		Chat.new("lumberjack-quest-done", self, game.player:resolveSource()):invoke()
	end,
}

newEntity{ defined_as = "LUMBERJACK",
	type = "humanoid", subtype = "human",
	name = "lumberjack",
	display = "p", color=colors.UMBER, faction = "allied-kingdoms",
	desc = [[A lumberjack. Cutting wood is his job, dream and passion.]],
	level_range = {1, 1}, exp_worth = 1,
	rarity = 1,
	max_life = 100, life_rating = 10,
	stats = { str=20 },
	rank = 2,
	size_category = 2,
	infravision = 10,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="flee_dmap", },

	on_die = function(self, who)
		game.player:resolveSource():hasQuest("lumberjack-cursed"):lumberjack_dead()
	end,
}
