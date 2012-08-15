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

local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/bear.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(3))
load("/data/general/npcs/canine.lua", rarity(1))
load("/data/general/npcs/snake.lua", rarity(0))
load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/faeros.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

-- Everything is poison immune in the caldera, they couldnt live there otherwise
for i, e in ipairs(loading_list) do
	if e.name then e.poison_immune = 1 e.faction = "enemies" end
end

newEntity{ define_as = "MINDWORM",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "thalore", unique = true,
	name = "Mindworm",
	display = "p", color=colors.VIOLET,
	desc = [[This tall thalore eyes are lost in the distance, you can feel that he barely sees you.]],
	killer_message = "and mind-probed",
	level_range = {25, nil}, exp_worth = 2,
	max_life = 100, life_rating = 10, fixed_rating = true,
	psi_rating = 9,
	rank = 3.5,
	size_category = 3,
	infravision = 10,
	stats = { str=10, dex=12, cun=24, mag=10, wil=25, con=10 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="mindstar", defined="PSIONIC_FURY", random_art_replace={chance=75}, autoreq=true},
		{type="weapon", subtype="mindstar", autoreq=true},
		{type="jewelry", subtype="amulet", autoreq=true},
		{type="jewelry", subtype="ring", autoreq=true},
		{type="jewelry", subtype="ring", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="NOTE5"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SLEEP]={base=3, every=4, max=7},
		[Talents.T_MIND_SEAR]={base=5, every=4, max=8},
		[Talents.T_SOLIPSISM]={base=5, every=4, max=8},
		[Talents.T_FEEDBACK_LOOP]={base=3, every=4, max=7},
		[Talents.T_BACKLASH]={base=3, every=4, max=7},
		[Talents.T_FORGE_SHIELD]={base=5, every=4, max=7},
		[Talents.T_FORGE_ARMOR]={base=3, every=4, max=7},
		[Talents.T_BIOFEEDBACK]={base=4, every=4, max=7},
		[Talents.T_RESONANCE_FIELD]={base=4, every=4, max=7},
		[Talents.T_AMPLIFICATION]={base=3, every=4, max=7},
		[Talents.T_CONVERSION]={base=3, every=4, max=7},
		[Talents.T_PSYCHIC_LOBOTOMY]={base=4, every=4, max=7},
		[Talents.T_SYNAPTIC_STATIC]={base=3, every=4, max=7},
	},
	resolvers.inscriptions(2, "infusion"),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self)
		game.level.data.fumes_active = false
		require("engine.ui.Dialog"):simplePopup("Fumes", "As Mindworm dies you can feel the fumes getting less poisonous for your mind.")
	end,
}
