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
	name = "natural ", prefix=true,
	keywords = {natural=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incEquilibrium(-self:getCharmPower(true) / 5)
		end] = {100, function(self, who) return ("regenerate %d equilibrium"):format(self:getCharmPower(true) / 5) end},
	}
}

newEntity{
	name = "forcefull ", prefix=true,
	keywords = {force=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incStamina(self:getCharmPower(true) / 6)
		end] = {100, function(self, who) return ("regenerate %d stamina"):format(self:getCharmPower(true) / 6) end},
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
			[DamageType.NATURE] = resolvers.mbonus_material(4, 1),
			[DamageType.ACID] = resolvers.mbonus_material(4, 1),
			[DamageType.LIGHT] = resolvers.mbonus_material(4, 1),
		},
		learn_talent = {[Talents.T_WARD] = 1},
	},
}

newEntity{
	name = "rushing ", prefix=true,
	keywords = {rushing=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		learn_talent = {[Talents.T_RUSHING_CLAWS] = resolvers.mbonus_material(4, 1)},
	},
}

newEntity{
	name = "webbed ", prefix=true,
	keywords = {webbed=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		learn_talent = {[Talents.T_LAY_WEB] = resolvers.mbonus_material(4, 1)},
	},
}

newEntity{
	name = "tentacled ", prefix=true,
	keywords = {tentacled=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 15,

	wielder = {
		talent_cd_reduction={[Talents.T_INVOKE_TENTACLE]=-5},
		learn_talent = {[Talents.T_INVOKE_TENTACLE] = 1},
	},
}
