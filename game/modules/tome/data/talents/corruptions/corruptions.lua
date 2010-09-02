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
newTalentType{ no_silence=true, type="corruption/sanguisuge", name = "sanguisuge", generic = true, description = "Manipulate the life force to power your own dark powers." }
newTalentType{ no_silence=true, type="corruption/bone", name = "bone", description = "Harness the power of bones." }
newTalentType{ no_silence=true, type="corruption/hexes", name = "hexes", description = "Hex your foes, hindering and crippling them." }
newTalentType{ no_silence=true, type="corruption/curses", name = "curses", description = "Curse your foes, hindering and crippling them." }
newTalentType{ no_silence=true, type="corruption/plague", name = "plage", description = "Spread diseases to your foes." }
newTalentType{ no_silence=true, type="corruption/scourge", name = "scourge", description = "Bring pain and destruction to the world." }
newTalentType{ no_silence=true, type="corruption/reaving-combat", name = "reaving combat", description = "Enhanced melee combat through the dark arts." }

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
str_corrs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_corrs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_corrs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_corrs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_corrs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/corruptions/sanguisuge.lua")
load("/data/talents/corruptions/scourge.lua")
load("/data/talents/corruptions/plague.lua")
load("/data/talents/corruptions/reaving-combat.lua")
load("/data/talents/corruptions/bone.lua")
load("/data/talents/corruptions/curses.lua")
load("/data/talents/corruptions/hexes.lua")
