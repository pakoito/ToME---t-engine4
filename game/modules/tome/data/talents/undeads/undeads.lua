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

-- Undead talents
newTalentType{ type="undead/base", name = "base", generic = true, description = "Undead's innate abilities." }
newTalentType{ type="undead/ghoul", name = "ghoul", generic = true, description = "Ghoul's innate abilities." }
newTalentType{ type="undead/skeleton", name = "skeleton", generic = true, description = "Skeleton's innate abilities." }
newTalentType{ type="undead/vampire", name = "vampire", generic = true, description = "Vampire's innate abilities." }
newTalentType{ type="undead/lich", name = "lich", generic = true, description = "Liches innate abilities." }

-- Generic requires for undeads based on talent level
undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
undeads_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/undeads/ghoul.lua")
load("/data/talents/undeads/skeleton.lua")


-- Undeads's power: ID
newTalent{
	short_name = "UNDEAD_ID",
	name = "Knowledge of the Past",
	type = {"undead/base", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t) self.auto_id = 2 end,
	action = function(self, t)
		local Chat = require("engine.Chat")
		local chat = Chat.new("elisa-orb-scrying", {name="Past memories"}, self, {version="undead"})
		chat:invoke()
		return true
	end,
	info = function(self)
		return ([[You concentrate for a moment to recall some of your memories as a living being and look for knowledge to identify rare objects.]])
	end,
}
