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

-- Random escort
id = "escort-duty-"..game.zone.short_name.."-"..game.level.level

kind = {}

name = ""
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Escort"
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.on_grant = nil
	local types = {
		{ name="warrior",
			types = {
				["technique/combat-training"] = 0.7,
				["technique/combat-techniques-active"] = 0.7,
				["technique/combat-techniques-passive"] = 0.7,
			},
			talents =
			{
				[who.T_RUSH] = 1,
			},
			stats =
			{
				[who.STAT_STR] = 2,
				[who.STAT_DEX] = 1,
				[who.STAT_CON] = 2,
			}
		},
	}
end
