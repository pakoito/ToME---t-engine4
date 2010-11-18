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

load("/data/general/npcs/elven-caster.lua", rarity(0))
load("/data/general/npcs/elven-warrior.lua", rarity(0))
load("/data/general/npcs/minor-demon.lua", rarity(5))
load("/data/general/npcs/major-demon.lua", function(e) e.rarity = nil end)
local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_MAJOR_DEMON", define_as = "KRYL_FEIJAN",
	name = "Kryl-Feijan", color=colors.VIOLET, unique = true,
	desc = [[This huge demon is covered in darkness. The ripped flesh of its "mother" still hands on its shard claws.]],
	level_range = {29, nil}, exp_worth = 2,
	rank = 3.5,
	size_category = 4,
	max_life = 250, life_rating = 21, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=42, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	poison_immune = 1,
	blind_immune = 1,
	combat_armor = 0, combat_def = 15,

	open_door = true,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	combat = { dam=resolvers.mbonus(66, 20), atk=50, apr=30, dammod={str=1.1} },

	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_DARKNESS]=3,
		[Talents.T_EVASION]=5,
		[Talents.T_VIRULENT_DISEASE]=3,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ define_as = "MELINDA",
	name = "Melinda",
	type = "humanoid", subtype = "human", female=true,
	display = "@", color=colors.LIGHT_BLUE,
	desc = [[A female human lying unconcious on a black altar, twisted sigils scored into her naked flesh.
You can discern great beauty under the stains of blood covering her skin.]],
	autolevel = "tank",
	ai = "summoned", ai_real = "move_dmap", ai_state = { ai_target="target_player", talent_in=4, },
	stats = { str=8, dex=7, mag=8, con=12 },
	faction = "victim",

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 4,
	rank = 2,
	exp_worth = 0,

	max_life = 100, life_regen = 0,
	life_rating = 12,
	combat_armor = 3, combat_def = 3,
	inc_damage = {all=-50},

	on_added_to_level = function(self)
		self:setEffect(self.EFF_TIME_PRISON, 100, {})
	end,

	on_die = function(self)
		game.player:hasQuest("kryl-feijan-escape").not_saved = true
		game.player:setQuestStatus("kryl-feijan-escape", engine.Quest.FAILED)
	end,
}

newEntity{ define_as = "ACOLYTE",
	name = "Acolyte of the Sect of Kryl-Feijan",
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.LIGHT_RED,
	desc = [[Black robed elves with a mad look in their eyes.]],
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, },
	stats = { str=12, dex=17, mag=18, wil=22, con=12 },

	infravision = 20,
	move_others = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	rank = 3,
	exp_worth = 2,

	max_life = 200, life_regen = 10,
	life_rating = 14,

	resolvers.talents{
		[Talents.T_SOUL_ROT]=4,
		[Talents.T_FLAME]=5,
		[Talents.T_MANATHRUST]=3,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self)
		if not game.level.turn_counter then return end
		local nb = 0
		local melinda
		for uid, e in pairs(game.level.entities) do
			if e.define_as and e.define_as == "ACOLYTE" and not e.dead then nb = nb + 1 end
			if e.define_as and e.define_as == "MELINDA" then melinda = e end
		end
		if nb == 0 then
			game.level.turn_counter = nil

			local spot = game.level:pickSpot{type="locked-door", subtype="locked-door"}
			local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)

			if melinda then
				melinda:removeEffect(melinda.EFF_TIME_PRISON)
				require("engine.ui.Dialog"):simpleLongPopup("Melinda", "The woman seems to be freed from her bonds.\nShe stumbles on her feet, her naked body still dripping in blood. 'Please get me out of here!'", 400)
			end
		end
	end,
}
