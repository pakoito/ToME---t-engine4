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

-- Of the greater undead, vampires are the crossover between physical and magical prowess.  They possess a life draining attack and they are able to cast some powerful spells.
-- Ranks: vampire, master vampire, elder vampire, vampire lord.
-- to be added? ancient vampire
--taken from the T2 list, with oriental vampire removed, does it really have a part here in ToME?

-- last updated: 4:00pm March 1st, 2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_VAMPIRE",
	type = "undead", subtype = "vampires",
	display = "V", color=colors.WHITE,
	desc = [[These ancient cursed beings often take upon the form of a bat and attack its prey.]],

	combat = { dam=resolvers.rngavg(9,13), atk=10, apr=9, damtype=DamageType.DRAINLIFE, dammod={str=1.9} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	drops = resolvers.drops{chance=20, nb=1, {} },

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=9, },
	energy = { mod=1 },
	stats = { str=12, dex=12, mag=12, con=12 },
	infravision = 20,
	life_regen = 3,
	size_category = 3,
	rank = 2,

	open_door = true,

	resolvers.tmasteries{ ["technique/other"]=0.5, ["spell/phantasm"]=0.8, },
	resolvers.sustains_at_birth(),

	resists = { [DamageType.COLD] = 80, [DamageType.NATURE] = 80, [DamageType.LIGHT] = -50,  },
	blind_immune = 1,
	confusion_immune = 1,
	see_invisible = 5,
	undead = 1,
--	free_action = 1,
--	sleep_immune = 1,
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "lesser vampire", color=colors.SLATE,
	desc=[[This vampire has only just begun it's new life, it has not yet fathomed its newfound power.  Yet it still has its thirst for blood.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 7, combat_def = 6,

	resolvers.talents{ [Talents.T_STUN]=1 },
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "vampire", color=colors.SLATE,
	desc=[[It is a humanoid with an aura of power. You notice a sharp set of front teeth.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 9, combat_def = 6,

	resolvers.talents{ [Talents.T_STUN]=1, [Talents.T_BLUR_SIGHT]=1, [Talents.T_ROTTING_DISEASE]=1, },
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "master vampire", color=colors.GREEN,
	desc=[[It is a humanoid form dressed in robes. Power emanates from its chilling frame.]],
	level_range = {23, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(80,90),
	combat_armor = 10, combat_def = 8,
	ai = "dumb_talented_simple", ai_state = { talent_in=6, },
	resolvers.talents{ [Talents.T_STUN]=1, [Talents.T_BLUR_SIGHT]=2, [Talents.T_PHANTASMAL_SHIELD]=1, [Talents.T_ROTTING_DISEASE]=2, },
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "elder vampire", color=colors.RED,
	desc=[[A terrible robed undead figure, this creature has existed in its unlife for many centuries by stealing the life of others.
It can summon the very shades of its victims from beyond the grave to come enslaved to its aid.]],
	level_range = {26, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 12, combat_def = 10,
	rank = 3,
	ai = "dumb_talented_simple", ai_state = { talent_in=6, },
	summon = {{type="undead", number=1, hasxp=false}, },
	resolvers.talents{ [Talents.T_STUN]=2, [Talents.T_SUMMON]=1, [Talents.T_BLUR_SIGHT]=3, [Talents.T_PHANTASMAL_SHIELD]=2, [Talents.T_ROTTING_DISEASE]=3, },
}

newEntity{ base = "BASE_NPC_VAMPIRE",
	name = "vampire lord", color=colors.BLUE,
	desc=[[A foul wind chills your bones as this ghastly figure approaches.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 9,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 15, combat_def = 15,
	rank = 3,
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
	summon = {{type="undead", number=1, hasxp=false}, },
	resolvers.talents{ [Talents.T_STUN]=4, [Talents.T_SUMMON]=1, [Talents.T_BLUR_SIGHT]=4, [Talents.T_PHANTASMAL_SHIELD]=5, [Talents.T_ROTTING_DISEASE]=5, },
	make_escort = {
		{type="undead", number=resolvers.mbonus(2, 2)},
	},
}
