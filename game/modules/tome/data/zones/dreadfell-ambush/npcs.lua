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

load("/data/general/npcs/orc.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC", define_as = "UKRUK",
	unique = true,
	name = "Ukruk the Fierce",
	faction = "orc-pride",
	color=colors.VIOLET,
	desc = [[This ugly orc looks really nasty and vicious. He is obviously looking for something and bears an unknown symbol on his shield.]],
	level_range = {30, nil}, exp_worth = 2,
	max_life = 1500, life_rating = 18, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_spellresist = 70,
	combat_mentalresist = 70,
	combat_physresist = 70,
	see_invisible = 38,

	resolvers.equip{
		{type="weapon", subtype="longsword", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drop_randart{},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]=5, [Talents.T_ASSAULT]=5, [Talents.T_OVERPOWER]=5, [Talents.T_RUSH]=5,
	},
	combat_atk = 1000,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, {}),

	on_die = function(self, who)
		world:gainAchievement("KILL_UKRUK", game.player)
		local q = game.player:resolveSource():hasQuest("staff-absorption")
		if q then q:killed_ukruk(game.player:resolveSource()) end
	end,
}
