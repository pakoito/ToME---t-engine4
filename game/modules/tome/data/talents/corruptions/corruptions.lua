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
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/sanguisuge", name = "sanguisuge", description = "Manipulate the life force to feed your own dark powers." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/torment", name = "torment", generic = true, description = "All the tools to torment your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/vim", name = "vim", description = "Touch the very essence of your victims." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/bone", name = "bone", description = "Harness the power of bones." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/hexes", name = "hexes", generic = true, description = "Hex your foes, hindering and crippling them." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/curses", name = "curses", generic = true, description = "Curse your foes, hindering and crippling them." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/plague", name = "plague", description = "Spread diseases to your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/scourge", name = "scourge", description = "Bring pain and destruction to the world." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/reaving-combat", name = "reaving combat", description = "Enhanced melee combat through the dark arts." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blood", name = "blood", description = "Harness the power of blood, both your own and your foes'." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blight", name = "blight", description = "Bring corruption and decay to all who oppose you." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/shadowflame", name = "Shadowflame", description = "Harness the power of the demonic shadowflame." }

-- Generic requires for corruptions based on talent level
corrs_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
corrs_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
corrs_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
corrs_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
corrs_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_corrs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_corrs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_corrs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_corrs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_corrs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/corruptions/sanguisuge.lua")
load("/data/talents/corruptions/scourge.lua")
load("/data/talents/corruptions/plague.lua")
load("/data/talents/corruptions/reaving-combat.lua")
load("/data/talents/corruptions/bone.lua")
load("/data/talents/corruptions/curses.lua")
load("/data/talents/corruptions/hexes.lua")
load("/data/talents/corruptions/blood.lua")
load("/data/talents/corruptions/blight.lua")
load("/data/talents/corruptions/shadowflame.lua")
load("/data/talents/corruptions/vim.lua")
load("/data/talents/corruptions/torment.lua")
