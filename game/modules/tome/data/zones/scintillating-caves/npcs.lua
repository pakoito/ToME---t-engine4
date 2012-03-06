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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/bear.lua", rarity(2))
load("/data/general/npcs/crystal.lua", rarity(1))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CRYSTAL", define_as = "SPELLBLAZE_CRYSTAL",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Spellblaze Crystal", tint=colors.PURPLE, image = "npc/spellblaze_crystal.png",
	color=colors.VIOLET,
	desc = [[A formation of purple crystal. It seems strangely aware.]],
	killer_message = "and vaporised into nothingness",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	mana_regen = 3,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="CRYSTAL_FOCUS", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=1,
		[Talents.T_ICE_SHARDS]=1,
		[Talents.T_SOUL_ROT]=1,
		[Talents.T_ELEMENTAL_BOLT]=1,
	},
	resolvers.inscriptions(1, {"manasurge rune"}),
	inc_damage = { all = -35 },

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-shaloren", engine.Quest.COMPLETED, "spellblaze")
		game.state:activateBackupGuardian("SPELLBLAZE_SIMULACRUM", 3, 35, "I heard that some old crystals are nearly alive now in the scintillating caves.")
	end,
}

newEntity{ base="BASE_NPC_CRYSTAL", define_as = "SPELLBLAZE_SIMULACRUM",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Spellblaze Simulacrum", display = "g", image = "npc/spellblaze_simulacrum.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spellblaze_simulacrum.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET,
	desc = [[A formation of purple crystal, but where the others could only be described as polyhedral, this construct seems to strangely resemble... you, if you were several orders of magnitude larger.]],
	killer_message = "and vaporised into nothingness",
	level_range = {35, nil}, exp_worth = 3,
	max_life = 300, life_rating = 25, fixed_rating = true,
	life_regen = 0,
	mana_regen = 20,
	stats = { str=15, dex=15, cun=20, mag=35, con=15 },
	rank = 4,
	size_category = 5,
	infravision = 10,
	see_invisible = 10,
	blind_immune = 1,
	poison_immune = 1,
	disease_immune = 1,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="CRYSTAL_HEART", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	inc_damage = { all=70 },
	resolvers.talents{
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_FLAME]={base=3, every=7, max=5},
		[Talents.T_ICE_SHARDS]={base=3, every=7, max=5},
		[Talents.T_SOUL_ROT]={base=3, every=7, max=5},
		[Talents.T_MANATHRUST]={base=3, every=7, max=5},
		[Talents.T_LIGHTNING]={base=3, every=7, max=5},
		[Talents.T_ICE_STORM]={base=3, every=7, max=5},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(4, "rune"),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	-- Add the lore on the upstairs
	on_added_to_level = function(self)
		local note = game.zone:makeEntityByName(game.level, "object", "NOTE6")
		if note then
			game.zone:addEntity(game.level, note, "object", game.level.default_up.x, game.level.default_up.y)
		end
		self.on_added_to_level = nil
	end,
}
