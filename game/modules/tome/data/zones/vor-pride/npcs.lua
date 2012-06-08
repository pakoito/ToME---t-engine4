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

load("/data/general/npcs/orc.lua", rarity(3))
load("/data/general/npcs/orc-vor.lua", rarity(0))
load("/data/general/npcs/bone-giant.lua", function(e) if e.rarity then e.bonegiant_rarity = e.rarity; e.rarity = nil end end)

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_VOR", define_as = "VOR",
	allow_infinite_dungeon = true,
	name = "Vor, Grand Geomancer of the Pride", color=colors.VIOLET, unique = true,
	desc = [[An old orc, wearing multi-colored robes. Ice shards fly around him, leaving a trail of fire and lightning bursts.]],
	killer_message = "and used as target practice for initiate mages",
	level_range = {40, nil}, exp_worth = 1,
	rank = 5,
	max_life = 250, life_rating = 19, fixed_rating = true,
	infravision = 10,
	stats = { str=12, dex=10, cun=12, mag=21, con=14 },
	move_others=true,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },

	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="head", defined="CROWN_ELEMENTS", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="ORB_ELEMENTS"} },
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE_LORE"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	in_damages = {all=25},

	resolvers.talents{
		[Talents.T_FLAME]={base=5, every=7, max=7},
		[Talents.T_FLAMESHOCK]={base=5, every=7, max=7},
		[Talents.T_FIREFLASH]={base=5, every=7, max=7},
		[Talents.T_INFERNO]={base=5, every=7, max=7},
		[Talents.T_BLASTWAVE]={base=5, every=7, max=7},
		[Talents.T_CLEANSING_FLAMES]={base=5, every=7, max=7},
		[Talents.T_BURNING_WAKE]={base=5, every=7, max=7},

		[Talents.T_FREEZE]={base=5, every=7, max=7},
		[Talents.T_ICE_STORM]={base=5, every=7, max=7},
		[Talents.T_TIDAL_WAVE]={base=5, every=7, max=7},
		[Talents.T_ICE_SHARDS]={base=5, every=7, max=7},
		[Talents.T_FROZEN_GROUND]={base=5, every=7, max=7},

		[Talents.T_LIGHTNING]={base=5, every=7, max=7},
		[Talents.T_CHAIN_LIGHTNING]={base=5, every=7, max=7},

		[Talents.T_SPELLCRAFT]={base=5, every=7, max=7},
		[Talents.T_ESSENCE_OF_SPEED]={base=1, every=6, max=7},
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "vor")
		if not game.player:hasQuest("pre-charred-scar") then
			game.player:grantQuest("pre-charred-scar")
		end
	end,
}
