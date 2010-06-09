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

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION",
	unique = true, quest=true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	unided_name = "dark runed staff",
	name = "Staff of Absorption",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET,
	encumber = 7,
	desc = [[Carved with runes of power, this staff seems to have been made long ago. Yet it bears no signs of tarnishment.
Light around it seems to dim and you can feel its tremendous power simply by touching it.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 30,
		apr = 4,
		atk = 20,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 20,
		combat_spellcrit = 10,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "absorb energies", power = 1000,
		use = function(self, who)
			game.logPlayer(who, "This power seems too much to wield, you fear it might absorb YOU.")
		end
	},

	on_pickup = function(self, who)
		if who == game.player then
			who:grantQuest("staff-absorption")
		end
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "swirling orb",
	name = "Orb of Many Ways",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET,
	encumber = 1,
	desc = [[The orb projects images of distance places, some that seem to not be of this world, switching rapidly.
If used near a portal it could probably activate it.]],

	max_power = 50, power_regen = 1,
	use_power = { name = "activate a portal", power = 25,
		use = function(self, who)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal(g.orb_portal)
			else
				game.logPlayer(who, "There is no portal to activate here.")
			end
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}
