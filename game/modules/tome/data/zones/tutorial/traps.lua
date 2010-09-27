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

load("/data/general/traps/natural_forest.lua")

newEntity{ define_as = "TRAP_TUTORIAL",
	type = "tutorial", subtype="tutorial", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	desc = [[A tutorial]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		local d = require("engine.dialogs.ShowText").new("Tutorial: "..self.name, "tutorial/"..self.text)
		game:registerDialog(d)
		return false, false
	end
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MOVE",
	name = "Movement",
	text = "move",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MELEE",
	name = "Melee Combat",
	text = "melee",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_OBJECTS",
	name = "Objects",
	text = "objects",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TALENTS",
	name = "Talents",
	text = "talents",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_LEVELUP",
	name = "Experience and Levels",
	text = "levelup",
}
