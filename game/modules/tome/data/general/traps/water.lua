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

newEntity{ define_as = "TRAP_WATER",
	type = "natural", subtype="water", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		self:project({type="hit",x=x,y=y}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true, self.auto_disarm
	end,
}

newEntity{ base = "TRAP_WATER",
	name = "water jet", auto_id = true, image = "trap/trap_water_jet_01.png",
	detect_power = 6, disarm_power = 16,
	rarity = 3, level_range = {1, 50},
	color=colors.LIGHT_BLUE,
	message = "@Target@ triggers a water jet!",
	dam = resolvers.mbonus_level(150, 15), damtype = DamageType.PHYSICAL,
	auto_disarm = true,
}

newEntity{ base = "TRAP_WATER",
	name = "water siphon", auto_id = true, image = "trap/trap_water_siphon_01.png",
	detect_power = 8, disarm_power = 2,
	rarity = 3, level_range = {1, 50},
	color=colors.BLUE,
	message = "@Target@ is caught by a water siphon!",
	dam = resolvers.mbonus_level(90, 15),
	combatPhysicalpower = function(self) return self.disarm_power * 2 end,
	triggered = function(self, x, y, who)
		self:project({type="ball",radius=2,x=x,y=y}, x, y, engine.DamageType.PINNING, {dam=self.dam,dur=4})
		return true
	end,
}
