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
load("/data/general/npcs/horror-corrupted.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "THE_MOUTH",
	unique = true,
	name = "The Mouth", tint=colors.PURPLE, image = "npc/the_mouth.png",
	color=colors.VIOLET,
	desc = [["From bellow, it devours."]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 10000, life_rating = 0, fixed_rating = true,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	instakill_immune = 1,
	never_move = true,

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
	end,
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "SLIMY_CRAWLER",
	name = "slimy crawlyer",
	color = colors.GREEN,
	desc = [[This disgusting... thing crawls on the floor toward you with great speed.
It seems to come from the digestive system of the mouth.]],
	level_range = {4, nil}, exp_worth = 0,
	max_life = 80, life_rating = 10, fixed_rating = true,
	movement_speed = 0.2,
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
			self.summoner:takeHit(1000, who)
		end
	end,
}
