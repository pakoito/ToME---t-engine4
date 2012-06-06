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

load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/ghoul.lua")
load("/data/general/npcs/vampire.lua")
load("/data/general/npcs/bone-giant.lua")
load("/data/general/npcs/lich.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "CELIA",
	name = "Celia",
	type = "humanoid", subtype = "human", image = "npc/humanoid_human_celia.png",
	female = true,
	display = "p", color=colors.GREY,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_celia.png", display_h=2, display_y=-1}}},
	desc = [[A tall woman stands before you in a stained robe. Her sallow skin is marked by pox and open sores, but her eyes are bright and keen. The bulge around her abdomen would indicate that she is several months pregnant.]],
	autolevel = "caster",
	stats = { str=12, dex=17, mag=22, wil=22, con=12 },

	infravision = 10,
	move_others = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	rank = 3.5,
	exp_worth = 2,
	level_range = {20, nil},

	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	max_life = 500, life_regen = 0,
	mana_regen = 10,
	life_rating = 20,

	necrotic_aura_base_souls = 6,
	resolvers.talents{
		[Talents.T_INVOKE_DARKNESS]={base=5, every=5, max=10},
		[Talents.T_NECROTIC_AURA]=1,
		[Talents.T_CREATE_MINIONS]=2,
		[Talents.T_AURA_MASTERY]=5,
		[Talents.T_SURGE_OF_UNDEATH]={base=2, every=4, max=7},
		[Talents.T_CHILL_OF_THE_TOMB]={base=3, every=5, max=10},
		[Talents.T_WILL_O__THE_WISP]={base=3, every=5, max=10},
		[Talents.T_COLD_FLAMES]={base=4, every=5, max=10},
		[Talents.T_VAMPIRIC_GIFT]={base=2, every=5, max=10},
		[Talents.T_BLURRED_MORTALITY]={base=5, every=5, max=10},
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=5, max=10},
		[Talents.T_RIGOR_MORTIS]={base=3, every=5, max=10},
		[Talents.T_FORGERY_OF_HAZE]={base=3, every=5, max=10},
		[Talents.T_FROSTDUSK]={base=3, every=5, max=10},
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_takehit = function(self, val)
		if not game.zone.open_all_coffins then return val end
		self.on_takehit = nil
		game.zone.open_all_coffins(game.player, self)
		local p = game:getPlayer(true)
		p:setQuestStatus("grave-necromancer", engine.Quest.COMPLETED, "coffins")
		return val
	end,

	on_die = function(self)
		local p = game:getPlayer(true)
		if game.player:hasQuest("lichform") then
			game.player:setQuestStatus("lichform", engine.Quest.COMPLETED, "heart")

			local o = game.zone:makeEntityByName(game.level, "object", "CELIA_HEART")
			o:identify(true)
			if p:addObject(p.INVEN_INVEN, o) then
				game.logPlayer(p, "You receive: %s.", o:getName{do_color=true})
			end

			local Dialog = require("engine.ui.Dialog")
			Dialog:simpleLongPopup("Celia", "As you deal the last blow you quickly carve out Celia's heart for your Lichform ritual.\nCarefully weaving magic around it to keep it beating.", 400)
			p:setQuestStatus("grave-necromancer", engine.Quest.COMPLETED, "kill-necromancer")
		else
			if game.player:knownLore("necromancer-primer-1") and
			   game.player:knownLore("necromancer-primer-2") and
			   game.player:knownLore("necromancer-primer-3") and
			   game.player:knownLore("necromancer-primer-4") then
				game:setAllowedBuild("mage_necromancer", true)
			end
			p:setQuestStatus("grave-necromancer", engine.Quest.COMPLETED, "kill")
		end
		p:setQuestStatus("grave-necromancer", engine.Quest.COMPLETED)
	end,
}
