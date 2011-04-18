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
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/canine.lua", rarity(0))
load("/data/general/npcs/troll.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/swarm.lua", rarity(3))
load("/data/general/npcs/bear.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "TROLL_PROX",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Prox the Mighty",
	display = "T", color=colors.VIOLET, image="npc/troll_bill.png",
	desc = [[A huge troll, he might move slowly but he does look dangerous nonetheless.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=1,
	},
	resolvers.inscriptions(1, {"movement infusion"}),
	inc_damage = { all = -40 },

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	-- Drop the note when near death (but before death, so that Kill bill achievement is possible)
	on_takehit = function(self, val)
		if self.life - val < self.max_life * 0.4 then
			local n = game.zone:makeEntityByName(game.level, "object", "PROX_NOTE")
			if n then
				self.on_takehit = nil
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "Prox staggers for a moment. A note seems to drop at his feet.")
			end
		end
		return val
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("ALUIN", 2, 35, "... and we thought the trollmire was safer now!")
		game.player:resolveSource():grantQuest("start-allied")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "trollmire")
	end,
}

newEntity{ define_as = "TROLL_BILL",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Bill the Stone Troll",
	display = "T", color=colors.VIOLET, image="npc/troll_bill.png",
	desc = [[Big, brawny, powerful and with a taste for Halfling.
He is wielding a small tree trunk and lumbering toward you.
This is the troll the notes spoke about, no doubt.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 250, life_rating = 18, fixed_rating = true,
	max_stamina = 85,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", defined="GREATMAUL_BILL_TRUNK", random_art_replace={chance=75}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_RUSH]=4,
		[Talents.T_KNOCKBACK]=3,
	},
	resolvers.inscriptions(1, {"wild infusion", "heroism infusion"}),

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():grantQuest("trollmire-treasure")
		if who and who.level and who.level == 1 then
			world:gainAchievement("KILL_BILL", game.player)
		end
	end,
}

newEntity{ define_as = "ALUIN",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Aluin the Fallen",
	display = "p", color=colors.VIOLET,
	desc = [[His once shining armour now dull and bloodstained, this Sun Paladin has given in to despair.]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 350, life_rating = 23, fixed_rating = true,
	hate_regen = 10,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 20,
	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 30,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", defined="SANGUINE_SHIELD", random_art_replace={chance=65}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]={base=5, every=5, max=10},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=5, max=10},
		[Talents.T_RUSH]={base=4, every=7, max=6},

		[Talents.T_ENRAGE]={base=3, every=7, max=5},
		[Talents.T_SUPPRESSION]={base=4, every=7, max=6},
		[Talents.T_BLINDSIDE]={base=4, every=7, max=6},
		[Talents.T_GLOOM]={base=4, every=7, max=6},
		[Talents.T_WEAKNESS]={base=4, every=7, max=6},
		[Talents.T_TORMENT]={base=4, every=7, max=6},
		[Talents.T_LIFE_LEECH]={base=4, every=7, max=6},

		[Talents.T_CHANT_OF_LIGHT]={base=5, every=7, max=7},
		[Talents.T_SEARING_LIGHT]={base=5, every=7, max=7},
		[Talents.T_MARTYRDOM]={base=5, every=7, max=7},
		[Talents.T_BARRIER]={base=5, every=7, max=7},
		[Talents.T_WEAPON_OF_LIGHT]={base=5, every=7, max=7},
		[Talents.T_CRUSADE]={base=8, every=7, max=10},
		[Talents.T_FIREBEAM]={base=7, every=7, max=9},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),
}
