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

load("/data/general/npcs/ghost.lua", rarity(5))
load("/data/general/npcs/major-demon.lua", rarity(2))
load("/data/general/npcs/minor-demon.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "DRAEBOR",
	allow_infinite_dungeon = true,
	type = "demon", subtype = "minor", unique = true,
	name = "Draebor, the Imp",
	display = "u", color=colors.VIOLET,
	desc = [[An intensely irritating git of a monster.]],
	faction = "fearscape",
	level_range = {35, nil}, exp_worth = 3,
	max_life = 300, life_rating = 22, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 30,

	mana_regen = 100,
	life_regen = 10,
	stats = { str=20, dex=15, cun=35, mag=25, con=20 },
	poison_immune = 1,
	stun_immune = 1,
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,
	demon = 1,

	on_melee_hit = { [DamageType.FIRE] = 15, },
	resists = { [DamageType.FIRE] = 50, [DamageType.DARKNESS] = 50, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="BOOTS_OF_PHASING"} },

	summon = {
		{type="demon", number=1, hasxp=false},
	},

	talent_cd_reduction={[Talents.T_FLAME]=2, [Talents.T_BLOOD_GRASP]=4, [Talents.T_PHASE_DOOR]=3, [Talents.T_SUMMON]=-10, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_FLAME]={base=5, every=5, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max=8},
		[Talents.T_WILDFIRE]={base=5, every=5, max=8},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=5, max=8},
		[Talents.T_BONE_SHIELD]={base=3, every=10, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, who)
		require("engine.ui.Dialog"):simplePopup("Back and there again", "As the annoying imp falls a portal appears under its corpse.")
		local g = game.zone:makeEntityByName(game.level, "terrain", "PORTAL_BACK")
		game.zone:addEntity(game.level, g, "terrain", self.x, self.y)
	end,
}
