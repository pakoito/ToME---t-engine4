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

load("/data/general/npcs/orc.lua", rarity(3))
load("/data/general/npcs/orc-gorbat.lua", rarity(0))
load("/data/general/npcs/cold-drake.lua", rarity(0))
load("/data/general/npcs/storm-drake.lua", rarity(0))
load("/data/general/npcs/fire-drake.lua", rarity(0))
load("/data/general/npcs/multihued-drake.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_GORBAT", define_as = "GORBAT",
	allow_infinite_dungeon = true,
	name = "Gorbat, Supreme Wyrmic of the Pride", color=colors.VIOLET, unique = true,
	desc = [[An orc with scaly skin, claws and a pair of small wings on his back.]],
	level_range = {40, nil}, exp_worth = 2,
	rank = 5,
	max_life = 250, life_rating = 29, fixed_rating = true,
	infravision = 20,
	stats = { str=12, dex=10, cun=100, mag=21, con=14 },
	move_others=true,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "wyrmic",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(4, "infusion"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },

	resolvers.equip{
		{type="weapon", subtype="greatmaul", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="light", defined="CHROMATIC_HARNESS", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="ORB_DRAGON"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE_LORE"} },

	talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, },
	equilibrium_regen = -8,

	resolvers.talents{
		[Talents.T_NATURE_TOUCH]=5,

		[Talents.T_ICE_BREATH]=10,
		[Talents.T_FIRE_BREATH]=10,
		[Talents.T_SAND_BREATH]=10,

		[Talents.T_ICY_SKIN]=5,
		[Talents.T_ICE_CLAW]=7,

		[Talents.T_BELLOWING_ROAR]=7,
		[Talents.T_WING_BUFFET]=5,
		[Talents.T_ACIDIC_SKIN]=7,

		[Talents.T_WARPER]=7,
		[Talents.T_RITCH_FLAMESPITTER]=10,
		[Talents.T_RESILIENCE]=5,

		[Talents.T_HOWL]=5,

		[Talents.T_DISARM]=5,
		[Talents.T_WEAPON_COMBAT]=7,
		[Talents.T_WEAPONS_MASTERY]=5,

		[Talents.T_MASSIVE_ARMOUR_TRAINING]=5,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "gorbat")
		if not game.player:hasQuest("pre-charred-scar") then
			game.player:grantQuest("pre-charred-scar")
		end
	end,
}
