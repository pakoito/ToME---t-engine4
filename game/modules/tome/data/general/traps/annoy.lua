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

newEntity{ define_as = "TRAP_ANNOY",
	type = "annoy", subtype="annoy", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function() end,
}

newEntity{ base = "TRAP_ANNOY",
	name = "lethargy trap", auto_id = true, image = "trap/trap_lethargy_rune_01.png",
	detect_power = 20, disarm_power = 36,
	rarity = 3, level_range = {1, 50},
	color=colors.BLUE,
	message = "@Target@ seems less active.",
	triggered = function(self, x, y, who)
		local tids = {}
		for tid, lev in pairs(who.talents) do
			local t = who:getTalentFromId(tid)
			if not who.talents_cd[tid] and t.mode == "activated" then tids[#tids+1] = tid end
		end
		for i = 1, 3 do
			local tid = rng.tableRemove(tids)
			if not tid then break end
			who.talents_cd[tid] = rng.range(4, 7)
		end
		who.changed = true
		return true, true
	end
}

newEntity{ base = "TRAP_ANNOY",
	name = "burning curse trap", auto_id = true, image = "trap/trap_burning_curse_01.png",
	detect_power = 50, disarm_power = 58,
	rarity = 3, level_range = {30, 50},
	color=colors.ORCHID,
	message = "@Target@ triggers a burning curse!",
	dam = resolvers.mbonus(80, 5),
	pressure_trap = true,
	triggered = function(self, x, y, who)
		who:setEffect(who.EFF_BURNING_HEX, 7, {src=self, dam=self.dam, power=1+(self.dam/100)})
		return true, true
	end
}
