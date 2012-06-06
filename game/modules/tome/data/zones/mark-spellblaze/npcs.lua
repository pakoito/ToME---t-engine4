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
load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/faeros.lua", rarity(2))
load("/data/general/npcs/gwelgoroth.lua", rarity(2))
load("/data/general/npcs/elven-caster.lua", rarity(2))

--load("/data/general/npcs/all.lua", rarity(4, 65))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_ELVEN_CASTER", define_as = "GRAND_CORRUPTOR",
	allow_infinite_dungeon = true,
	name = "Grand Corruptor", color=colors.VIOLET, unique = true,
	desc = [[An elven corruptor, drawn to these blighted lands.]],
	level_range = {25, nil}, exp_worth = 1,
	rank = 3.5,
	max_vim = 800,
	max_life = resolvers.rngavg(300, 310), life_rating = 18,
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=1, {defined="DRAFT_LETTER"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	combat_armor = 0, combat_def = 0,
	silence_immune = 0.5,

	resolvers.talents{
		[Talents.T_DRAIN]={base=5, every=10, max=7},
		[Talents.T_BONE_SHIELD]={base=3, every=5, max=6},
		[Talents.T_BLOOD_SPRAY]={base=4, every=5, max=7},
		[Talents.T_SOUL_ROT]={base=3, every=5, max=6},
		[Talents.T_BLOOD_GRASP]={base=4, every=5, max=7},
		[Talents.T_BLOOD_BOIL]={base=3, every=5, max=6},
		[Talents.T_BLOOD_FURY]={base=4, every=5, max=7},
		[Talents.T_BONE_SPEAR]={base=3, every=5, max=6},
		[Talents.T_VIRULENT_DISEASE]={base=5, every=5, max=8},
		[Talents.T_DARKFIRE]={base=4, every=5, max=7},
		[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
		[Talents.T_DEMON_PLANE]={base=5, every=5, max=8},
		[Talents.T_CYST_BURST]={base=4, every=5, max=7},
		[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
		[Talents.T_WRAITHFORM]={base=5, every=5, max=8},
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(2, "rune"),

	on_added_to_level = function(self)
		self.on_added_to_level = nil
		-- Remove the quest starter when not spawned in the mark of the spellblaze
		if not game.zone.is_mark_spellblaze then self.on_takehit = nil end
	end,

	on_takehit = function(self, value, src)
		if not self.chatted and (self.life - value) < self.max_life * 0.4 then
			self.chatted = true
			-- Check for magical knowledge
			local has_spells = 0
			for tid, lev in pairs(game.player.talents) do
				local t = game.player:getTalentFromId(tid)
				if t.is_spell then has_spells = has_spells + lev end
			end
			print("Player has a total of "..has_spells.." spell levels")
			if not game.player:hasQuest("antimagic") and has_spells > 10 then
				local Chat = require "engine.Chat"
				local chat = Chat.new("corruptor-quest", self, game:getPlayer(true))
				chat:invoke()
				return 0
			end
		end
		return value
	end,
}
