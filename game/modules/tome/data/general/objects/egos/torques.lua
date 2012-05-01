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

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

load("/data/general/objects/egos/charms.lua")

newEntity{
	name = "psionic ", prefix=true,
	keywords = {psi=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incPsi(self:getCharmPower(true) / 7)
		end] = {100, function(self, who) return ("regenerate %d psi"):format(self:getCharmPower(true) / 7) end},
	}
}

newEntity{
	name = "hateful ", prefix=true,
	keywords = {hate=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incHate(-self:getCharmPower(true) / 7)
		end] = {100, function(self, who) return ("regenerate %d hate"):format(self:getCharmPower(true) / 7) end},
	}
}

newEntity{
	name = "warded ", prefix=true,
	keywords = {ward=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		wards = {
			[DamageType.MIND] = resolvers.mbonus_material(4, 1),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(2, 1),
			[DamageType.DARKNESS] = resolvers.mbonus_material(4, 1),
		},
		learn_talent = {[Talents.T_WARD] = 1},
	},
}

newEntity{
	name = "quiet ", prefix=true,
	keywords = {quiest=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		talent_cd_reduction={[Talents.T_SILENCE]=-5},
		learn_talent = {[Talents.T_SILENCE] = resolvers.mbonus_material(4, 1)},
	},
}

newEntity{
	name = "telekinetic ", prefix=true,
	keywords = {telekinetic=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		talent_cd_reduction={[Talents.T_TELEKINETIC_BLAST]=-5},
		learn_talent = {[Talents.T_TELEKINETIC_BLAST] = resolvers.mbonus_material(4, 1)},
	},
}
