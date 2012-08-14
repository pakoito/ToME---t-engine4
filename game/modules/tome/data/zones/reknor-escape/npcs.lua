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

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/molds.lua", rarity(1))
load("/data/general/npcs/orc.lua", function(e) if e.level_range and e.level_range[1] == 10 then e.level_range[1] = 1 e.start_level = 1 end end) -- Make orcs lower level, not a problem we have norgan to help!
load("/data/general/npcs/snake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "BROTOQ",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "orc", unique = true,
	name = "Brotoq the Reaver",
	display = "o", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_brotoq_the_reaver.png", display_h=2, display_y=-1}}},
	desc = [[A huge orc blocks your way to the Iron Council. You must pass.]],
	killer_message = ", who ate their brains still warm,",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=20, dex=10, cun=12, mag=20, con=12 },
	instakill_immune = 1,
	move_others=true,
	inc_damage = {all=-40},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="waraxe", defined="FAKE_SKULLCLEAVER", never_drop=true},
		{type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="light", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {type="weapon", subtype="waraxe", defined="SKULLCLEAVER", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]=2,
		[Talents.T_CORRUPTED_STRENGTH]=1,
		[Talents.T_CARRIER]=1,
		[Talents.T_ACID_BLOOD]=1,
		[Talents.T_REND]=2,
		[Talents.T_WEAPONS_MASTERY]=1,
	},
	resolvers.inscriptions(1, {"wild infusion"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },

	-- Remove free melee; poor brotoq
	forbid_corrupted_strength_blow = 0,

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-dwarf", engine.Quest.COMPLETED, "brotoq")
	end,
}

-- Your ally
newEntity{ define_as = "NORGAN",
	type = "humanoid", subtype = "dwarf", unique = true,
	name = "Norgan",
	display = "@", color=colors.UMBER,
	faction = "iron-throne",
	desc = [[Norgan and you are the sole survivors of the Reknor expedition, your duty is to make sure the news come back to the Iron Council.]],
	level_range = {1, nil},
	max_life = 120, life_rating = 12, fixed_rating = true,
	rank = 3,
	stats = { str=19, dex=10, cun=12, mag=8, con=16, wil=13 },
	move_others=true,
	never_anger = true,
	remove_from_party_on_death = true,
	silent_levelup = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatmaul", name="iron greatmaul", autoreq=true},
		{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		{type="lite", subtype="lite", name="brass lantern"},
	},

	resolvers.talents{
		[Talents.T_DWARF_RESILIENCE]=1,
		[Talents.T_ARMOUR_TRAINING]=2,
		[Talents.T_STUNNING_BLOW]=2,
		[Talents.T_WEAPON_COMBAT]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
	},
	resolvers.inscriptions(1, {"regeneration infusion"}),

	autolevel = "zerker",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-dwarf", engine.Quest.COMPLETED, "norgan-dead")
	end,
}
