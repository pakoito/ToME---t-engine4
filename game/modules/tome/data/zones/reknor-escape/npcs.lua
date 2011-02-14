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

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/molds.lua", rarity(1))
load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "BROTOQ",
	allow_infinite_dungeon = true,
	type = "undead", subtype = "skeleton", unique = true,
	name = "The Shade",
	display = "s", color=colors.VIOLET,
	shader = "unique_glow",
	desc = [[This skeleton looks nasty. There are red flames in its empty eye sockets. It wields a nasty sword and strides toward you, throwing spells.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_mana = 85,
	max_stamina = 85,
	rank = 4,
	size_category = 3,
	undead = 1,
	infravision = 20,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	blind_immune = 1,
	bleed_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="staff", defined="STAFF_KOR", random_art_replace={chance=75}, autoreq=true}, {type="armor", subtype="light", autoreq=true}, },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_MANATHRUST]=4, [Talents.T_FREEZE]=4, [Talents.T_TIDAL_WAVE]=2,
		[Talents.T_WEAPONS_MASTERY]=3,
	},
	resolvers.inscriptions(1, {"shielding rune", "phase door rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),
	inc_damage = {all=-20},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("KOR_FURY", 5, 35, ".. yes I tell you! The old ruins of Kor'Pul are still haunted!")
		game.player:resolveSource():grantQuest("start-allied")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "kor-pul")
	end,
}

-- Your ally
newEntity{ define_as = "NORGAN",
	type = "humanoid", subtype = "dwarf", unique = true,
	name = "Norgan",
	display = "@", color=colors.UMBER,
	faction = "iron-throne",
	desc = [[Norgan and you are the sole survivors of the Reknor expedition, your duty is to make sure the news come back to the Iron Council.]],
	level_range = {1, 1},
	max_life = 120, life_rating = 12, fixed_rating = true,
	rank = 3,
	stats = { str=19, dex=10, cun=12, mag=8, con=16, wil=13 },
	move_others=true,
	never_anger = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatmaul", name="iron greatmaul", autoreq=true},
		{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		{type="lite", subtype="lite", name="brass lantern"},
	},

	resolvers.talents{
		[Talents.T_DWARF_RESILIENCE]=1,
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_STUNNING_BLOW]=2,
		[Talents.T_WEAPON_COMBAT]=2,
		[Talents.T_WEAPONS_MASTERY]=2,
	},
	resolvers.inscriptions(1, {"regeneration infusion"}),

	autolevel = "zerker",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-dwarf", engine.Quest.COMPLETED, "norgan-dead")
	end,
}
