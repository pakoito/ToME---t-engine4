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

-- Spells
newTalentType{ type="spell/arcane", name = "arcane", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ type="spell/fire", name = "fire", description = "Harness the power of fire to burn your foes to ashes." }
newTalentType{ type="spell/earth", name = "earth", description = "Harness the power of the earth to protect and destroy." }
newTalentType{ type="spell/water", name = "water", description = "Harness the power of water to drown your foes." }
newTalentType{ type="spell/air", name = "air", description = "Harness the power of the air to fry your foes." }
newTalentType{ type="spell/conveyance", name = "conveyance", description = "Conveyance is the school of travel. It allows you to travel faster and to track others." }
newTalentType{ type="spell/nature", name = "nature", description = "Summons the power of nature to rejuvenate yourself and the world." }
newTalentType{ type="spell/meta", name = "meta", description = "Meta spells alter the working of magic itself." }
newTalentType{ type="spell/divination", name = "divination", description = "Divination allows the caster to sense its surroundings, find hidden things." }
newTalentType{ type="spell/temporal", name = "temporal", description = "Temporal the school of time manipulation." }
newTalentType{ type="spell/phantasm", name = "phantasm", description = "Control the power of tricks and illusions." }
newTalentType{ type="spell/enhancement", name = "enhancement", description = "Enhance your own body." }

-- Generic requires for spells based on talent level
spells_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
spells_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
spells_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
spells_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
spells_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/spells/arcane.lua")
load("/data/talents/spells/fire.lua")
load("/data/talents/spells/earth.lua")
load("/data/talents/spells/water.lua")
load("/data/talents/spells/air.lua")
load("/data/talents/spells/conveyance.lua")
load("/data/talents/spells/nature.lua")
load("/data/talents/spells/meta.lua")
load("/data/talents/spells/divination.lua")
load("/data/talents/spells/temporal.lua")
load("/data/talents/spells/phantasm.lua")
load("/data/talents/spells/enhancement.lua")
