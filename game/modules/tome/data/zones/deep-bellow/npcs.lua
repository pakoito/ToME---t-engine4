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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/horror-corrupted.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "THE_MOUTH",
	unique = true,
	name = "The Mouth", tint=colors.PURPLE,
	color=colors.VIOLET,
	desc = [["From bellow, it devours."]],
	killer_message = "and revived as a screeching drem bat",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_the_mouth.png", display_h=2, display_y=-1}}},
	level_range = {7, nil}, exp_worth = 2,
	max_life = 10000, life_rating = 0, fixed_rating = true,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	never_move = 1,

	-- Bad idea to melee it
	combat = {dam=100, atk=1000, apr=1000, physcrit=1000},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="TOOTH_MOUTH", random_art_replace={chance=35}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL]=1,
		[Talents.T_DRAIN]=1,
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1 },
	ai_tactic = resolvers.tactic"ranged",

	on_takehit = function(self, value)
		if value <= 500 then
			game.logSeen(self, "#CRIMSON#%s seems invulnerable, there must be an other way to kill it!", self.name:capitalize())
			return 0
		end
		return value
	end,

	-- Invoke crawlers every few turns
	on_act = function(self)
		if not self.ai_target.actor or self.ai_target.actor.dead then return end
		if not self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then return end

		self.last_crawler = self.last_crawler or (game.turn - 100)
		if game.turn - self.last_crawler >= 100 then -- Summon a crawler every 10 turns
			self:forceUseTalent(self.T_GIFT_OF_AMAKTHEL, {no_energy=true})
			self.last_crawler = game.turn
		end
	end,

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("deep-bellow", engine.Quest.COMPLETED)
		game.state:activateBackupGuardian("ABOMINATION", 3, 35, "I have heard a dwarf whispering about some abomination in the deep bellow.")
	end,
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "SLIMY_CRAWLER",
	name = "slimy crawler",
	color = colors.GREEN,
	desc = [[This disgusting... thing crawls on the floor toward you with great speed.
It seems to come from the digestive system of the mouth.]],
	level_range = {4, nil}, exp_worth = 0,
	max_life = 80, life_rating = 10, fixed_rating = true,
	movement_speed = 3,
	size_category = 1,

	combat = { dam=resolvers.mbonus(25, 15), damtype=DamageType.SLIME, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar" },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=1,
	},

	on_act = function(self)
		local tgts = {}
		for i, actor in ipairs(game.party.m_list) do
			if not actor.dead then tgts[#tgts+1] = actor end
		end
		self:setTarget(rng.table(tgts))

		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#With the Mouth death its crawler also falls lifeless on the ground!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead then
			game.logSeen(self, "#AQUAMARINE#As %s falls you notice that %s seems to shudder in pain!", self.name, self.summoner.name)
			self.summoner.no_take_hit_achievements = true
			self.summoner:takeHit(1000, who)
			self.summoner.no_take_hit_achievements = nil
		end
	end,
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "ABOMINATION",
	unique = true,
	allow_infinite_dungeon = true,
	name = "The Abomination",
	display = "h", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_the_abomination.png", display_h=2, display_y=-1}}},
	desc = [[A horrid mass of pustulent flesh, sinew, and bone; this creature seems to constantly be in pain. Two heads glare malevolently at you, an intruder in its domain.]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 350, life_rating = 23, fixed_rating = true,
	life_regen = 30,
	hate_regen = 100,
	negative_regen = 14,
	stats = { str=30, dex=8, cun=10, mag=15, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 30,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1 },
	resolvers.equip{
		{type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="boots", defined="WARPED_BOOTS", random_art_replace={chance=75}, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ADV_LTR_8"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},

		[Talents.T_GLOOM]={base=4, every=7, max=6},
		[Talents.T_WEAKNESS]={base=4, every=7, max=6},
		[Talents.T_DISMAY]={base=4, every=7, max=6},

		[Talents.T_HYMN_OF_MOONLIGHT]={base=3, every=7, max=5},
		[Talents.T_STARFALL]={base=3, every=7, max=7},
		[Talents.T_SHADOW_BLAST]={base=3, every=7, max=7},
	},
	resolvers.sustains_at_birth(),

	-- Supposed to drop two notes during the fight, if player has cooldowns to worry about player can snag these then.
	on_takehit = function(self, val)
		if self.life - val < self.max_life * 0.75 and not self.dropped_note6 then
			local n = game.zone:makeEntityByName(game.level, "object", "ADV_LTR_6")
			if n then
				self.dropped_note6 = true
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "A parchment falls to the floor near The Abomination.")
			end
		end
		if self.life - val < self.max_life * 0.25 and not self.dropped_note7 then
			local n = game.zone:makeEntityByName(game.level, "object", "ADV_LTR_7")
			if n then
				self.dropped_note7 = true
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "A parchment falls to the floor near The Abomination.")
			end
		end
		return val
	end,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),
}
