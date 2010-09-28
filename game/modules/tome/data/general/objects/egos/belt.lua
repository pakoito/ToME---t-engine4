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
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	name = " of carrying", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(50, 10, function(e, v) return v * 0.4, v end),
	},
}

newEntity{
	name = " of shielding", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		combat_def = resolvers.mbonus_material(10, 5, function(e, v) return v * 1, v end),
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "create a temporary shield that absorbs damage", power = 100, use = function(self, who)
		local power = 100 + who:getMag(120)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=power})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
	end}
}

newEntity{
	name = "slotted ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 8,
	cost = 6,
	belt_slots = resolvers.mbonus_material(6, 3, function(e, v) return v * 1 end),
	on_wear = function(self, who)
		who.inven[who.INVEN_INBELT] = {max=self.belt_slots, worn=false, use_speed=0.6, id=who.INVEN_INBELT}
	end,
	on_cantakeoff = function(self, who)
		if #who:getInven(who.INVEN_INBELT) > 0 then
			game.logPlayer(who, "You can not remove %s while it still carries items.", self:getName{do_color=true})
			return true
		end
	end,
	on_takeoff = function(self, who)
		who.inven[who.INVEN_INBELT] = nil
	end,
}

newEntity{
	name = " of the mystic", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of the titan", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of life", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 6,
	wielder = {
		life_regen = resolvers.mbonus_material(10, 2, function(e, v) return v * 1, v/10 end),
	},
}
