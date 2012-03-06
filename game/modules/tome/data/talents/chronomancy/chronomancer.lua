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

-- Paradox Mage SpellsnewTalentType
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/age-manipulation", name = "Age Manipulation", description = "Manipulate the age of creatures you encounter." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/chronomancy", name = "chronomancy", generic = true, description = "Allows you to glimpse the future or become more aware of the present." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/energy", name = "energy", generic = true, description = "Manipulate raw energy by addition or subtraction." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/gravity", name = "gravity", description = "Call upon the force of gravity to crush, push, and pull your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/matter", name = "matter", description = "Change and shape matter itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/paradox", name = "paradox", min_lev = 10, description = "Create loopholes in the laws of spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/speed-control", name = "Speed Control", description = "Control how fast objects and creatures move through spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-combat", name = "Temporal Combat", description = "A blend of chronomancy and physical combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timeline-threading", name = "Timeline Threading", min_lev = 10, description = "Examine and alter the timelines that make up the spacetime continuum." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timetravel", name = "Time Travel", description = "Travel through time yourself or send your foes into the future.." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-folding", name = "Spacetime Folding", description = "Mastery of folding points in space." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-weaving", name = "Spacetime Weaving", generic = true, description = "Weave the threads of spacetime and correct the damage you've caused through your meddling." }


newTalentType{ no_silence=true, is_spell=true, type="chronomancy/temporal-archery", name = "Temporal Archery", description = "A blend of chronomancy and ranged combat." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/other", name = "Other", generic = true, description = "Miscellaneous Chronomancy effects." }


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

-- Backfire Function; this does the actual backfire even though the chance is calculated in Actor
checkBackfire = function(self, x, y)
	if self:paradoxBackfireChance() and not self:attr("no_paradox_fail") then
		game.logPlayer(self, "The fabric of spacetime ripples and your spell backfires!!")
		return self.x, self.y
	else
		return x, y
	end
end

-- Make sure we don't run concurrent chronoworlds; to prevent lag and possible game breaking bugs or exploits
checkTimeline = function(self)
	if game._chronoworlds  == nil then
		return false
	else
		game.logPlayer(self, "The timeline is too fractured right now to use this ability.")
		return true
	end
end

-- Paradox modifier.  This controls how much extra effect chronomancy spells have at high paradox.
-- Note that 300 is the optimal balance and going below this number will decrease the effect of chronomancy spells.
getParadoxModifier = function (self, pm)
	local pm = math.sqrt((1 + (self:getParadox()/300))/2)
	return pm
end

load("/data/talents/chronomancy/age-manipulation.lua")
load("/data/talents/chronomancy/chronomancy.lua")
load("/data/talents/chronomancy/energy.lua")
load("/data/talents/chronomancy/gravity.lua")
load("/data/talents/chronomancy/matter.lua")
load("/data/talents/chronomancy/paradox.lua")
load("/data/talents/chronomancy/speed-control.lua")
load("/data/talents/chronomancy/temporal-archery.lua")
load("/data/talents/chronomancy/temporal-combat.lua")
load("/data/talents/chronomancy/timeline-threading.lua")
load("/data/talents/chronomancy/timetravel.lua")
load("/data/talents/chronomancy/spacetime-folding.lua")
load("/data/talents/chronomancy/spacetime-weaving.lua")

-- Anomalies, not learnable talents that may be cast instead of the intended spell when paradox gets to high
load("/data/talents/chronomancy/anomalies.lua")