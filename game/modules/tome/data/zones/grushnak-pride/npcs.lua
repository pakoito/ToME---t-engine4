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
load("/data/general/npcs/orc-grushnak.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_GRUSHNAK", define_as = "GRUSHNAK",
	allow_infinite_dungeon = true,
	name = "Grushnak, Battlemaster of the Pride", color=colors.VIOLET, unique = true,
	desc = [[An old orc, covered in battle scars, he looks fierce and very, very, dangerous.]],
	level_range = {45, nil}, exp_worth = 2,
	rank = 5,
	max_life = 700, life_rating = 25, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=12, wil=45, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	combat_armor = 10, combat_def = 10,
	stamina_regen = 40,

	open_door = true,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, "infusion"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1, FINGER=2, NECK=1 },

	resolvers.equip{
		{type="weapon", subtype="waraxe", ego_change=100, autoreq=true},
		{type="armor", subtype="shield", ego_change=100, autoreq=true},
		{type="armor", subtype="massive", ego_chance=100, autoreq=true},
		{type="armor", subtype="head", ego_chance=100, autoreq=true},
		{type="armor", subtype="feet", ego_chance=100, autoreq=true},
--		Commented because this can generate rings of invis or amulets of telepathy and drain the life of the boss
--		{type="jewelry", subtype="amulet", ego_chance=100, autoreq=true},
--		{type="jewelry", subtype="ring", ego_chance=100, autoreq=true},
		{type="jewelry", subtype="ring", defined="PRIDE_GLORY", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="ORB_DESTRUCTION"} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE_LORE"} },

	make_escort = {
		{type="orc", no_subescort=true, number=resolvers.mbonus(6, 5)},
	},

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]=10,
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=10,
		[Talents.T_WEAPONS_MASTERY]=10,
		[Talents.T_RUSH]=5,
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_SHIELD_PUMMEL]=4,
		[Talents.T_OVERPOWER]=5,
		[Talents.T_ASSAULT]=3,
		[Talents.T_SHIELD_EXPERTISE]=5,
		[Talents.T_BATTLE_SHOUT]=3,
		[Talents.T_SHIELD_WALL]=5,
		[Talents.T_SHATTERING_SHOUT]=5,
		[Talents.T_BATTLE_CRY]=5,
		[Talents.T_ONSLAUGHT]=5,
		[Talents.T_SECOND_WIND]=5,
		[Talents.T_JUGGERNAUT]=5,
		[Talents.T_UNSTOPPABLE]=5,
		[Talents.T_MORTAL_TERROR]=3,
		[Talents.T_BLOODBATH]=5,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "grushnak")
		if not game.player:hasQuest("pre-charred-scar") then
			game.player:grantQuest("pre-charred-scar")
		end
	end,
}
