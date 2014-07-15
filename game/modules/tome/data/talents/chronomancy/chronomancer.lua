-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- Class Trees
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/blade-threading", name = "Blade Threading", description = "A blend of chronomancy and dual-weapon combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/bow-threading", name = "Bow Threading", description = "A blend of chronomancy and ranged combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/guardian", name = "Temporal Guardian", description = "Warden combat training and techniques." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/threaded-combat", name = "Threaded Combat", min_lev = 10, description = "A blend of ranged and dual-weapon combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-hounds", name = "Temporal Hounds", min_lev = 10, description = "Call temporal hounds to aid you in combat." }

newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/energy", name = "energy", generic = true, description = "Manipulate raw energy by addition or subtraction." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/fate-threading", name = "Fate Threading", description = "Manipulate the threads of fate." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/gravity", name = "gravity", description = "Call upon the force of gravity to crush, push, and pull your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/matter", name = "matter", description = "Change and shape matter itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/paradox", name = "paradox", min_lev = 10, description = "Create loopholes in the laws of spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/speed-control", name = "Speed Control", description = "Control how fast objects and creatures move through spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timeline-threading", name = "Timeline Threading", min_lev = 10, description = "Examine and alter the timelines that make up the spacetime continuum." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timetravel", name = "Time Travel", min_lev = 10, description = "Travel through time yourself, or send your foes into the future." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-folding", name = "Spacetime Folding", description = "Mastery of folding points in space." }

-- Generic Chronomancy
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/chronomancy", name = "Chronomancy", generic = true, description = "Allows you to glimpse the future, or become more aware of the present." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/fate-weaving", name = "Fate Weaving", generic = true, description = "Weave the threads of fate." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-weaving", name = "Spacetime Weaving", generic = true, description = "Weave the threads of spacetime." }

-- Misc and Outdated Trees
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/other", name = "Other", generic = true, description = "Miscellaneous Chronomancy effects." }

newTalentType{ no_silence=true, is_spell=true, type="chronomancy/age-manipulation", name = "Age Manipulation", description = "Manipulate the age of creatures you encounter." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/temporal-archery", name = "Temporal Archery", description = "A blend of chronomancy and ranged combat." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/temporal-combat", name = "Temporal Combat", description = "A blend of chronomancy and physical combat." }



-- Anomalies are not learnable but can occur instead of an intended spell when paradox gets to high.
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/anomalies", name = "anomalies", description = "Spacetime anomalies that can randomly occur when paradox is to high." }

-- Generic requires for chronomancy spells based on talent level
chrono_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
chrono_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
chrono_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
chrono_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
chrono_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

chrono_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
chrono_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
chrono_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
chrono_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
chrono_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-- Generic requires for non-spell temporal effects based on talent level
temporal_req1 = {
	stat = { wil=function(level) return 12 + (level-1)*2 end},
	level = function(level) return 0 + (level-1) end,
}
temporal_req2 = {
	stat = { wil=function(level) return 20 + (level-1)*2 end},
	level = function(level) return 4 + (level-1) end,
}
temporal_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
temporal_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
temporal_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/chronomancy/age-manipulation.lua")
load("/data/talents/chronomancy/blade-threading.lua")
load("/data/talents/chronomancy/bow-threading.lua")
load("/data/talents/chronomancy/chronomancy.lua")
load("/data/talents/chronomancy/energy.lua")
load("/data/talents/chronomancy/fate-threading.lua")
load("/data/talents/chronomancy/fate-weaving.lua")
load("/data/talents/chronomancy/gravity.lua")
load("/data/talents/chronomancy/matter.lua")
load("/data/talents/chronomancy/paradox.lua")
load("/data/talents/chronomancy/speed-control.lua")
load("/data/talents/chronomancy/temporal-archery.lua")
load("/data/talents/chronomancy/temporal-combat.lua")
load("/data/talents/chronomancy/guardian.lua")
load("/data/talents/chronomancy/temporal-hounds.lua")
load("/data/talents/chronomancy/threaded-combat.lua")
load("/data/talents/chronomancy/timeline-threading.lua")
load("/data/talents/chronomancy/timetravel.lua")
load("/data/talents/chronomancy/spacetime-folding.lua")
load("/data/talents/chronomancy/spacetime-weaving.lua")

-- Loads many functions and misc. talents
load("/data/talents/chronomancy/other.lua")

-- Anomalies, not learnable talents that may be cast instead of the intended spell when paradox gets to high
load("/data/talents/chronomancy/anomalies.lua")