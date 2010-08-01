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

load("/data/general/npcs/aquatic_critter.lua", rarity(0))
load("/data/general/npcs/aquatic_demon.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "MAGLOR",
	type = "humanoid", subtype = "naga", unique = true,
	name = "Maglor, Last Son of Fëanor the Maker",
	faction="silmaril-guardians",
	display = "@", color=colors.VIOLET,
	desc = [[Maglor elven body was wrapped by thousands of years under the water, gills have grown on his neck, palms have formed between his fingers.
The most horrible thing though is his legs, they have fused into a snake tail, granting him fast movement underwater.
He wears a mace and a shield.]],
	energy = {mod = 1.7},
	level_range = {30, 50}, exp_worth = 4,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_stamina = 85,
	stats = { str=25, dex=10, cun=40, mag=50, con=50 },
	rank = 4,
	size_category = 3,
	can_breath={water=1},
	infravision = 20,
	move_others=true,

	instakill_immune = 1,
	teleport_immune = 1,
	confusion_immune= 1,
	combat_spellresist = 25,
	combat_mentalresist = 25,
	combat_physresist = 30,

	resists = { [DamageType.COLD] = 60, [DamageType.ACID] = 20, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
		{type="armor", subtype="heavy", ego_chance=100, autoreq=true},
		{type="jewelry", subtype="lite", defined="WATER_SILMARIL", autoreq=true},
	},
	drops = resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_MACE_MASTERY]=6,
		[Talents.T_SHIELD_EXPERTISE]=3,
		[Talents.T_SHIELD_PUMMEL]=2,
		[Talents.T_RIPOSTE]=5,
		[Talents.T_BLINDING_SPEED]=3,
		[Talents.T_PERFECT_STRIKE]=5,

		[Talents.T_SPIT_POISON]=5,

		[Talents.T_HEAL]=5,
		[Talents.T_UTTERCOLD]=5,
		[Talents.T_ICE_SHARDS]=5,
		[Talents.T_FREEZE]=3,
		[Talents.T_TIDAL_WAVE]=5,
		[Talents.T_ICE_STORM]=5,
		[Talents.T_WATER_BOLT]=5,

		[Talents.T_MIND_DISRUPTION]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("maglor", engine.Quest.COMPLETED, "kill-maglor")
		game.player:resolveSource():hasQuest("maglor"):portal_back()
	end,

	can_talk = "maglor",
}
