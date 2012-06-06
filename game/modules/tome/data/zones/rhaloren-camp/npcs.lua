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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/molds.lua", rarity(5))
load("/data/general/npcs/elven-warrior.lua", rarity(0))
load("/data/general/npcs/elven-caster.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "INQUISITOR",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "shalore", unique = true,
	name = "Rhaloren Inquisitor",
	display = "p", color=colors.VIOLET, female = true,
	desc = [[This tall elf rush to you, wielding both her greatsword and magical spells.]],
	killer_message = "and hung from the rafters",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, auto_req=true}, {type="armor", subtype="light", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {defined="ROD_OF_ANNULMENT", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE5"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=3, [Talents.T_SOUL_ROT]=3,
		[Talents.T_WEAPONS_MASTERY]=2,
		[Talents.T_RUSH]=2,
	},
	resolvers.inscriptions(1, {"shielding rune", "speed rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),
	inc_damage = {all=-20},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-shaloren", engine.Quest.COMPLETED, "rhaloren")
	end,
}
