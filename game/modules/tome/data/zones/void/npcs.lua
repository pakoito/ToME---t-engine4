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

--load("/data/general/npcs/telugoroth.lua", rarity(0))
--load("/data/general/npcs/horror.lua", function(e) if e.rarity then e.horror_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "GOD_GERLYK",
	type = "god", subtype = "god", unique = true,
	name = "Gerlyk, the Creator",
	display = "P", color=colors.VIOLET,
	desc = [[During the Age of Haze nearly all gods were destroyed by the Sher'tuls Godslayers. yet a few escaped.
Gerlyk, the creator of the human race, prefered to flee into the void between the stars than to face death. He has been trapped ever since.
The sorcerers tried to bring him back and nearly succeeded.
Now you have come to finish what the Sher'tul began. Become a Godslayer yourself.]],
	level_range = {100, nil}, exp_worth = 3,
	max_life = 900, life_rating = 80, fixed_rating = true,
	life_regen = 25,
	max_stamina = 10000,
	max_mana = 10000,
	max_positive = 10000,
	max_negative = 10000,
	max_vim = 10000,
	stats = { str=100, dex=100, con=100, mag=100, wil=100, cun=100 },
	inc_stats = { str=80, dex=80, con=80, mag=80, wil=80, cun=80 },
	rank = 5,
	size_category = 5,
	infravision = 10,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	move_others=true,
	see_invisible = 150,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
	},
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

-- give him a special shield talent that only the staff of absorption can remove
	resolvers.talents{
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_DISMAY]=3,
		[Talents.T_UNNATURAL_BODY]=4,
		[Talents.T_DOMINATE]=1,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_SLASH]=3,
		[Talents.T_RECKLESS_CHARGE]=1,

		[Talents.T_DAMAGE_SMEARING]=5,
		[Talents.T_HASTE]=3,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
--	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, {"healing infusion", "regeneration infusion", "shielding rune", "invisibility rune", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("void-gerlyk", engine.Quest.COMPLETED)
	end,
}
