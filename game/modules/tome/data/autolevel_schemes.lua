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

local Autolevel = require "engine.Autolevel"

Autolevel:registerScheme{ name = "none", levelup = function(self)
end}

Autolevel:registerScheme{ name = "warrior", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_STR, self.STAT_DEX }
end}

Autolevel:registerScheme{ name = "ghoul", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_CON }
end}

Autolevel:registerScheme{ name = "zerker", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_STR, self.STAT_CON }
end}

Autolevel:registerScheme{ name = "tank", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_CON, self.STAT_CON }
end}

Autolevel:registerScheme{ name = "rogue", levelup = function(self)
	self:learnStats{ self.STAT_DEX, self.STAT_CUN, self.STAT_CUN }
end}

Autolevel:registerScheme{ name = "slinger", levelup = function(self)
	self:learnStats{ self.STAT_DEX, self.STAT_DEX, self.STAT_CUN }
end}

Autolevel:registerScheme{ name = "archer", levelup = function(self)
	self:learnStats{ self.STAT_DEX, self.STAT_DEX, self.STAT_STR }
end}

Autolevel:registerScheme{ name = "caster", levelup = function(self)
	self:learnStats{ self.STAT_MAG, self.STAT_MAG, self.STAT_WIL }
end}

Autolevel:registerScheme{ name = "warriormage", levelup = function(self)
	self:learnStats{ self.STAT_MAG, self.STAT_MAG, self.STAT_WIL, self.STAT_STR, self.STAT_STR, self.STAT_DEX }
end}

Autolevel:registerScheme{ name = "roguemage", levelup = function(self)
	self:learnStats{ self.STAT_CUN, self.STAT_DEX, self.STAT_CUN, self.STAT_MAG }
end}

Autolevel:registerScheme{ name = "dexmage", levelup = function(self)
	self:learnStats{ self.STAT_MAG, self.STAT_MAG, self.STAT_DEX, self.STAT_DEX }
end}

Autolevel:registerScheme{ name = "snake", levelup = function(self)
	self:learnStats{ self.STAT_CUN, self.STAT_DEX, self.STAT_CON, self.STAT_CUN, self.STAT_DEX, self.STAT_STR }
end}

Autolevel:registerScheme{ name = "spider", levelup = function(self)
	self:learnStats{ self.STAT_CUN, self.STAT_WIL, self.STAT_MAG, self.STAT_DEX, self.STAT_DEX }
end}

Autolevel:registerScheme{ name = "alchemy-golem", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_STR, self.STAT_DEX, self.STAT_CON }
end}

Autolevel:registerScheme{ name = "drake", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_STR, self.STAT_WIL, self.STAT_WIL, self.STAT_CON, self.STAT_DEX }
end}

Autolevel:registerScheme{ name = "wildcaster", levelup = function(self)
	self:learnStats{ self.STAT_WIL, self.STAT_WIL, self.STAT_CUN }
end}

Autolevel:registerScheme{ name = "summoner", levelup = function(self)
	self:learnStats{ self.STAT_WIL, self.STAT_CUN }
end}

Autolevel:registerScheme{ name = "wyrmic", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_WIL, self.STAT_DEX, self.STAT_CUN }
end}

Autolevel:registerScheme{ name = "warriorwill", levelup = function(self)
	self:learnStats{ self.STAT_STR, self.STAT_WIL, self.STAT_STR, self.STAT_WIL, self.STAT_DEX, }
end}

Autolevel:registerScheme{ name = "random_boss", levelup = function(self)
	pcall(function() self:learnStats(self.auto_stats) end)
end}
