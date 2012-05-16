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
load("/data/general/npcs/orc-grushnak.lua", rarity(4))
load("/data/general/npcs/bone-giant.lua", rarity(4))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_GRUSHNAK", define_as = "GNARG",
	allow_infinite_dungeon = true,
	name = "Warmaster Gnarg", color=colors.VIOLET, unique = true,
	desc = [[This ugly orc looks really nasty and vicious. He wields a huge two-handed sword and means to use it.]],
	level_range = {35, nil}, exp_worth = 2,
	rank = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=22, dex=20, cun=12, mag=21, con=14 },
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_spellresist = 30,
	combat_physresist = 50,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"tank",
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(2, "infusion"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },

	resolvers.equip{
		{type="weapon", subtype="greatsword", defined="MURDERBLADE", random_art_replace={chance=75}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	-- Reduce cooldowns
	talent_cd_reduction={[Talents.T_RUSH]=35,},

	resolvers.talents{
		[Talents.T_RUSH]=5,
		[Talents.T_WARSHOUT]={base=5, every=7, max=7},
		[Talents.T_STUNNING_BLOW]={base=5, every=7, max=7},
		[Talents.T_SUNDER_ARMOUR]={base=5, every=7, max=7},
		[Talents.T_SLOW_MOTION]={base=5, every=7, max=7},
		[Talents.T_SHATTERING_SHOUT]={base=5, every=7, max=7},
		[Talents.T_SECOND_WIND]={base=5, every=7, max=7},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base="GREATER_MULTI_HUED_WYRM", define_as="OVERPOWERED_WYRM",
	name = "overpowered greater multi-hued wyrm",
	image = "npc/dragon_multihued_greater_multi_hued_wyrm.png",
	level_range = {100, nil}, exp_worth = 3,
	wyrm_rarity = 1, rarity = false,
	rank = 3.5,
	no_breath = 1,
	seen_by = function(self, who)
		if game:getPlayer(true) ~= who then return end
		world:gainAchievement("UBER_WYRMS_OPEN", who)
		self:setTarget(who)
	end,
	on_die = function(self, who)
		world:gainAchievement("UBER_WYRMS", game:getPlayer(true))
	end,
}
