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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")

newEntity{ base = "BASE_ROD",
	power_source = {nature=true},
	define_as = "ROD_SPYDRIC_POISON",
	unided_name = "poison dripping wand", image = "object/artifact/rod_of_spydric_poison.png",
	name = "Rod of Spydric Poison", color=colors.LIGHT_GREEN, unique=true,
	desc = [[This rod carved out of a giant spider fang continuously drips venom.]],
	cost = 50,
	elec_proof = true,

	max_power = 75, power_regen = 1,
	use_power = { name = "shoot a bolt of spydric poison", power = 25,
		use = function(self, who)
			local tg = {type="bolt", range=12, talent=t}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.SPYDRIC_POISON, {dam=200 + who:getMag() * 4, dur=6}, {type="slime"})
			return {id=true, used=true}
		end
	},
}
