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

newEffect{
	name = "POISONED",
	desc = "Poisoned",
	long_desc = function(self, eff) return ("The target is poisoned, doing 1 damage per turn.") end,
	type = "poison",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# is poisoned!", "+Poison" end,
	on_lose = function(self, err) return "#Target# stops being poisoned.", "-Poison" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = old_eff.dur + new_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, 1)
	end,
}

newEffect{
	name = "CUT",
	desc = "Bleeding",
	long_desc = function(self, eff) return ("Huge cut that bleeds blood, doing %d damage per turn."):format((eff.dur > 200) and 3 or ((eff.dur > 100) and 2 or 1)) end,
	type = "physical",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# starts to bleed.", "+Bleeds" end,
	on_lose = function(self, err) return "#Target# stops bleeding.", "-Bleeds" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = old_eff.dur + new_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local dam = (eff.dur > 200) and 3 or ((eff.dur > 100) and 2 or 1)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, dam)
	end,
}
