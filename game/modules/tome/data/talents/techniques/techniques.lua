-- Physical combat
newTalentType{ type="technique/2hweapon", name = "two handed weapons", description = "Allows the user to be more proficient with two handed weapons." }
newTalentType{ type="technique/dualweapon", name = "dual wielding", description = "Allows the user to be more proficient with dual wielding weapons." }
newTalentType{ type="technique/shield", name = "weapon and shields", description = "Allows the user to be more proficient with shields and one handed weapons." }
newTalentType{ type="technique/weapon-training", name = "weapon-training", description = "Grants bonuses to the different weapon types." }
newTalentType{ type="technique/combat-training", name = "combat-training", description = "Teaches to use various armors and improves health." }

load("/data/talents/techniques/2hweapon.lua")
load("/data/talents/techniques/dualweapon.lua")
load("/data/talents/techniques/weaponshield.lua")
load("/data/talents/techniques/weapon-training.lua")
load("/data/talents/techniques/combat-training.lua")
