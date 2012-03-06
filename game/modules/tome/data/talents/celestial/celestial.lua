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

-- Corruptions
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/guardian", name = "guardian", min_lev = 10, description = "Your devotion grants you additional protection." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/chants", name = "chants", generic = true, description = "Chant the glory of the sun." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/light", name = "light", generic = true, description = "Invoke the power of light to heal and mend." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/combat", name = "combat", description = "Your devotion allows you to combat your foes with indomitable determination." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/sun", name = "sun", description = "Summon the power of the Sun to burn your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/glyphs", name = "glyphs", min_lev = 10, description = "Bind the holy powers into glyphs to trap your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/twilight", name = "twilight", description = "Stand between the darkness and the light, harnessing both." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/star-fury", name = "star fury", description = "Call fury of the stars and moon to destroy your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/hymns", name = "hymns", generic = true, description = "Chant the glory of the moon." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/circles", name = "circles", min_lev = 10, description = "Bind the power of the moon into circles at your feet." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/eclipse", name = "eclipse", description = "The moment of the Eclipse is the moment of Truth, when Sun and Moon are in tandem and the energies of the world hang in balance. Intense focus allows the greatest Anorithils to harness these energies to unleash devastating forces.." }


newTalentType{ no_silence=true, is_spell=true, type="celestial/other", name = "other", description = "Various celestial talents." }

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
divi_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
divi_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
divi_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
divi_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
divi_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/celestial/chants.lua")
load("/data/talents/celestial/sun.lua")
load("/data/talents/celestial/combat.lua")
load("/data/talents/celestial/light.lua")
load("/data/talents/celestial/glyphs.lua")
load("/data/talents/celestial/guardian.lua")

load("/data/talents/celestial/twilight.lua")
load("/data/talents/celestial/hymns.lua")
load("/data/talents/celestial/star-fury.lua")
load("/data/talents/celestial/eclipse.lua")
load("/data/talents/celestial/circles.lua")
