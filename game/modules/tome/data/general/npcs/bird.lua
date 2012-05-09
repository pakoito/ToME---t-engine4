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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_BIRD",
	type = "animal", subtype = "bird",
	display = "B", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },

	stats = { str=12, dex=20, mag=3, con=13 },
	global_speed_base = 1.2,
	combat_armor = 1, combat_def = 5,
	combat = { dam=5, atk=15, apr=7, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 1,
	size_category = 1,
	levitation = 1,

	can_pass = {pass_tree=10},
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base="BASE_NPC_BIRD", define_as = "NPC_PHOENIX",
	name = "Phoenix", unique = true,
	display = "B", color=colors.VIOLET,
	rarity = 50,
	desc = [[Ever burning, ever dying, ever reviving, the Phoenix swoops down upon you, seeking to share its fiery fate with you.]],
	level_range = {40, 75}, exp_worth = 10,
	max_life = 1000, life_rating = 23, fixed_rating = true,
	max_mana = 1000,
	mana_regen = 20,
	life_regen = -15,
	rank = 3.5,
	no_breath = 1,
	size_category = 3,

	lite = 2,
	ai = "tactical",

	stats = { str=20, dex=60, cun=60, mag=30, con=40, wil=40 },
	combat = { dam=resolvers.levelup(50, 1, 1), atk=50, apr=12, dammod={mag=1.3} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
        resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=9, {ego_chance=100} },

	resists = { [DamageType.FIRE] = 100 },

	resolvers.talents{
		[Talents.T_BODY_OF_FIRE]=10,
		[Talents.T_FIRE_STORM]=5,
		[Talents.T_HEAT]=5,
		[Talents.T_WILDFIRE]=5,
		[Talents.T_WING_BUFFET]=5,
		[Talents.T_BURNING_WAKE]=5,
		[Talents.T_FLAME]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_BLASTWAVE]=5,
		[Talents.T_FLAMESHOCK]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	move = function(self, x, y, force)
		if self.x and self.y then game.level.map:particleEmitter(self.x, self.y, 1, "firetrail") end
		return mod.class.NPC.move(self, x, y, force)
	end,

	die = function(self, src)
		local dur = rng.range(5,10)

		if not self:hasEffect(self.EFF_PHOENIX_EGG) then
			self.dead = nil
			self:resetToFull()
			self.life = math.min(1500, self.max_life)
			self:setEffect(self.EFF_PHOENIX_EGG, dur, {life_regen = 25, mana_regen = -9.75, never_move = 1, never_blow = 1, silence = 1})
			game.logSeen(src, "#LIGHT_RED#%s raises from the dead!", self.name:capitalize())
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "RESURRECT!", {255,120,0})
			self.died = (self.died or 0) + 1
		else
			return mod.class.NPC.die(self, src)
		end
	end,
}
