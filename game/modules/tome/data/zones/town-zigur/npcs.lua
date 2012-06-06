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

load("/data/general/npcs/all.lua")
load("/data/general/npcs/faeros.lua")
load("/data/general/npcs/gwelgoroth.lua")

local Talents = require("engine.interface.ActorTalents")

-- For the corruptors attack
load("/data/general/npcs/elven-caster.lua", function(e) if e.rarity then e.rarity, e.corruptor_rarity = nil, e.rarity end end)
newEntity{ base = "BASE_NPC_ELVEN_CASTER", define_as = "GRAND_CORRUPTOR",
	name = "Grand Corruptor", color=colors.VIOLET, unique = "Grand Corruptor Zigur",
	desc = [[An Elven corruptor, drawn to these blighted lands.]],
	level_range = {30, nil}, exp_worth = 1,
	rank = 3.5,
	max_vim = 800,
	max_life = resolvers.rngavg(300, 310), life_rating = 18,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(3, "rune"),

	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_DRAIN]=5,
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_BLOOD_SPRAY]=5,
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_BLOOD_BOIL]=5,
		[Talents.T_BLOOD_FURY]=5,
		[Talents.T_BONE_SPEAR]=5,
		[Talents.T_VIRULENT_DISEASE]=5,
		[Talents.T_DARKFIRE]=5,
		[Talents.T_FLAME_OF_URH_ROK]=5,
		[Talents.T_CYST_BURST]=4,
		[Talents.T_BURNING_HEX]=5,
		[Talents.T_WRAITHFORM]=5,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self)
		local q = game.player:hasQuest("anti-antimagic")
		if q then q:corruptor_dies() end
	end,
}

-- For the corruptors defense
load("/data/general/npcs/ziguranth.lua", function(e) if e.rarity then e.rarity, e.ziguranth_rarity = nil, e.rarity end end)
newEntity{ base = "BASE_NPC_ZIGURANTH", define_as = "PROTECTOR_MYSSIL",
	name = "Protector Myssil", color=colors.VIOLET, unique = true,
	desc = [[A Halfling ziguranth, clad in dark steel plates. She is the current leader of Zigur.]],
	female = true, subtype = "halfling",
	level_range = {30, nil}, exp_worth = 1,
	rank = 4,
	size_category = 2,
	stamina_regen = 40,
	max_life = resolvers.rngavg(300, 310), life_rating = 21,
	resolvers.equip{
		{type="weapon", subtype="greatsword", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={arcane=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },

	combat_armor = 5, combat_def = 10,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]=2,
		[Talents.T_WEAPONS_MASTERY]=2,
		[Talents.T_RESOLVE]=5,
		[Talents.T_AURA_OF_SILENCE]=4,
		[Talents.T_ANTIMAGIC_SHIELD]=5,
		[Talents.T_MANA_CLASH]=4,
		[Talents.T_ICE_CLAW]=5,
		[Talents.T_LIGHTNING_SPEED]=5,
		[Talents.T_ICE_BREATH]=5,
		[Talents.T_ICY_SKIN]=5,
		[Talents.T_WAR_HOUND]=5,
		[Talents.T_MINOTAUR]=5,
		[Talents.T_SPIDER]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "myssil",

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, "infusion"),

	on_die = function(self)
		local q = game.player:hasQuest("anti-antimagic")
		if q then q:myssil_dies() end
	end,
}
