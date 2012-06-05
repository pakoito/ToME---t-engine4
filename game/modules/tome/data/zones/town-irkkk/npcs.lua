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

load("/data/general/npcs/gwelgoroth.lua", function(e) if e.rarity then e.derth_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_IRKKK_TOWN",
	type = "humanoid", subtype = "yeek",
	display = "p", color=colors.WHITE,
	faction = "the-way",
	anger_emote = "Catch @himher@!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, PSIONIC_FOCUS=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=7, dex=8, mag=6, wil=15, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN",
	name = "yeek mindslayer", color=colors.LIGHT_UMBER,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_yeek_yeek_mindslayer.png", display_h=2, display_y=-1}}},
	desc = [[A mindslayer in training.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{
		[Talents.T_KINETIC_AURA]={base=1, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN",
	name = "yeek psionic", color=colors.YELLOW,
	desc = [[You can literaly feel the mental energies emited by this yeek.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
}

-------------------------------- Stores
newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_GEM",
	name = "gem crafter", color=colors.BLUE, image = "npc/humanoid_yeek_yeek_psionic.png",
	desc = [[This yeek has all sorts of gems to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("GEMSTORE"),
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_2HANDS",
	name = "two hander weapons crafter", color=colors.UMBER, image = "npc/humanoid_yeek_yeek_commoner_06.png",
	desc = [[This yeek has all sorts of two handed weapons to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("TWO_HANDS_WEAPON"),
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_1HAND",
	name = "one hander weapons crafter", color=colors.UMBER, image = "npc/humanoid_yeek_yeek_commoner_08.png",
	desc = [[This yeek has all sorts of one handed weapons to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("ONE_HAND_WEAPON"),
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_CLOTH",
	name = "tailor", color=colors.BLUE, image = "npc/humanoid_yeek_yeek_commoner_04.png",
	desc = [[This yeek has all sorts of cloth to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("CLOTH_ARMOR"),
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_LEATHER",
	name = "tanner", color=colors.BLUE, image = "npc/humanoid_yeek_yeek_commoner_07.png",
	desc = [[This yeek has all sorts of leathers to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("LIGHT_ARMOR"),
}

newEntity{ base = "BASE_NPC_IRKKK_TOWN", define_as = "YEEK_STORE_NATURE",
	name = "natural infusions", color=colors.BLUE, image = "npc/humanoid_yeek_yeek_summoner.png",
	desc = [[This yeek has all sorts of infusions to sell.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="gem"},
	},
	resolvers.talents{
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
		[Talents.T_PYROKINESIS]={base=1, every=7, max=5},
		[Talents.T_REACH]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
	},
	resolvers.store("POTION"),
}
