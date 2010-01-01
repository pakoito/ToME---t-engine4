-- Physical combat
newTalentType{ type="physical/2hweapon", name = "two handed weapons", description = "Allows the user to be more proficient with two handed weapons." }
newTalentType{ type="physical/dualweapon", name = "dual wielding", description = "Allows the user to be more proficient with dual wielding weapons." }
newTalentType{ type="physical/shield", name = "weapon and shields", description = "Allows the user to be more proficient with shields and one handed weapons." }
newTalentType{ type="physical/dirty", name = "dirty fighting", description = "Teaches various physical talents to criple your foes." }
newTalentType{ type="physical/weapon-training", name = "weapon-training", description = "Grants bonuses to the different weapon types." }
newTalentType{ type="physical/combat-training", name = "combat-training", description = "Teaches to use various armors and improves health." }

load("/data/talents/physical/2hweapon.lua")
load("/data/talents/physical/dualweapon.lua")
load("/data/talents/physical/weaponshield.lua")
load("/data/talents/physical/dirty.lua")
load("/data/talents/physical/weapon-training.lua")
load("/data/talents/physical/combat-training.lua")
