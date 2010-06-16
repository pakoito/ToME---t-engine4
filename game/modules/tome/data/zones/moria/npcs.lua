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

load("/data/general/npcs/orc.lua")
load("/data/general/npcs/troll.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Moria, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GOLBUG",
	type = "humanoid", subtype = "orc", unique = true,
	faction = "orc-pride",
	name = "Golbug the Destroyer",
	display = "o", color=colors.VIOLET,
	desc = [[A huge and muscular orc of unknown breed. He looks both menacing and cunning...]],
	level_range = {28, 45}, exp_worth = 2,
	max_life = 350, life_rating = 16, fixed_rating = true,
	max_stamina = 245,
	rank = 5,
	size_category = 3,
	infravision = 20,
	stats = { str=22, dex=19, cun=34, mag=10, con=16 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
		{type="armor", subtype="head", autoreq=true},
		{type="armor", subtype="massive", ego_chance=50, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {type="jewelry", subtype="orb", defined="ORB_MANY_WAYS"} },

	stun_immune = 1,
	see_invisible = 5,

	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=3,
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_MACE_MASTERY]=6,
		[Talents.T_SHIELD_PUMMEL]=4,
		[Talents.T_RUSH]=4,
		[Talents.T_RIPOSTE]=4,
		[Talents.T_BLINDING_SPEED]=4,
		[Talents.T_OVERPOWER]=3,
		[Talents.T_ASSAULT]=3,
		[Talents.T_SHIELD_WALL]=3,
		[Talents.T_SHIELD_EXPERTISE]=2,

		[Talents.T_BELLOWING_ROAR]=3,
		[Talents.T_WING_BUFFET]=2,
		[Talents.T_FIRE_BREATH]=4,

		[Talents.T_ICE_CLAW]=3,
		[Talents.T_ICY_SKIN]=4,
		[Talents.T_ICE_BREATH]=4,
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	on_acquire_target = function(self, who)
		-- Doesnt matter who, jsut assume the player is there
		if not self.has_chatted then
			self.has_chatted = true
			local Chat = require("engine.Chat")
			local chat = Chat.new("golbug-explains", self, game.player)
			chat:invoke()
		end
	end,

	on_die = function(self, who)
		world:gainAchievement("DESTROYER_BANE", game.player:resolveSource())
		game.player.winner = true
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE)
		game.player:grantQuest("wild-wild-east")
		local D = require "engine.Dialog"
		D:simplePopup("Winner!", "#VIOLET#Congratulations, you have won the game! At least for now... The quest has only started!")
	end,
}
