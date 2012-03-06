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

load("/data/general/npcs/yaech.lua", rarity(0))
load("/data/general/npcs/aquatic_critter.lua", rarity(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_YAECH", define_as = "MURGOL",
	unique = true,
	name = "Murgol, the Yaech Lord",
	color=colors.VIOLET,
	desc = [[You can feel the psionic waves of power come from this yaech.]],
	killer_message = "and flushed out to sea",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 100, life_rating = 13, fixed_rating = true,
	psi_regen = 10,
	infravision = 10,
	stats = { str=10, dex=10, cun=15, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	rank = 4,

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1, MAINHAND=1 },

	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
		{type="armor", subtype="light", defined="EEL_SKIN", random_art_replace={chance=65}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_PYROKINESIS]=2,
		[Talents.T_REACH]=2,
		[Talents.T_MINDLASH]=2,
		[Talents.T_MINDHOOK]=2,
		[Talents.T_KINETIC_SHIELD]=3,
		[Talents.T_THERMAL_SHIELD]=3,
	},
	resolvers.sustains_at_birth(),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
	end,
}
