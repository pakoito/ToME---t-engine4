-- Physical combat
newTalentType{ type="technique/2hweapon-offense", name = "two handed weapons", description = "Specialized two handed techniques." }
newTalentType{ type="technique/2hweapon-cripple", name = "two handed weapons", description = "Specialized two handed techniques." }
newTalentType{ type="technique/shield-offense", name = "weapon and shields", description = "Specialized weapon and shield techniques." }
newTalentType{ type="technique/shield-defense", name = "weapon and shields", description = "Specialized weapon and shield techniques." }
newTalentType{ type="technique/dualweapon", name = "dual wielding", description = "Specialized dual wielding techniques." }
newTalentType{ type="technique/weapon-training", name = "weapon-training", description = "Grants bonuses to the different weapon types." }
newTalentType{ type="technique/combat-training", name = "combat-training", description = "Teaches to use various armors and improves health." }

-- Generic requires for techs based on talent level
techs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Generic requires for techs_dex based on talent level
techs_dex_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_dex_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_dex_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_dex_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_dex_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/techniques/2hweapon.lua")
load("/data/talents/techniques/dualweapon.lua")
load("/data/talents/techniques/weaponshield.lua")
load("/data/talents/techniques/weapon-training.lua")
load("/data/talents/techniques/combat-training.lua")
