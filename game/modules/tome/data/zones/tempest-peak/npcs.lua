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

load("/data/general/npcs/gwelgoroth.lua", rarity(0))
load("/data/general/npcs/xorn.lua", rarity(2))
load("/data/general/npcs/snow-giant.lua", rarity(0))
load("/data/general/npcs/storm-drake.lua", rarity(1))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "URKIS",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Urkis, the High Tempest",
	display = "p", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_urkis__the_high_tempest.png", display_h=2, display_y=-1}}},
	desc = [[Lightning crackles around this middle-aged man. He radiates power.]],
	killer_message = "and used in mad electrical reanimation experiments",
	level_range = {17, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_mana = 850, mana_regen = 40,
	rank = 4,
	size_category = 2,
	infravision = 10,
	stats = { str=10, dex=12, cun=14, mag=25, con=16 },

	instakill_immune = 1,
	blind_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resists = { [DamageType.LIGHTNING] = 100, },

	resolvers.talents{
		[Talents.T_FREEZE]=4,
		[Talents.T_ICE_SHARDS]=4,
		[Talents.T_LIGHTNING]=5,
		[Talents.T_SHOCK]=4,
		[Talents.T_HURRICANE]=4,
		[Talents.T_NOVA]=4,
		[Talents.T_THUNDERSTORM]=5,
		[Talents.T_TEMPEST]=5,
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("lightning-overload", engine.Quest.COMPLETED)
	end,
}
