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

-- Cunning talents
newTalentType{ type="cunning/stealth", name = "stealth", description = "Allows the user to enter stealth." }
newTalentType{ type="cunning/trapping", name = "trapping", description = "The knowledge of trap laying." }
newTalentType{ type="cunning/dirty", name = "dirty fighting", description = "Teaches various talents to criple your foes." }
newTalentType{ type="cunning/lethality", name = "lethality", description = "How to make your foes feel the pain." }
newTalentType{ type="cunning/survival", name = "survival", description = "The knowledge of the dangers of the world, and how to best avoid them." }

-- Generic requires for cunning based on talent level
cuns_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cuns_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cuns_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cuns_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cuns_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/cunning/stealth.lua")
load("/data/talents/cunning/traps.lua")
load("/data/talents/cunning/dirty.lua")
load("/data/talents/cunning/lethality.lua")
load("/data/talents/cunning/survival.lua")
