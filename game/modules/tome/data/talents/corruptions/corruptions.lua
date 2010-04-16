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

-- Corruptions
newTalentType{ type="corruption/ritual", name = "blighted rituals", description = "Learn how to control the dark powers." }
newTalentType{ type="corruption/blight-magic", name = "blight magic", description = "Control the corruptions to form dark spells." }
newTalentType{ type="corruption/blighted-combat", name = "blighted combat", description = "Control the corruptions to enhance melee combat." }
newTalentType{ type="corruption/diseases", name = "deseases", description = "The subtle art of diseases and rotting." }
newTalentType{ type="corruption/blood-magic", name = "blood magic", description = "Allows to take control of the blood, both yours or your foes." }
newTalentType{ type="corruption/necromancy", name = "necromancy", description = "The dark art of raising undeads." }

-- Generic requires for corruptions based on talent level
corrs_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
corrs_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
corrs_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
corrs_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
corrs_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/corruptions/rituals.lua")
