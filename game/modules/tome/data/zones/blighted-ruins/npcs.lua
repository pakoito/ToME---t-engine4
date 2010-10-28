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

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/ghoul.lua", rarity(3))
load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/bone-giant.lua", function(e) e.rarity = nil end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "NECROMANCER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.DARK_GREY,
	name = "Necromancer", color=colors.DARK_GREY,
	desc = [[An human dressed in black robes. He mumbles is a harsh tongue. He seems to think you are his slave.]],
	level_range = {1, nil}, exp_worth = 1,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	rank = 2,
	size_category = 2,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	energy = { mod=1 },
	stats = { str=10, dex=8, mag=16, con=6 },

	max_life = resolvers.rngavg(70,80), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloak", defined="CLOAK_DECEPTION", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=1,
	},

	die = function(self, src)
		self.die = function() end
		local Chat = require "engine.Chat"
		local chat = Chat.new("undead-start-kill", self, game.player)
		chat:invoke()
	end,
}

newEntity{
	define_as = "NECROMANCER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.DARK_GREY,
	name = "Necromancer", color=colors.DARK_GREY,
	desc = [[An human dressed in black robes. He mumbles is a harsh tongue. He seems to think you are his slave.]],
	level_range = {1, nil}, exp_worth = 1,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	rank = 2,
	size_category = 2,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	energy = { mod=1 },
	stats = { str=10, dex=8, mag=16, con=6 },

	max_life = resolvers.rngavg(70,80), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloak", defined="CLOAK_DECEPTION", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=1,
	},

	die = function(self, src)
		self.die = function() end
		local Chat = require "engine.Chat"
		local chat = Chat.new("undead-start-kill", self, game.player)
		chat:invoke()
	end,
}

newEntity{ base = "BASE_NPC_BONE_GIANT", define_as = "HALF_BONE_GIANT",
	name = "Half-Finished Bone Giant", color=colors.VIOLET, unique=true,
	desc = [[A towering creature, made from the bones of hundreds of dead bodies. It is covered by an unholy aura.
This specimen look like it was hastily assembled and is not really complete yet.]],
	level_range = {7, nil}, exp_worth = 1,
	rank = 4,
	max_life = resolvers.rngavg(100,120), life_rating = 14,
	combat_armor = 7, combat_def = 7,
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(5, 2)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(5, 2)},
	resolvers.talents{ [Talents.T_BONE_ARMOUR]=3, [Talents.T_THROW_BONES]=1, [Talents.T_STUN]=1, },
	resolvers.sustains_at_birth(),

	resolvers.drops{chance=100, nb=3, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="UNDEATH_PHIAL"} },

	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-undead", engine.Quest.COMPLETED)
	end,
}
