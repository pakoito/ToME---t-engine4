-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/molds.lua", rarity(5))
load("/data/general/npcs/elven-warrior.lua", rarity(0))
load("/data/general/npcs/elven-caster.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "RING_MASTER",
	type = "humanoid", subtype = "yaech", unique = true,
	name = "Blood Master",
	display = "@", color=colors.VIOLET,
	blood_color = colors.BLUE,
	desc = [[This small humanoid is covered in silky white fur. Its buldging eyes stares deep into your mind.]],
	level_range = {14, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	rank = 3.5,
	size_category = 2,
	infravision = 20,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	move_others=true,
	psi_regen = 4,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, PSIONIC_FOCUS = 1, QS_PSIONIC_FOCUS = 1 },
	resolvers.equip{ {type="weapon", subtype="greatsword", auto_req=true}, {type="armor", subtype="light", autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.inventory{ inven="PSIONIC_FOCUS",
		{type="weapon", subtype="greatsword", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_UNITY]={base=7, every=4, max=10},
		[Talents.T_QUICKENED]={base=3, every=2, max=6},
		[Talents.T_WAYIST]={base=3, every=4, max=5},
		[Talents.T_MINDHOOK]={base=3, every=7, max=5},
		[Talents.T_TELEKINETIC_LEAP]={base=3, every=7, max=5},
		[Talents.T_KINETIC_AURA]={base=3, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=3, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=3, every=7, max=5},
		[Talents.T_KINETIC_LEECH]={base=5, every=7, max=7},
		[Talents.T_TELEKINETIC_SMASH]={base=5, every=7, max=8},
		[Talents.T_AUGMENTATION]={base=3, every=7, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=3, max=10},
		[Talents.T_WEAPON_COMBAT]={base=4, every=3, max=10},
	},

	resolvers.inscriptions(2, {"shielding rune", "speed rune"}),

	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:setQuestStatus("ring-of-blood", engine.Quest.COMPLETED, "killall")
	end,

	faction = "slavers",
	can_talk = "ring-of-blood-master",
}


----------------------------------- Spectators
newEntity{ define_as = "SPECTATOR",
	type = "humanoid", subtype = resolvers.rngtable{"shalore","thalore","human","halfling","dwarf"},
	name = "spectator",
	female = resolvers.rngtable{false, true},
	display = "p", resolvers.rngcolor{colors.BLUE, colors.LIGHT_BLUE, colors.RED, colors.LIGHT_RED, colors.ORANGE, colors.YELLOW, colors.GREEN, colors.LIGHT_GREEN, colors.PINK, },
	desc = [[A spectator, who probably paid a lot to watch this bloody "game".]],
	level_range = {1, nil}, exp_worth = 0,
	max_life = 100, life_rating = 12,
	faction = "neutral",
	emote_random = resolvers.emote_random{
		"Blood!", "Fight!", "To the death!",
		"Oh this is great", "I love the smell of death...",
		"Slavers forever!",
	},
}

----------------------------------- Player's slave

newEntity{ define_as = "PLAYER_SLAVE",
	type = "humanoid", subtype = "human",
	name = "slave combatant",
	display = "@", color=colors.UMBER,
	desc = [[This ]],
	level_range = {9, 9}, exp_worth = 0,
	max_life = 120, life_rating = 12, fixed_rating = true,
	rank = 3,
	lite = 3,
	stats = { str=18, dex=18, cun=18, mag=10, con=16 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, MOUNT = 1 },
	resolvers.equip{ {type="armor", subtype="light", auto_req=true} },

	resolvers.talents{
		[Talents.T_STRIKING_STANCE] = 1,
		[Talents.T_DOUBLE_STRIKE] = 4,
		[Talents.T_BODY_SHOT] = 3,
		[Talents.T_RUSHING_STRIKE] = 1,
		[Talents.T_STRIKING_STANCE] = 1,
		[Talents.T_UPPERCUT] = 3,
		[Talents.T_RELENTLESS_STRIKES] = 1,
		[Talents.T_CLINCH] = 2,
		[Talents.T_MAIM] = 2,
		[Talents.T_UNARMED_MASTERY] = 4,
		[Talents.T_WEAPON_COMBAT] = 4,
	},

	resolvers.inscriptions(1, {"regeneration infusion"}),

	autolevel = "warrior",

	faction = "slavers",
}
