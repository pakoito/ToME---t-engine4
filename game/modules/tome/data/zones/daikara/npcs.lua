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

load("/data/general/npcs/xorn.lua", rarity(4))
load("/data/general/npcs/canine.lua", rarity(2))
load("/data/general/npcs/snow-giant.lua", rarity(0))
load("/data/general/npcs/cold-drake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "RANTHA_THE_WORM",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "ice", unique = true,
	name = "Rantha the Worm",
	display = "D", color=colors.VIOLET,
	desc = [[Claws and teeth. Ice and death. Dragons are not all extinct it seems...]],
	level_range = {12, nil}, exp_worth = 2,
	max_life = 230, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	combat_armor = 17, combat_def = 14,
	infravision = 20,
	instakill_immune = 1,
	stun_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },

	resists = { [DamageType.FIRE] = -20, [DamageType.COLD] = 100 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="FROST_TREADS", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=3,

		[Talents.T_ICE_STORM]=2,
		[Talents.T_FREEZE]=3,

		[Talents.T_ICE_CLAW]={base=4, every=6},
		[Talents.T_ICY_SKIN]={base=3, every=7},
		[Talents.T_ICE_BREATH]={base=4, every=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("MASSOK", 7, 43, "I have heard there is a dragon hunter in the Daikara that is unhappy about the wyrm being already dead.")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "daikara")
	end,
}

newEntity{ base="BASE_NPC_ORC_GRUSHNAK", define_as = "MASSOK",
	allow_infinite_dungeon = true,
	name = "Massok the Dragonslayer", color=colors.VIOLET, unique = true,
	desc = [[A huge and heavily-scarred orc with a gigantic sword. His helm is fashioned from a dragon skull.]],
	level_range = {45, nil}, exp_worth = 3,
	rank = 4,
	max_life = 500, life_rating = 25, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=12, wil=45, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_armor = 10, combat_def = 10,
	stamina_regen = 40,

	open_door = true,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {"wild infusion", "healing infusion", "regeneration infusion", "heroism infusion"}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1, FINGER=2, NECK=1 },

	resists = { [DamageType.COLD] = 100 },

	resolvers.equip{
		{type="weapon", subtype="battleaxe", ego_change=100, autoreq=true},
		{type="armor", subtype="massive", ego_chance=100, autoreq=true},
		{type="armor", subtype="head", defined="DRAGON_SKULL", random_art_replace={chance=75}, autoreq=true},
		{type="armor", subtype="feet", ego_chance=100, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]=7,
		[Talents.T_HEAVY_ARMOUR_TRAINING]=7,
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=7,
		[Talents.T_WEAPONS_MASTERY]=7,
		[Talents.T_RUSH]=9,
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_STUNNING_BLOW]=4,
		[Talents.T_JUGGERNAUT]=5,
		[Talents.T_SHATTERING_IMPACT]=5,
		[Talents.T_BATTLE_SHOUT]=5,
		[Talents.T_BERSERKER]=5,
		[Talents.T_UNSTOPPABLE]=5,
		[Talents.T_MORTAL_TERROR]=5,
		[Talents.T_BLOODBATH]=5,
	},
	resolvers.sustains_at_birth(),
}
