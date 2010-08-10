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
load("/data/general/npcs/naga.lua", rarity(6))
--[[
-- Orcs & trolls
load("/data/general/npcs/orc-grushnak.lua", rarity(0))
load("/data/general/npcs/orc-vor.lua", rarity(0))
load("/data/general/npcs/orc-rak-shor.lua", rarity(0))
load("/data/general/npcs/orc.lua", rarity(8))
--load("/data/general/npcs/troll.lua", rarity(0))

-- Others
load("/data/general/npcs/naga.lua", rarity(6))
load("/data/general/npcs/snow-giant.lua", rarity(0))

-- Drakes
load("/data/general/npcs/fire-drake.lua", rarity(10))
load("/data/general/npcs/cold-drake.lua", rarity(10))
load("/data/general/npcs/multihued-drake.lua", rarity(10))

-- Undeads
load("/data/general/npcs/bone-giant.lua", rarity(3))
load("/data/general/npcs/vampire.lua", rarity(5))
load("/data/general/npcs/ghoul.lua", rarity(2))
load("/data/general/npcs/skeleton.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))
]]
local Talents = require("engine.interface.ActorTalents")

-- Alatar & Palando, the final bosses
newEntity{
	define_as = "ALATAR",
	type = "humanoid", subtype = "istari",
	name = "Alatar the Blue",
	display = "@", color=colors.AQUAMARINE,
	faction = "blue-wizards",

	desc = [[Lost to the memory of the West, the Blue Wizards have setup in the Far East, slowly growing corrupt. Now they must be stopped.]],
	level_range = {75, 75}, exp_worth = 15,
	max_life = 1000, life_rating = 36, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, cun=60, mag=30, con=40 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", ego_chance=100, autoreq=true},
		{type="armor", subtype="cloth", ego_chance=100, autoreq=true},
	},
	resolvers.drops{chance=100, nb=10, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_FLAME]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_LIGHTNING]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_STONE_SKIN]=5,
		[Talents.T_STRIKE]=5,
		[Talents.T_HEAL]=5,
		[Talents.T_REGENERATION]=5,
		[Talents.T_ILLUMINATE]=5,
		[Talents.T_QUICKEN_SPELLS]=5,
		[Talents.T_SPELL_SHAPING]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_METAFLOW]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },
}

newEntity{
	define_as = "PALLANDO",
	type = "humanoid", subtype = "istari",
	name = "Pallando the Blue",
	display = "@", color=colors.LIGHT_BLUE,
	faction = "blue-wizards",

	desc = [[Lost to the memory of the West, the Blue Wizards have setup in the Far East, slowly growing corrupt. Now they must be stopped.]],
	level_range = {75, 75}, exp_worth = 15,
	max_life = 1000, life_rating = 36, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, cun=60, mag=30, con=40 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", ego_chance=100, autoreq=true},
		{type="armor", subtype="cloth", ego_chance=100, autoreq=true},
	},
	resolvers.drops{chance=100, nb=10, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_FLAME]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_LIGHTNING]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_STONE_SKIN]=5,
		[Talents.T_STRIKE]=5,
		[Talents.T_HEAL]=5,
		[Talents.T_REGENERATION]=5,
		[Talents.T_ILLUMINATE]=5,
		[Talents.T_QUICKEN_SPELLS]=5,
		[Talents.T_SPELL_SHAPING]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_METAFLOW]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },
}
