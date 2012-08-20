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

newTalentType{ type="uber/uber", name = "uber", description = "Ultimate talents you may only know one." }


uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.level = 40
	t.require.stat = t.require.stat or {}
	t.require.stat.str = 80
	newTalent(t)
end
load("/data/talents/uber/str.lua")

uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 40
	t.require.stat.dex = 80
	newTalent(t)
end
load("/data/talents/uber/dex.lua")

uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 40
	t.require.stat.con = 80
	newTalent(t)
end
load("/data/talents/uber/const.lua")

uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 40
	t.require.stat.mag = 80
	newTalent(t)
end
load("/data/talents/uber/mag.lua")

uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.level = 40
	t.require.stat = t.require.stat or {}
	t.require.stat.wil = 80
	newTalent(t)
end
load("/data/talents/uber/wil.lua")

uberTalent = function(t)
	t.type = {"uber/uber", 1}
	t.require = t.require or {}
	t.require.level = 40
	t.require.stat = t.require.stat or {}
	t.require.stat.cun = 80
	newTalent(t)
end
load("/data/talents/uber/cun.lua")
