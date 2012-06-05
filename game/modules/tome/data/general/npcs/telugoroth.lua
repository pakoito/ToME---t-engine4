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

-- Teluvorta swap function
-- This causes the monster to swap places with a random target each turn
local function doTeluvortaSwap(self)
	local Map = require "engine.Map"
	local tgts = {}
	local grids = core.fov.circle_grids(self.x, self.y, 10)
	for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
		local a = game.level.map(x, y, Map.ACTOR)
		if a and a:canBe("teleport") and a ~= self and self:canProject({type=hit}, a.x, a.y) then
			tgts[#tgts+1] = a
		end
	end end

	if #tgts > 0 then
		-- Randomly take a target
		local a, id = rng.table(tgts)
		local target = a

		if self:checkHit(self:combatSpellpower(), target:combatSpellResist()) and target:canBe("teleport") and self:canBe("teleport") then
			-- first remove the target so the destination tile is empty
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			local px, py
			px, py = self.x, self.y
			if self:teleportRandom(a.x, a.y, 0) then
				-- return the target at the casters old location
				game.level.map(px, py, Map.ACTOR, target)
				self.x, self.y, target.x, target.y = target.x, target.y, px, py
				game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				game.logSeen(self, "Reality has shifted.")
			else
				-- return the target without effect
				game.level.map(target.x, target.y, Map.ACTOR, target)
				game.logSeen(self, "The spell fizzles!")
			end
		else
			game.logSeen(target, "%s resists the swap!", target.name:capitalize())
		end
		game:playSoundNear(self, "talents/teleport")
	end
end

newEntity{
	define_as = "BASE_NPC_TELUGOROTH", -- telu goroth = time terror
	type = "elemental", subtype = "temporal",
	killer_message = "and lost outside time",
	blood_color = colors.PURPLE,
	display = "E", color=colors.YELLOW,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.TEMPORAL, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 8,
	rank = 2,
	size_category = 3,
	levitation = 1,

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	global_speed_base = 1.5,
	stats = { str=8, dex=12, mag=12, wil=12, con=10 },

	resists = { [DamageType.TEMPORAL] = 100, },

	negative_status_effect_immune = 1,
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "telugoroth", color=colors.KHAKI,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  Its blurred form constantly shifts before your eyes.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=3, -- At rank four this talent gets an extra bolt, no scaling
	},
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "greater telugoroth", color=colors.YELLOW,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  Its blurred form constantly shifts before your eyes.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_temporal_greater_telugoroth.png", display_h=2, display_y=-1}}},
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70,80), life_rating = 10,
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=3,
		[Talents.T_ECHOES_FROM_THE_PAST]={base=3, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "ultimate telugoroth", color=colors.GOLD,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  Its blurred form constantly shifts before your eyes.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_temporal_ultimate_telugoroth.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	ai = "tactical",

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=3,
		[Talents.T_ECHOES_FROM_THE_PAST]={base=4, every=7},
		[Talents.T_RETHREAD]={base=3, every=7},
		[Talents.T_STOP]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),
}
-- telu vorta = time storm
newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "teluvorta", color=colors.DARK_KHAKI,
	desc = [[Time and space collapse in upon this erratically moving time elemental.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_snake" },
	doTeluvortaSwap = doTeluvortaSwap,
	
	talent_cd_reduction = {[Talents.T_DUST_TO_DUST]=-3},

	resolvers.talents{
		[Talents.T_DUST_TO_DUST]={base=3, every=10, max=7},
		[Talents.T_TEMPORAL_WAKE]={base=3, every=10, max=7},
	},
	resolvers.sustains_at_birth(),

	on_act = function(self)
		if rng.chance(2) then
			self:doTeluvortaSwap()
		end
	end,
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "greater teluvorta", color=colors.TAN,
	desc = [[Time and space collapse in upon this erratically-moving time elemental.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_temporal_greater_teluvorta.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_snake" },
	doTeluvortaSwap = doTeluvortaSwap,
	
	talent_cd_reduction = {[Talents.T_DUST_TO_DUST]=-3},

	resolvers.talents{
		[Talents.T_DIMENSIONAL_STEP]={base=5, every=10, max=9},
		[Talents.T_DUST_TO_DUST]={base=4, every=10, max=8},
		[Talents.T_TEMPORAL_WAKE]={base=4, every=10, max=8},
	},
	resolvers.sustains_at_birth(),
	on_act = function(self)
		if rng.chance(2) then
			self:doTeluvortaSwap()
		end
	end,
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "ultimate teluvorta", color=colors.DARK_TAN,
	desc = [[Time and space collapse in upon this erratically-moving time elemental.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_temporal_ultimate_teluvorta.png", display_h=2, display_y=-1}}},
	level_range = {18, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	size_category = 4,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20, combat_def_ranged = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_snake" },
	doTeluvortaSwap = doTeluvortaSwap,
	
	talent_cd_reduction = {[Talents.T_DUST_TO_DUST]=-3},

	resolvers.talents{
		[Talents.T_ANOMALY_TEMPORAL_STORM]=1,
		[Talents.T_DUST_TO_DUST]={base=4, every=7},
		[Talents.T_QUANTUM_SPIKE]={base=2, every=7},
		[Talents.T_SWAP]={base=5, every=7},
		[Talents.T_TEMPORAL_WAKE]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),
	on_act = function(self)
		if rng.chance(2) then
			self:doTeluvortaSwap()
		end
	end,
}
