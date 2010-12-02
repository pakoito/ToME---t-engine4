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

-- Archmage spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/arcane", name = "arcane", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }

-- Elemental spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/fire", name = "fire", description = "Harness the power of fire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/wildfire", name = "wildfire", description = "Harness the power of wildfire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/earth", name = "earth", description = "Harness the power of the earth to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone", name = "stone", description = "Harness the power of the stone to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/water", name = "water", description = "Harness the power of water to drown your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/ice", name = "ice", description = "Harness the power of ice to freeze and shatter your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/air", name = "air", description = "Harness the power of the air to fry your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/storm", name = "storm", description = "Harness the power of the storm to incinerate your foes." }

-- Various other magic schools
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/meta", name = "meta", description = "Meta spells alter the working of magic itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/temporal", name = "temporal", description = "The school of time manipulation." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/phantasm", name = "phantasm", description = "Control the power of tricks and illusions." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/enhancement", name = "enhancement", description = "Magical enhancement of your body." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/conveyance", name = "conveyance", generic = true, description = "Conveyance is the school of travel. It allows you to travel faster and to track others." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/divination", name = "divination", generic = true, description = "Divination allows the caster to sense its surroundings, find hidden things." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/nature", name = "nature", generic = true, description = "Summons the power of nature to rejuvenate yourself and the world." }

-- Alchemist spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/explosives", name = "explosive admixtures", description = "Manipulate gems to turn them into explosive magical bombs." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/infusion", name = "infusion", description = "Infusion your gem bombs with the powers of the elements." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/golemancy-base", name = "golemancy", hide = true, description = "Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/golemancy", name = "golemancy", description = "Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/advanced-golemancy", name = "advanced-golemancy", description = "Advanced golem operations." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/fire-alchemy", name = "fire alchemy", description = "Alchemical control over fire.é" }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy-base", name = "stone alchemy", hide = true, description = "Manipulate gems, imbue their powers into other objects." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy", name = "stone alchemy", generic = true, description = "Alchemical control over stone and gems." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/staff-combat", name = "staff combat", generic = true, description = "Harness the power of magical staves." }

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
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/spells/arcane.lua")
load("/data/talents/spells/fire.lua")
load("/data/talents/spells/wildfire.lua")
load("/data/talents/spells/earth.lua")
load("/data/talents/spells/stone.lua")
load("/data/talents/spells/water.lua")
load("/data/talents/spells/ice.lua")
load("/data/talents/spells/air.lua")
load("/data/talents/spells/storm.lua")
load("/data/talents/spells/conveyance.lua")
load("/data/talents/spells/nature.lua")
load("/data/talents/spells/meta.lua")
load("/data/talents/spells/divination.lua")
load("/data/talents/spells/temporal.lua")
load("/data/talents/spells/phantasm.lua")
load("/data/talents/spells/enhancement.lua")

load("/data/talents/spells/explosives.lua")
load("/data/talents/spells/infusion.lua")
load("/data/talents/spells/golemancy.lua")
load("/data/talents/spells/advanced-golemancy.lua")
load("/data/talents/spells/staff-combat.lua")
load("/data/talents/spells/fire-alchemy.lua")
load("/data/talents/spells/stone-alchemy.lua")
