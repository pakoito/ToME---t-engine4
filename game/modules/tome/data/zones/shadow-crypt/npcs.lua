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

load("/data/general/npcs/shade.lua", rarity(0))
load("/data/general/npcs/orc-rak-shor.lua", rarity(10))

load("/data/general/npcs/all.lua", function(e) if e.rarity then e.shade_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_RAK_SHOR", define_as = "CULTIST_RAK_SHOR",
	name = "Rak'Shor Cultist", color=colors.VIOLET, unique = true,
	desc = [[An old orc, wearing black robes. He seems to be responsible for the creation of the shades.]],
	level_range = {35, 50}, exp_worth = 2,
	rank = 4,
	max_life = 150, life_rating = 17, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=42, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	disease_immune = 1,
	confusion_immune = 1,
	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.equip{
		{type="weapon", subtype="staff", ego_change=100, autoreq=true},
	},
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	inc_damage = {[DamageType.BLIGHT] = -30},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_EVASION]=5,
		[Talents.T_VIRULENT_DISEASE]=5,
		[Talents.T_CYST_BURST]=3,
		[Talents.T_EPIDEMIC]=4,
	},
	resolvers.sustains_at_birth(),

	on_takehit = function(self, value, src)
		-- When the bone shield is taken down, copy the player
		if not self:isTalentActive(self.T_BONE_SHIELD) and not self.copied_player then
			local a = mod.class.NPC.new{}
			a:replaceWith(game.player:cloneFull())
			mod.class.NPC.castAs(a)
			engine.interface.ActorAI.init(a, a)
			a.no_drops = true
			a.energy.value = 0
			a.player = nil
			a.rank = 4
			a.name = "Shade of "..a.name
			a.color_r = 150 a.color_g = 150 a.color_b = 150
			a._mo:invalidate()
			a.ai = "dumb_talented_simple"
			a.ai_state = {talent_in=1}
			a.faction = self.faction
			a.inc_damage.all = (a.inc_damage.all or 0) - 40
			a.max_life = a.max_life * 1.8
			a.life = a.max_life
			a.on_die = function(self)
				world:gainAchievement("SHADOW_CLONE", game.player)
				game.level.map(self.x, self.y, game.level.map.TERRAIN, game.zone.grid_list.UP_WILDERNESS)
				game.logSeen(who, "As your shade dies the magical veil protecting the stairs out vanishes.")
			end

			-- Remove some talents
			local tids = {}
			for tid, _ in pairs(a.talents) do
				local t = a:getTalentFromId(tid)
				if t.no_npc_use then tids[#tids+1] = t end
			end
			for i, t in ipairs(tids) do
				if t.mode == "sustained" and a:isTalentActive(t.id) then a:forceUseTalent(t.id, {ignore_energy=true}) end
				a.talents[t.id] = nil
			end

			local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[engine.Map.ACTOR]=true})
			if x and y then
				game.zone:addEntity(game.level, a, "actor", x, y)

				game.logPlayer(game.player, "#GREY#The cultist looks deep in your eyes, you feel torn apart!")
				self:doEmote("Ra'kk kor merk ZUR!!!", 120)
				self.copied_player = true
			end
		end
		return value
	end,
}
