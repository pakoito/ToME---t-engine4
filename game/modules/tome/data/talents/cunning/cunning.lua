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

-- Cunning talents
newTalentType{ allow_random=true, type="cunning/stealth-base", name = "stealth", description = "Allows the user to enter stealth." }
newTalentType{ allow_random=true, type="cunning/stealth", name = "stealth", description = "Allows the user to enter stealth." }
newTalentType{ allow_random=true, type="cunning/trapping", name = "trapping", description = "The knowledge of trap laying and assorted trickeries." }
newTalentType{ allow_random=true, type="cunning/traps", name = "traps", description = "Collection of known traps." }
newTalentType{ allow_random=true, type="cunning/poisons", name = "poisons", min_lev = 10, description = "The knowledge of poisons and how to apply them to 'good' effects." }
newTalentType{ allow_random=true, type="cunning/poisons-effects", name = "poisons", description = "Collection of known poisons." }
newTalentType{ allow_random=true, type="cunning/dirty", name = "dirty fighting", description = "Teaches various talents to cripple your foes." }
newTalentType{ allow_random=true, type="cunning/lethality", name = "lethality", description = "How to make your foes feel the pain." }
newTalentType{ allow_random=true, type="cunning/shadow-magic", name = "shadow magic", description = "Blending magic and shadows." }
newTalentType{ allow_random=true, type="cunning/ambush", name = "ambush", min_lev = 10, description = "Using darkness and a bit of magic you manipulate the shadows." }
newTalentType{ allow_random=true, type="cunning/survival", name = "survival", generic = true, description = "The knowledge of the dangers of the world, and how to best avoid them." }
newTalentType{ allow_random=true, type="cunning/tactical", name = "tactical", description = "Tactical combat abilities." }
newTalentType{ allow_random=true, type="cunning/scoundrel", name = "scoundrel", generic = true, description = "The use of ungentlemanly techniques." }

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
cuns_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cuns_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cuns_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cuns_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cuns_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/cunning/stealth.lua")
load("/data/talents/cunning/traps.lua")
load("/data/talents/cunning/poisons.lua")
load("/data/talents/cunning/dirty.lua")
load("/data/talents/cunning/lethality.lua")
load("/data/talents/cunning/tactical.lua")
load("/data/talents/cunning/survival.lua")
load("/data/talents/cunning/shadow-magic.lua")
load("/data/talents/cunning/ambush.lua")
load("/data/talents/cunning/scoundrel.lua")
