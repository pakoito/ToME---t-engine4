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
load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "SHADE",
	allow_infinite_dungeon = true,
	type = "undead", subtype = "skeleton", unique = true,
	name = "The Shade",
	display = "s", color=colors.VIOLET,
	shader = "unique_glow",
	desc = [[This skeleton looks nasty. There are red flames in its empty eye sockets. It wields a nasty sword and strides toward you, throwing spells.]],
	killer_message = "and left to rot",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_mana = 85,
	max_stamina = 85,
	rank = 4,
	size_category = 3,
	undead = 1,
	infravision = 10,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	blind_immune = 1,
	bleed_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="staff", defined="STAFF_KOR", random_art_replace={chance=75}, autoreq=true}, {type="armor", subtype="light", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_MANATHRUST]=4, [Talents.T_FREEZE]=4, [Talents.T_TIDAL_WAVE]=2,
		[Talents.T_WEAPONS_MASTERY]=2,
	},
	resolvers.inscriptions(1, {"shielding rune", "phase door rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),
	inc_damage = {all=-20},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("KOR_FURY", 3, 35, ".. yes I tell you! The old ruins of Kor'Pul are still haunted!")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "kor-pul")
	end,
}

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "KOR_FURY",
	allow_infinite_dungeon = true,
	type = "undead", subtype = "ghost", unique = true,
	name = "Kor's Fury",
	display = "G", color=colors.VIOLET,
	desc = [[The shade's colossal will keeps it anchored to this world, now as a vengeful, insane spirit.]],
	level_range = {38, nil}, exp_worth = 3,
	max_life = 250, life_rating = 20, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },

	undead = 1,
	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	bleed_immune = 1,
	teleport_immune = 0.5,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	see_invisible = 80,
	move_others=true,

	can_pass = {pass_wall=70},
	resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="light", forbid_power_source={antimagic=true}, autoreq=true},
		{type="jewelry", subtype="amulet", defined="VOX", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_MANATHRUST]={base=5, every=6, max=8},
		[Talents.T_FREEZE]={base=5, every=6, max=8},
		[Talents.T_TIDAL_WAVE]={base=5, every=6, max=8},
		[Talents.T_ICE_STORM]={base=5, every=6, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=6, max=8},
		[Talents.T_EMPATHIC_HEX]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_DEATH]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_IMPOTENCE]={base=5, every=6, max=8},
		[Talents.T_VIRULENT_DISEASE]={base=5, every=6, max=8},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { ai_target="target_player_radius", sense_radius=50, talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
}
