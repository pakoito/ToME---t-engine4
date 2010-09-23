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

-- Physical combat
newTalentType{ type="technique/2hweapon-offense", name = "two-handed weapons", description = "Specialized two-handed techniques." }
newTalentType{ type="technique/2hweapon-cripple", name = "two-handed weapons", description = "Specialized two-handed techniques." }
newTalentType{ type="technique/shield-offense", name = "weapons and shields", description = "Specialized weapon and shield techniques." }
newTalentType{ type="technique/shield-defense", name = "weapons and shields", description = "Specialized weapon and shield techniques." }
newTalentType{ type="technique/dualweapon-training", name = "dual wielding", description = "Specialized dual wielding techniques." }
newTalentType{ type="technique/dualweapon-attack", name = "dual wielding", description = "Specialized dual wielding techniques." }
newTalentType{ type="technique/archery-base", name = "archery - base", description = "Ability to shoot, you should never this this." }
newTalentType{ type="technique/archery-bow", name = "archery - bows", description = "Specialized bow techniques." }
newTalentType{ type="technique/archery-sling", name = "archery - slings", description = "Specialized sling techniques." }
newTalentType{ type="technique/archery-training", name = "archery - common", description = "Generic archery techniques." }
newTalentType{ type="technique/archery-utility", name = "archery - utility", description = "Specialized archery techniques to maim your targets." }
newTalentType{ type="technique/superiority", name = "superiority", description = "Advanced combat techniques." }
newTalentType{ type="technique/warcries", name = "warcries", description = "Master the warcries to improve yourself and weaken others." }
newTalentType{ type="technique/bloodthirst", name = "bloodthirst", description = "Delight in the act of battle and the spilling of blood." }
newTalentType{ type="technique/field-control", name = "field control", generic = true, description = "Control the battlefield using various techniques." }
newTalentType{ type="technique/combat-techniques-active", name = "combat techniques", description = "Generic combat oriented techniques." }
newTalentType{ type="technique/combat-techniques-passive", name = "combat techniques", description = "Generic combat oriented techniques." }
newTalentType{ type="technique/combat-training", name = "combat training", generic = true, description = "Teaches to use various armors and improves health." }
newTalentType{ type="technique/magical-combat", name = "magical combat", description = "The blending together of magic and melee prowess." }

-- Generic requires for techs based on talent level
-- Uses STR
techs_req1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_req2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_req3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_req4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_req5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end
techs_req_high1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
} end
techs_req_high2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
} end
techs_req_high3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
} end
techs_req_high4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
} end
techs_req_high5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
} end

-- Generic requires for techs_dex based on talent level
techs_dex_req1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_dex_req2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_dex_req3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_dex_req4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_dex_req5 = {
	stat = { dex=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Generic rquires based either on str or dex
techs_strdex_req1 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_strdex_req2 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_strdex_req3 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_strdex_req4 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_strdex_req5 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end

load("/data/talents/techniques/2hweapon.lua")
load("/data/talents/techniques/dualweapon.lua")
load("/data/talents/techniques/weaponshield.lua")
load("/data/talents/techniques/superiority.lua")
load("/data/talents/techniques/warcries.lua")
load("/data/talents/techniques/bloodthirst.lua")
load("/data/talents/techniques/field-control.lua")
load("/data/talents/techniques/combat-techniques.lua")
load("/data/talents/techniques/combat-training.lua")
load("/data/talents/techniques/bow.lua")
load("/data/talents/techniques/sling.lua")
load("/data/talents/techniques/archery.lua")
load("/data/talents/techniques/magical-combat.lua")
