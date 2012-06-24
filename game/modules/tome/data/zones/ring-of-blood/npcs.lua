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

load("/data/general/npcs/all.lua", function(e) e.slaver_rarity, e.rarity = e.rarity, nil end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "RING_MASTER",
	type = "humanoid", subtype = "yaech", unique = true,
	name = "Blood Master",
	display = "@", color=colors.VIOLET,
	blood_color = colors.BLUE,
	desc = [[This small humanoid is covered in silky white fur. Its bulging eyes stare deep into your mind.]],
	level_range = {14, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	rank = 3.5,
	size_category = 2,
	infravision = 10,
	stats = { str=16, dex=12, cun=14, wil=25, con=16 },
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
		game.player:setQuestStatus("ring-of-blood", engine.Quest.COMPLETED)
	end,

	faction = "slavers",
	can_talk = "ring-of-blood-master",
}


----------------------------------- Spectators
newEntity{ define_as = "SPECTATOR",
	type = "humanoid", subtype = resolvers.rngtable{"shalore","thalore","human","halfling","dwarf"},
	name = "spectator", quest = true,
	female = resolvers.rngtable{false, true},
	image = resolvers.rngtable{"npc/humanoid_human_spectator.png","npc/humanoid_human_spectator02.png","npc/humanoid_human_spectator03.png",},
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
	desc = [[This humanoid has been enslaved by the yaech's mental powers.]],
	level_range = {9, 9}, exp_worth = 0,
	max_life = 120, life_rating = 12, fixed_rating = true,
	rank = 3,
	lite = 3,
	stats = { str=18, dex=18, cun=18, mag=10, con=16 },
	instakill_immune = 1,
	move_others=true,
	suppress_alchemist_drops = true,

	body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1 },
	resolvers.equip{
		{type="armor", subtype="hands", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_EMPTY_HAND] = 1,
		[Talents.T_DOUBLE_STRIKE] = 4,
		[Talents.T_BODY_SHOT] = 3,
		[Talents.T_SPINNING_BACKHAND] = 1,
		[Talents.T_STRIKING_STANCE] = 1,
		[Talents.T_UPPERCUT] = 3,
		[Talents.T_RELENTLESS_STRIKES] = 3,
		[Talents.T_CLINCH] = 2,
		[Talents.T_MAIM] = 2,
		[Talents.T_UNARMED_MASTERY] = 2,
		[Talents.T_WEAPON_COMBAT] = 2,
		[Talents.T_ARMOUR_TRAINING]=3,
	},

	resolvers.inscriptions(2, {"regeneration infusion","healing infusion"}, nil, true),

	autolevel = "warrior",

	faction = "neutral",
}


-------------------------------------- NPCs

newEntity{
	define_as = "BASE_NPC_SLAVER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.DARK_KHAKI,
--	faction = "slavers",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=3, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_SLAVER",
	name = "slaver", color=colors.TEAL,
	subtype = "yaech",
	desc = [[A slaver.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_MANATHRUST]={base=3, every=5, max=6},
		[Talents.T_FLAME]={base=3, every=5, max=6},
		[Talents.T_LIGHTNING]={base=3, every=5, max=6},
		[Talents.T_FLAMESHOCK]={base=3, every=5, max=6},
	},

	make_escort = {
		{type="humanoid", subtype="human", name="enthralled slave", number=2, post=function(self, m)
			m.master = self
			m.on_act = function(self)
				if self.master and self.master:attr("dead") then
					self.faction = "neutral"
					self:doEmote(rng.table{"I am free!", "At last, freedom!", "Thanks for this!", "The mental hold is gone!"}, 60)
					self.on_act = nil
					self.master = nil
					world:gainAchievement("RING_BLOOD_FREED", game:getPlayer(true))
				end
			end
		end},
	}
}

newEntity{ base = "BASE_NPC_SLAVER",
	name = "enthralled slave", color=colors.KHAKI,
	subtype = "human",
	desc = [[A slave.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 20,
	max_life = resolvers.rngavg(80,90), life_rating = 13,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="armor", subtype="hands", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_DOUBLE_STRIKE] = {base=3, every=5, max=6},
		[Talents.T_UPPERCUT] = {base=3, every=5, max=6},
		[Talents.T_EMPTY_HAND] = 1,
		[Talents.T_CLINCH] = {base=3, every=5, max=6},
		[Talents.T_MAIM] = {base=3, every=5, max=6},
		[Talents.T_UNARMED_MASTERY] = {base=2, every=6, max=4},
		[Talents.T_WEAPON_COMBAT] = {base=2, every=6, max=4},
	},
}
