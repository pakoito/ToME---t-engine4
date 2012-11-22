-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local DamageType = require "engine.DamageType"
local src = version

local function has_ward(which)
	if not src.wards then return false end
	if src.wards[which] and src.wards[which] ~= 0 then return true end
	return false
end

local function set_ward(which, charges)
	src:setEffect(src.EFF_WARD, 10, {nb=charges, d_type=which})
	state.set_ward = true
end

newChat{ id="welcome",
	text = [[Call forth which ward?]],
	answers = {
		{"Fire ["..(src.wards[DamageType.FIRE] or 0).."]", 
			cond = function() return has_ward(DamageType.FIRE) end,
			action = function() return set_ward(DamageType.FIRE, (src.wards[DamageType.FIRE] or 0)) end,
		},
		{"Lightning ["..(src.wards[DamageType.LIGHTNING] or 0).."]",
			cond = function() return has_ward(DamageType.LIGHTNING) end,
			action = function() return set_ward(DamageType.LIGHTNING, (src.wards[DamageType.LIGHTNING] or 0)) end,
		},
		{"Cold ["..(src.wards[DamageType.COLD] or 0).."]",
			cond = function(who) return has_ward(DamageType.COLD) end,
			action = function() return set_ward(DamageType.COLD, (src.wards[DamageType.COLD] or 0)) end,
		},
		{"Arcane ["..(src.wards[DamageType.ARCANE] or 0).."]",
			cond = function(who) return has_ward(DamageType.ARCANE) end,
			action = function() return set_ward(DamageType.ARCANE, (src.wards[DamageType.ARCANE] or 0)) end,
		},
		{"Light ["..(src.wards[DamageType.LIGHT] or 0).."]", 
			cond = function() return has_ward(DamageType.LIGHT) end,
			action = function() return set_ward(DamageType.LIGHT, (src.wards[DamageType.LIGHT] or 0)) end,
		},
		{"Darkness ["..(src.wards[DamageType.DARKNESS] or 0).."]", 
			cond = function() return has_ward(DamageType.DARKNESS) end,
			action = function() return set_ward(DamageType.DARKNESS, (src.wards[DamageType.DARKNESS] or 0)) end,
		},
		{"Temporal ["..(src.wards[DamageType.TEMPORAL] or 0).."]", 
			cond = function() return has_ward(DamageType.TEMPORAL) end,
			action = function() return set_ward(DamageType.TEMPORAL, (src.wards[DamageType.TEMPORAL] or 0)) end,
		},
		{"Physical ["..(src.wards[DamageType.PHYSICAL] or 0).."]", 
			cond = function() return has_ward(DamageType.PHYSICAL) end,
			action = function() return set_ward(DamageType.PHYSICAL, (src.wards[DamageType.PHYSICAL] or 0)) end,
		},
		{"Nature ["..(src.wards[DamageType.NATURE] or 0).."]", 
			cond = function() return has_ward(DamageType.NATURE) end,
			action = function() return set_ward(DamageType.NATURE, (src.wards[DamageType.NATURE] or 0)) end,
		},
		{"Blight ["..(src.wards[DamageType.BLIGHT] or 0).."]", 
			cond = function() return has_ward(DamageType.BLIGHT) end,
			action = function() return set_ward(DamageType.BLIGHT, (src.wards[DamageType.BLIGHT] or 0)) end,
		},
		{"Acid ["..(src.wards[DamageType.ACID] or 0).."]", 
			cond = function() return has_ward(DamageType.ACID) end,
			action = function() return set_ward(DamageType.ACID, (src.wards[DamageType.ACID] or 0)) end,
		},
		{"Mind ["..(src.wards[DamageType.MIND] or 0).."]", 
			cond = function() return has_ward(DamageType.MIND) end,
			action = function() return set_ward(DamageType.MIND, (src.wards[DamageType.MIND] or 0)) end,
		},

		{"Never mind"},
	}
}

return "welcome"

