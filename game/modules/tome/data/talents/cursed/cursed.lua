-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

-- Doomed
newTalentType{ allow_random=true, type="cursed/dark-sustenance", name = "dark sustenance", generic = true, description = "Invoke the powerful force of your will." }
newTalentType{ allow_random=true, type="cursed/force-of-will", name = "force of will", description = "Invoke the powerful force of your will." }
newTalentType{ allow_random=true, type="cursed/darkness", is_spell=true, name = "darkness", description = "Harness the power of darkness to envelop your foes." }
newTalentType{ allow_random=true, type="cursed/shadows", is_spell=true, name = "shades", description = "Summon shadows from the darkness to aid you." }
newTalentType{ allow_random=true, type="cursed/punishments", name = "punishments", description = "Your hate becomes punishment in the minds of your foes." }
newTalentType{ allow_random=true, type="cursed/primal-magic", name = "primal magic", description = "You still control traces of power from your previous life." }

-- Generic
newTalentType{ allow_random=true, type="cursed/cursed-form", name = "cursed form", generic = true, description = "You are wracked with the dark energies of the curse." }
newTalentType{ allow_random=true, type="cursed/fateful-aura", name = "fateful aura", generic = true, description = "The things you surround yourself with soon wither away." }
newTalentType{ allow_random=false, type="cursed/curses", name = "curses", hide = true, description = "The effects of cursed objects." }
newTalentType{ allow_random=true, type="cursed/dark-figure", name = "dark figure", description = "Life as an outcast has given you time to reflect on your misfortunes." }

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

cursed_mag_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_mag_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_mag_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_mag_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_mag_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- utility functions
function getHateMultiplier(self, min, max, cursedWeaponBonus, hate)
	local fraction = (hate or self.hate) / 10
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

function checkWillFailure(self, target, minChance, maxChance, attackStrength)
	-- attack power is analogous to mental resist except all willpower and no cunning
	local attack = self:getWil() * 0.5 * attackStrength
	local defense = target:combatMentalResist()

	-- used this instead of checkHit to get a curve that is a little more ratio dependent than difference dependent.
	-- + 10 prevents large changes for low attack/defense values
	-- 2 * log adjusts falloff to roughly get 0% break near attack = 0.5 * defense and 100% break near attack = 2 * defense
	local chance = minChance + (1 + 2 * math.log((attack + 10) / (defense + 10))) * (maxChance - minChance) * 0.5

	local result = rng.avg(1, 100)
	print("checkWillFailure", self.name, self.level, target.name, target.level, minChance, chance, maxChance)

	if result <= minChance then return true end
	if result >= maxChance then return false end
	return result <= chance
end

load("/data/talents/cursed/slaughter.lua")
load("/data/talents/cursed/endless-hunt.lua")
load("/data/talents/cursed/strife.lua")
load("/data/talents/cursed/gloom.lua")
load("/data/talents/cursed/rampage.lua")

load("/data/talents/cursed/force-of-will.lua")
load("/data/talents/cursed/dark-sustenance.lua")
load("/data/talents/cursed/shadows.lua")
load("/data/talents/cursed/darkness.lua")
load("/data/talents/cursed/punishments.lua")
load("/data/talents/cursed/primal-magic.lua")

load("/data/talents/cursed/cursed-form.lua")
load("/data/talents/cursed/fateful-aura.lua")
load("/data/talents/cursed/dark-figure.lua")
