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

-- Cursed
newTalentType{ allow_random=true, type="cursed/slaughter", name = "slaughter", description = "Your weapon yearns for its next victim." }
newTalentType{ allow_random=true, type="cursed/endless-hunt", name = "endless hunt", description = "Each day you lift your weary body and begin the unending hunt." }
newTalentType{ allow_random=true, type="cursed/strife", name = "strife", description = "The battlefield is your home; death and confusion, your comfort." }
newTalentType{ allow_random=true, type="cursed/gloom", name = "gloom", description = "All those in your sight must share your despair." }
newTalentType{ allow_random=true, type="cursed/rampage", name = "rampage", description = "Let loose the hate that has grown within." }
newTalentType{ allow_random=true, type="cursed/predator", name = "predator", description = "Track and kill your prey with single-minded focus." }

-- Doomed
newTalentType{ allow_random=true, type="cursed/dark-sustenance", name = "dark sustenance", generic = true, description = "Invoke the powerful force of your will." }
newTalentType{ allow_random=true, type="cursed/force-of-will", name = "force of will", description = "Invoke the powerful force of your will." }
newTalentType{ allow_random=true, type="cursed/darkness", name = "darkness", description = "Harness the power of darkness to envelop your foes." }
newTalentType{ allow_random=true, type="cursed/shadows", name = "shadows", description = "Summon shadows from the darkness to aid you." }
newTalentType{ allow_random=true, type="cursed/punishments", name = "punishments", description = "Your hate becomes punishment in the minds of your foes." }

-- Generic
newTalentType{ allow_random=true, type="cursed/gestures", name = "gestures", generic = true, description = "Enhance the power of you mind with gestures." }
newTalentType{ allow_random=true, type="cursed/cursed-form", name = "cursed form", generic = true, description = "You are wracked with the dark energies of the curse." }
newTalentType{ allow_random=true, type="cursed/cursed-aura", name = "cursed aura", generic = true, description = "The things you surround yourself with soon wither away." }
newTalentType{ allow_random=false, type="cursed/curses", name = "curses", hide = true, description = "The effects of cursed objects." }
newTalentType{ allow_random=true, type="cursed/fears", name = "fears", description = "Use the fear that lies at the heart of your curse to attack the minds of your enemies." }

cursed_wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_wil_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_str_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_str_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_str_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_str_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_str_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_cun_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_lev_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
cursed_lev_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
cursed_lev_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
cursed_lev_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
cursed_lev_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

-- utility functions
function getHateMultiplier(self, min, max, cursedWeaponBonus, hate)
	local fraction = (hate or self.hate) / 100
	if cursedWeaponBonus then
		if self:hasDualWeapon() then
			if self:hasCursedWeapon() then fraction = fraction + 0.13 end
			if self:hasCursedOffhandWeapon() then fraction = fraction + 0.07 end
		else
			if self:hasCursedWeapon() then fraction = fraction + 0.2 end
		end
	end
	fraction = math.min(fraction, 1)
	return (min + ((max - min) * fraction))
end

load("/data/talents/cursed/slaughter.lua")
load("/data/talents/cursed/endless-hunt.lua")
load("/data/talents/cursed/strife.lua")
load("/data/talents/cursed/gloom.lua")
load("/data/talents/cursed/rampage.lua")
load("/data/talents/cursed/predator.lua")

load("/data/talents/cursed/force-of-will.lua")
load("/data/talents/cursed/dark-sustenance.lua")
load("/data/talents/cursed/shadows.lua")
load("/data/talents/cursed/darkness.lua")
load("/data/talents/cursed/punishments.lua")
load("/data/talents/cursed/gestures.lua")

load("/data/talents/cursed/cursed-form.lua")
load("/data/talents/cursed/cursed-aura.lua")
load("/data/talents/cursed/fears.lua")
