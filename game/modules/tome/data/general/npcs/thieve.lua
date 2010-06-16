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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_THIEF",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.BLUE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.drops{chance=100, nb=2, {type="money"} },
	infravision = 10,

	max_stamina = 100,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	energy = { mod=1 },
	stats = { str=8, dex=15, mag=6, cun=15, con=7 },

	resolvers.tmasteries{ ["technique/other"]=0.3, ["cunning/stealth"]=1, ["cunning/dirty"]=0.3, ["technique/dualweapon-training"]=0.3 },
	resolvers.talents{ [Talents.T_LETHALITY]=1, },
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "cutpurse", color_r=0, color_g=0, color_b=resolvers.rngrange(235, 255),
	desc = [[The lowest of the thieves, they are just learning the tricks of the trade.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 5,
	combat_armor = 1, combat_def = 5,
	max_life = resolvers.rngavg(60,80),
	resolvers.talents{  },
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "rogue", color_r=0, color_g=0, color_b=resolvers.rngrange(215, 235),
	desc = [[Stronger than a cutpurse, this thief has been promoted.]],
	level_range = {2, nil}, exp_worth = 1,
	rarity = 5,
	combat_armor = 2, combat_def = 5,
	resolvers.talents{ [Talents.T_STEALTH]=1,  },
	on_added = function(self) self.energy.value = game.energy_to_act self:useTalent(self.T_STEALTH) end,
	max_life = resolvers.rngavg(70,90),
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "thief", color_r=0, color_g=0, color_b=resolvers.rngrange(195, 215),
	desc = [[He eyes you and your belongings, then suddenly vanishes... strange, why is your pack lighter?]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 5,
	combat_armor = 3, combat_def = 5,
	resolvers.talents{ [Talents.T_STEALTH]=2,  },
	on_added = function(self) self.energy.value = game.energy_to_act self:useTalent(self.T_STEALTH) end,
	max_life = resolvers.rngavg(70,90),
}

newEntity{ base = "BASE_NPC_THIEF", define_as = "THIEF_BANDIT",
	name = "bandit", color_r=0, color_g=0, color_b=resolvers.rngrange(175, 195),
	desc = [[These ruffians often employ brute force over thievery, but they are capable of stealing as well.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 7,
	combat_armor = 4, combat_def = 6,
	resolvers.talents{ [Talents.T_STEALTH]=3, [Talents.T_LETHALITY]=2, },
	on_added = function(self) self.energy.value = game.energy_to_act self:useTalent(self.T_STEALTH) end,
	max_life = resolvers.rngavg(80,100),
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "bandit lord", color_r=resolvers.rngrange(75, 85), color_g=0, color_b=resolvers.rngrange(235, 255),
	desc = [[He is the leader of a gang of bandits, watch out for his men.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 12,
	combat_armor = 5, combat_def = 7,
	max_life = resolvers.rngavg(90,100),
	combat = { dam=resolvers.rngavg(6,7), atk=10, apr=4},
	make_escort = {
		{type="humanoid", subtype="human", name="bandit", number=2},
		{type="humanoid", subtype="human", name="thief", number=2},
		{type="humanoid", subtype="human", name="rogue", number=2},
	},
	summon = {
		{type="humanoid", subtype="human", name="bandit", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="bandit", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="thief", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="rogue", number=2, hasxp=false},
	},
	resolvers.talents{ [Talents.T_STEALTH]=3, [Talents.T_SUMMON]=1, [Talents.T_LETHALITY]=3, },
	on_added = function(self) self.energy.value = game.energy_to_act self:useTalent(self.T_STEALTH) end,
}

newEntity{ base = "BASE_NPC_THIEF", define_as = "THIEF_ASSASSIN",
	name = "assassin", color_r=resolvers.rngrange(0, 10), color_g=resolvers.rngrange(0, 10), color_b=resolvers.rngrange(0, 10),
	desc = [[Before you looms a pair of eyes... A glint of steel... death.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 12,
	combat_armor = 3, combat_def = 10,
	resolvers.talents{ [Talents.T_STEALTH]=3, [Talents.T_PRECISION]=3, [Talents.T_DUAL_WEAPON_TRAINING]=2, [Talents.T_DUAL_WEAPON_DEFENSE]=2, [Talents.T_DUAL_STRIKE]=1, [Talents.T_SWEEP]=1, [Talents.T_SHADOWSTRIKE]=2, [Talents.T_LETHALITY]=5, },
	on_added = function(self) self.energy.value = game.energy_to_act self:useTalent(self.T_STEALTH) end,
	max_life = resolvers.rngavg(70,90),
}
