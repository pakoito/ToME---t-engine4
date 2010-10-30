-- ToME - Tales of Maj'Eyal
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

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SUPREME_ARCHMAGE_LINANIIL",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "angolwen",
	name = "Linaniil, Supreme Archmage of Angolwen", color=colors.VIOLET, unique = true,
	desc = [[A tall, pale, woman dressed in a revealing silk robe. Her gaze is so intense it seems to burn.]],
	level_range = {50, 50}, exp_worth = 2,
	rank = 4,
	size_category = 3,
	female = true,
	mana_regen = 90,
	max_mana = 20000,
	max_life = 250, life_rating = 22, fixed_rating = true,
	infravision = 20,
	stats = { str=10, dex=15, cun=42, mag=26, con=14 },
	instakill_immune = 1,
	teleport_immune = 1,
	move_others=true,
	combat_spellpower = 30,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resists = {[DamageType.FIRE]=100, [DamageType.LIGHTNING]=100},

	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_WILDFIRE]=5,
		[Talents.T_FLAME]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_DANCING_FIRES]=5,
		[Talents.T_COMBUST]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_DISRUPTION_SHIELD]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_SHOCK]=5,
		[Talents.T_TEMPEST]=5,
		[Talents.T_HURRICANE]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_TELEPORT]=5,
		[Talents.T_KEEN_SENSES]=5,
		[Talents.T_PREMONITION]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "angolwen-leader",
}
