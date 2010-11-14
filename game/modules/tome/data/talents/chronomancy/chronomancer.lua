-- ToME - Tales of Maj'Eyal
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

-- Paradox Mage SpellsnewTalentType
newTalentType{ no_silence=true, type="chronomancy/advanced-timetravel", name = "Advanced Time Travel", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/chronomancy", name = "chronomancy", generic = true, description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/energy", name = "energy", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/entropy", name = "entropy", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/gravity", name = "gravity", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/inertia", name = "inertia", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/matter", name = "matter", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/paradox", name = "paradox", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/probability", name = "probability", generic = true, description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/temporal-combat", name = "Temporal Combat", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/threading", name = "threading", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/timetravel", name = "Time Travel", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ no_silence=true, type="chronomancy/weaving", name = "weaving", generic = true, description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }


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

-- Backfire Function

checkBackfire = function(self, x, y)
	local backfire = math.pow (((self:getParadox() - self:getWil())/300), 3)
	print("[Paradox] Backfire chance: ", backfire, "::", self:getParadox())
	if rng.percent(backfire) then
		game.logPlayer(self, "The fabric of spacetime ripples and your spell backfires!!")
		return self.x, self.y
	else
		return x, y
	end
end

getParadoxModifier = function (self, pm)
	local pm = (1 + (self:getParadox()/300))/2
		return pm
end

load("/data/talents/chronomancy/advanced-timetravel.lua")
load("/data/talents/chronomancy/chronomancy.lua")
load("/data/talents/chronomancy/energy.lua")
load("/data/talents/chronomancy/entropy.lua")
load("/data/talents/chronomancy/gravity.lua")
load("/data/talents/chronomancy/inertia.lua")
load("/data/talents/chronomancy/matter.lua")
load("/data/talents/chronomancy/paradox.lua")
load("/data/talents/chronomancy/probability.lua")
load("/data/talents/chronomancy/temporal-combat.lua")
load("/data/talents/chronomancy/threading.lua")
load("/data/talents/chronomancy/timetravel.lua")
load("/data/talents/chronomancy/weaving.lua")
