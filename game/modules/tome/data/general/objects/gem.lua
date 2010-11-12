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

local Stats = require "engine.interface.ActorStats"

newEntity{
	define_as = "BASE_GEM",
	type = "gem", subtype="white",
	display = "*", color=colors.YELLOW,
	encumber = 0,
	identified = true,
	stacking = true,
	desc = [[Gems can be sold for money or used in arcane rituals.]],
}

local function newGem(name, image, cost, rarity, color, min_level, max_level, tier, power, imbue, bomb, mana_consume)
	-- Gems, randomly lootable
	newEntity{ base = "BASE_GEM", define_as = "GEM_"..name:upper(),
		name = name:lower(), subtype = color,
		color = colors[color:upper()], image=image,
		level_range = {min_level, max_level},
		rarity = rarity, cost = cost,
		mana_consume = mana_consume,
		material_level = tier,
		imbue_powers = imbue,
	}
	-- Alchemist gems, not lootable, only created by talents
	newEntity{ base = "BASE_GEM", define_as = "ALCHEMIST_GEM_"..name:upper(),
		name = "alchemist "..name:lower(), type='alchemist-gem', subtype = color,
		slot = "QUIVER",
		color = colors[color:upper()], image=image,
		cost = 0,
		material_level = tier,
		alchemist_power = power,
		alchemist_bomb = bomb,
	}
end

newGem("Diamond",	"object/diamond.png",5,	18,	"white",	40,	50, 5, 70,
	{ inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, } },
	{ power=25 },
	300
)
newGem("Pearl",	"object/pearl.png",	5,	18,	"white",	40,	50, 5, 70,
	{ resists = {all=10} },
	{ splash={type="LITE", dam=1} },
	300
)
newGem("Moonstone",	"object/moonstone.png",5,	18,	"white",	40,	50, 5, 70,
	{ combat_def=10 },
	{ stun={chance=20, dur=3} },
	300
)
newGem("Fire Opal",	"object/fireopal.png",5,	18,	"red",		40,	50, 5, 70,
	{ inc_damage = {all=10} },
	{ splash={type="FIRE", dam=40} },
	300
)
newGem("Bloodstone",	"object/bloodstone.png",5,	18,	"red",		40,	50, 5, 70,
	{ stun_immune=0.6 },
	{ leech=10 },
	300
)
newGem("Ruby",		"object/ruby.png",	4,	16,	"red",		30,	40, 4, 65,
	{ inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 4, } },
	{ power=20 },
	250
)
newGem("Amber",		"object/amber.png",	4,	16,	"yellow",	30,	40, 4, 65,
	{ inc_damage = {all=8} },
	{ stun={chance=10, dur=2} },
	250
)
newGem("Turquoise",	"object/turquoise.png",4,	16,	"green",	30,	40, 4, 65,
	{ see_invisible=10 },
	{ splash={type="ACID", dam=30} },
	250
)
newGem("Jade",		"object/jade.png",	4,	16,	"green",	30,	40, 4, 65,
	{ resists = {all=8} },
	{ splash={type="SLOW", dam=-1 + 1 / (1 + 0.20)} },
	250
)
newGem("Sapphire",	"object/garnet.png",4,	16,	"blue",		30,	40, 4, 65,
	{ combat_def=8 },
	{ splash={type="ICE", dam=30} },
	250
)
newGem("Quartz",	"object/quartz.png",3,	12,	"white",	20,	30, 3, 50,
	{ stun_immune=0.3 },
	{ splash={type="SPELLKNOCKBACK", dam=10} },
	200
)
newGem("Emerald",	"object/emerald.png",3,	12,	"green",	20,	30, 3, 50,
	{ resists = {all=6} },
	{ splash={type="POISON", dam=50} },
	200
)
newGem("Lapis Lazuli",	"object/lapis_lazuli.png",3,	12,	"blue",		20,	30, 3, 50,
	{ combat_def=6 },
	{ mana=30 },
	200
)
newGem("Garnets",	"object/garnet.png",3,	12,	"red",		20,	30, 3, 50,
	{ inc_damage = {all=6} },
	{ leech=5 },
	200
)
newGem("Onyx",		"object/.png",	3,	12,	"black",	20,	30, 3, 50,
	{ inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_MAG] = 3, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 3, [Stats.STAT_CON] = 3, } },
	{ power=15 },
	200
)
newGem("Amethyst",	"object/.png",2,	10,	"violet",	10,	20, 2, 35,
	{ inc_damage = {all=4} },
	{ splash={type="ARCANE", dam=25}},
	150
)
newGem("Opal",		"object/.png",	2,	10,	"blue",		10,	20, 2, 35,
	{ inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_DEX] = 2, [Stats.STAT_MAG] = 2, [Stats.STAT_WIL] = 2, [Stats.STAT_CUN] = 2, [Stats.STAT_CON] = 2, } },
	{ power=10 },
	150
)
newGem("Topaz",		"object/.png",	2,	10,	"blue",		10,	20, 2, 35,
	{ combat_def=4 },
	{ range=3 },
	150
)
newGem("Aquamarine",	"object/.png",2,	10,	"blue",		10,	20, 2, 35,
	{ resists = {all=4} },
	{ mana=20 },
	150
)
newGem("Ametrine",	"object/.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ inc_damage = {all=2} },
	{ splash={type="LITE", dam=1} },
	100
)
newGem("Zircon",	"object/.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ resists = {all=2} },
	{ daze={chance=20, dur=3} },
	100
)
newGem("Spinel",	"object/.png",1,	8,	"green",	1,	10, 1, 20,
	{ combat_def=2 },
	{ mana=10 },
	100
)
newGem("Citrine",	"object/.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ lite=1 },
	{ range=1 },
	100
)
newGem("Agate",		"object/.png",	1,	8,	"black",	1,	10, 1, 20,
	{ inc_stats = { [Stats.STAT_STR] = 1, [Stats.STAT_DEX] = 1, [Stats.STAT_MAG] = 1, [Stats.STAT_WIL] = 1, [Stats.STAT_CUN] = 1, [Stats.STAT_CON] = 1, } },
	{ power=5 },
	100
)
