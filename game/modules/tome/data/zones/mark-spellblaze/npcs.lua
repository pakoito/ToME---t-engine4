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
	level_range = {30, nil}, exp_worth = 1,
	rank = 3.5,
	vim_regen = 40,
	max_vim = 800,
	max_life = resolvers.rngavg(300, 310), life_rating = 18,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=1, {defined="DRAFT_LETTER"} },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	combat_armor = 0, combat_def = 0,
	silence_immune = 0.5,

	resolvers.talents{
		[Talents.T_BONE_SHIELD]=3,
		[Talents.T_BLOOD_SPRAY]=4,
		[Talents.T_SOUL_ROT]=3,
		[Talents.T_BLOOD_GRASP]=4,
		[Talents.T_BLOOD_BOIL]=3,
		[Talents.T_BLOOD_FURY]=4,
		[Talents.T_BONE_SPEAR]=3,
		[Talents.T_VIRULENT_DISEASE]=5,
		[Talents.T_DARKFIRE]=4,
		[Talents["T_FLAME_OF_URH'ROK"]]=5,
		[Talents.T_DEMON_PLANE]=5,
		[Talents.T_CYST_BURST]=4,
		[Talents.T_BURNING_HEX]=5,
		[Talents.T_WRAITHFORM]=5,
	},
	resolvers.sustains_at_birth(),

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
				local chat = Chat.new("corruptor-quest", self, game.player)
				chat:invoke()
				return 0
			end
		end
		return value
	end,
}
