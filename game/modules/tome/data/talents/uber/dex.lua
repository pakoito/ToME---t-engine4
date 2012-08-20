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

uberTalent{
	name = "Through The Crowd",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("bump_swap_speed_divide", 10)
	end,
	on_unlearn = function(self, t)
		self:attr("bump_swap_speed_divide", -10)
	end,
	require = { special={desc="Have had at least 6 party members at the same time.", fct=function(self)
		return self:attr("huge_party")
	end} },
	info = function(self, t)
		return ([[You are used to a crowded party, you can swap place with friendly creatures for only one tenth of a turn.]])
		:format()
	end,
}
