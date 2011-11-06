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

load("/data/general/objects/objects.lua")

-- Id stuff
newEntity{ define_as = "ORB_KNOWLEDGE",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb", no_unique_lore = true,
	name = "Orb of Knowledge", identified = true,
	display = "*", color=colors.VIOLET, image = "object/ruby.png",
	encumber = 1,
	save_hotkey = true,
	desc = [[This orb was given to you by Elisa the halfling scryer, it will automatically identify normal and rare items for you and can be activated to identify all others.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			for inven_id, inven in pairs(who.inven) do
				for item, o in ipairs(inven) do
					if not o:isIdentified() then
						o:identify(true)
						game.logPlayer(who, "You have: %s", o:getName{do_colour=true})
					end
				end
			end
			return {id=true, used=true}
		end
	},

	carrier = {
		auto_id = 2,
	},
}
