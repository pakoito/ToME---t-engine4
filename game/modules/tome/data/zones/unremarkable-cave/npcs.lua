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

load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/snake.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "FILLAREL",
	type = "humanoid", subtype = "elf", unique = true,
	name = "Fillarel Aldaren", faction = "neutral",
	display = "@", color=colors.GOLD,
	desc = [[An elven women. She wears a tight robe decorated with symbols of the sun and the moon and wields a staff.]],
	level_range = {25, 35}, exp_worth = 2,
	max_life = 120, life_rating = 15, fixed_rating = true,
	positive_regen = 10,
	negative_regen = 10,
	rank = 4,
	size_category = 3,
	infravision = 20,
	stats = { str=10, dex=22, cun=25, mag=20, con=12 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", ego_chance=100, autoreq=true},
		{type="armor", subtype="cloth", ego_chance=100, autoreq=true},
	},
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_MOONLIGHT_RAY]=4,
		[Talents.T_STARFALL]=5,
		[Talents.T_SHADOW_BLAST]=3,
		[Talents.T_SEARING_LIGHT]=4,
		[Talents.T_FIREBEAM]=4,
		[Talents.T_SUNBURST]=3,
		[Talents.T_HYMN_OF_SHADOWS]=2,
		[Talents.T_CHANT_OF_FORTITUDE]=2,
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },

	on_added = function(self)
		self.energy.value = game.energy_to_act self:useTalent(self.T_HYMN_OF_SHADOWS)
		self.energy.value = game.energy_to_act self:useTalent(self.T_CHANT_OF_FORTITUDE)
	end,

	seen_by = function(self, who)
		if not self.has_been_seen and who.player then
			local Chat = require("engine.Chat")
			local chat = Chat.new("unremarkable-cave-bosses", self, who)
			chat:invoke()
			self.has_been_seen = true
		end
	end,

	can_talk = "unremarkable-cave-fillarel",
}

newEntity{ define_as = "CORRUPTOR",
	type = "humanoid", subtype = "orc", unique = true,
	name = "Krogar", faction = "neutral",
	display = "@", color=colors.GREEN,
	desc = [[An orc clad in mail armour, he wields a staff and looks menacing.]],
	level_range = {25, 35}, exp_worth = 2,
	max_life = 120, life_rating = 15, fixed_rating = true,
	positive_regen = 10,
	negative_regen = 10,
	rank = 4,
	size_category = 3,
	stats = { str=10, dex=22, cun=25, mag=20, con=12 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", ego_chance=100, autoreq=true},
		{type="armor", subtype="heavy", ego_chance=100, autoreq=true},
	},
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=3,
		[Talents.T_MOONLIGHT_RAY]=4,
		[Talents.T_STARFALL]=5,
		[Talents.T_SHADOW_BLAST]=3,
		[Talents.T_SEARING_LIGHT]=4,
		[Talents.T_FIREBEAM]=4,
		[Talents.T_SUNBURST]=3,
		[Talents.T_HYMN_OF_SHADOWS]=2,
		[Talents.T_CHANT_OF_FORTITUDE]=2,
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },

	can_talk = "unremarkable-cave-krogar",
}
