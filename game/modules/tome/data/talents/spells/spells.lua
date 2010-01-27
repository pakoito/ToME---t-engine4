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
newTalentType{ type="spell/necromancy", name = "necromancy", description = "Necromancy is a dark school of magic dealing with death, and undeath." }

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
load("/data/talents/spells/necromancy.lua")
