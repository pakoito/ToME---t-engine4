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

local Autolevel = require "engine.Autolevel"

local function learnStats(self, statorder)
	self.auto_stat_cnt = self.auto_stat_cnt or 1
	while self.unused_stats > 0 do
		self:incStat(statorder[self.auto_stat_cnt], 1)
		self.auto_stat_cnt = util.boundWrap(self.auto_stat_cnt + 1, 1, #statorder)
		self.unused_stats = self.unused_stats - 1
	end
end

Autolevel:registerScheme{ name = "none", levelup = function(self)
end}

Autolevel:registerScheme{ name = "warrior", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_STR, self.STAT_DEX })
end}

Autolevel:registerScheme{ name = "ghoul", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_CON })
end}

Autolevel:registerScheme{ name = "tank", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_CON, self.STAT_CON })
end}

Autolevel:registerScheme{ name = "rogue", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_CUN, self.STAT_CUN })
end}

Autolevel:registerScheme{ name = "slinger", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_DEX, self.STAT_CUN })
end}

Autolevel:registerScheme{ name = "archer", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_DEX, self.STAT_STR })
end}

Autolevel:registerScheme{ name = "caster", levelup = function(self)
	learnStats(self, { self.STAT_MAG, self.STAT_MAG, self.STAT_WIL })
end}

Autolevel:registerScheme{ name = "warriormage", levelup = function(self)
	learnStats(self, { self.STAT_MAG, self.STAT_MAG, self.STAT_WIL, self.STAT_STR, self.STAT_STR, self.STAT_DEX })
end}

Autolevel:registerScheme{ name = "snake", levelup = function(self)
	learnStats(self, { self.STAT_CUN, self.STAT_DEX, self.STAT_CON, self.STAT_CUN, self.STAT_DEX, self.STAT_STR })
end}
