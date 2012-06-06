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

load("/data/general/npcs/all.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_SKELETON", define_as = "TUTORIAL_NPC_MAGE", image="npc/skeleton_mage.png",
	name = "skeleton mage", color=colors.LIGHT_RED,
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_MANATHRUST]=3 },

	resolvers.equip{ {type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_TROLL", define_as = "TUTORIAL_NPC_TROLL",
	name = "half-dead forest troll", color=colors.YELLOW_GREEN,
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.
He looks hurt.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(10,20),
	combat_armor = 3, combat_def = 0,
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "TUTORIAL_NPC_LONE_WOLF",
	name = "Lone Wolf", color=colors.VIOLET, unique=true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_canine_lone_wolf.png", display_h=2, display_y=-1}}},
	desc = [[It is a large wolf with eyes full of cunning, only 3 times bigger than a normal wolf. It looks hungry. You look tasty!]],
	level_range = {3, nil}, exp_worth = 2,
	rank = 4,
	size_category = 4,
	max_life = 220,
	combat_armor = 8, combat_def = 0,
	combat = { dam=20, atk=15, apr=4 },

	stats = { str=25, dex=20, cun=15, mag=10, con=15 },

	resolvers.talents{
		[Talents.T_GLOOM]=1,
		[Talents.T_RUSH]=1,
		[Talents.T_CRIPPLE]=1,
	},
	resolvers.sustains_at_birth(),

	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("tutorial", engine.Quest.COMPLETED)
		local d = require("engine.dialogs.ShowText").new("Tutorial: Finish", "tutorial/done")
		game:registerDialog(d)
	end,
}
