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

local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/orc.lua", rarity(40))

load("/data/general/npcs/feline.lua", function(m)
	m.level_range = {1,1}
	m.max_life = 30
	for i, e in ipairs(m) do
		if type(e) == "table" and e.__resolver == "talents" then
			local nt = {}
			for tid, d in pairs(e[1]) do
				if tid == m.T_RUSH then nt[m.T_NIMBLE_MOVEMENTS] = d
				else nt[tid] = d
				end
			end
			e[1] = nt
		end
	end
end)

newEntity{
	define_as = "ILLUSION_YEEK",
	type = "humanoid", subtype = "yeek",
	name = "yeek illusion",
	image = resolvers.rngtable{
		"npc/humanoid_yeek_yeek_commoner_01.png",
		"npc/humanoid_yeek_yeek_commoner_02.png",
		"npc/humanoid_yeek_yeek_commoner_03.png",
		"npc/humanoid_yeek_yeek_commoner_04.png",
		"npc/humanoid_yeek_yeek_commoner_05.png",
		"npc/humanoid_yeek_yeek_commoner_06.png",
		"npc/humanoid_yeek_yeek_commoner_07.png",
		"npc/humanoid_yeek_yeek_commoner_08.png",
	},
	display = "p", color=colors.WHITE,
	desc = [[What?!]],
	faction = "neutral",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, PSIONIC_FOCUS=1 },
	lite = 3,

	life_rating = 10, max_life = 15,
	emote_random = {chance=10, "Who are you?", "What do you want?", "Why are you here?", "Where are you going?", "Do you have anything worth living for?"},
	level_range = {1, 1}, exp_worth = 1,
	rarity = 1,

	on_bump = function(self, who)
		local x, y = self.x, self.y
		game.level.map:particleEmitter(self.x, self.y, 1, "blood")
		self:die(self)
	end,
	on_die = function(self)
		local m
		if self.is_wife then
			m = game.zone.npc_list.WIFE
		else
			local list = require("mod.class.NPC"):loadList("/data/general/npcs/ghoul.lua")
			m = list.GHOUL:clone()
		end
		if m then
			m:resolve()
			m:resolve(nil, true)
			m.exp_worth = 0
			m.inc_damage.all = -50
			m.life = 30
			game.zone:addEntity(game.level, m, "actor", self.x, self.y)
			m:doEmote("GRrrrrrllllll!", 60)
		end
	end,
}

newEntity{ base = "BASE_NPC_ORC", define_as = "WIFE",
	name = "lost wife", color=colors.YELLOW,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_mother.png", display_h=2, display_y=-1}}},
	desc = [[Your wife has been turned into a giant, bloated form that towers above you. Mucus and slime ooze from every orifice, dripping onto the floor. The sight and the smell make you retch.]],
	level_range = {10, 10}, exp_worth = 0,
	female = true,
	never_move = 1,
	stun_immune = 1,
	size_category = 4,
	faction = "enemies",
	subtype = "bloated horror",

	max_life = 400, life_rating = 0, life_regen = 0,
	rank = 3,

	on_melee_hit = {[DamageType.BLIGHT] = 5},

	combat_armor = 10, combat_def = 0,
	resolvers.talents{
		[Talents.T_SLIME_SPIT]=1,
	},

	on_die = function(self)
		local g = game.zone.grid_list.DREAM2_END:clone()
		game.zone:addEntity(game.level, g, "terrain", self.x, self.y)
	end
}
