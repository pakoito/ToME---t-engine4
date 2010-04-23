-- ToME - Tales of Middle-Earth
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

--  Wights had the power to confuse and paralyze
-- their icy grasp will sap willpower and drain exp
--
--they will have high treasure, but be *hard*

--in the books they could confuse and paralyze and sleep and bend lesser minds to do their will and cause fear.  fear would be more of an aura (need to save against it, but realistically it would only be once).
-- they could also be mind affecting too :)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_VAMPIRE",
	type = "undead", subtype = "vampire",
	display = "V", color=colors.WHITE,

	combat = { dam=resolvers.rngavg(9,13), atk=10, apr=9, dammod={str=0.85}, damtype=DamageType.DRAINLIFE },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {ego_chance=20} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
	energy = { mod=1 },
	stats = { str=11, dex=11, mag=15, con=12 },
	rank = 2,
	size_category = 3,

	resolvers.tmasteries{ ["technique/other"]=0.3, ["spell/air"]=0.3, ["spell/fire"]=0.3 },

	resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.PHYSICAL] = 15, [DamageType.LIGHT] = -100, },
	poison_immune = 1,
	blind_immune = 1,
	see_invisible = 7,
	undead = 1,
	stun_immune = 0.7,
	sleep_immune = 1,
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "lesser vampire", color=colors.GREEN,
	desc=[[it sucks blood! It wants yours!]],
	level_range = {16, 50}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 7, combat_def = 6,
}
