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

-- Corruptions
newTalentType{ type="divine/chants", name = "chants", description = "Chant the glory of the sun." }
newTalentType{ type="divine/light", name = "light", description = "Invoke the power of light to heal and mend." }
newTalentType{ type="divine/combat", name = "combat", description = "Your devotion allows you to combat your foes with indomitable determination." }
newTalentType{ type="divine/sun", name = "sun", description = "Summon the power of the Sun to burn your foes." }
newTalentType{ type="divine/glyphs", name = "glyphs", description = "Bind the holy powers into glyphs to trap your foes." }

-- Generic requires for corruptions based on talent level
divi_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
divi_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
divi_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
divi_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
divi_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/divine/chants.lua")
load("/data/talents/divine/sun.lua")
load("/data/talents/divine/combat.lua")
load("/data/talents/divine/light.lua")
