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

local Stats = require "engine.interface.ActorStats"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION",
	unique = true, quest=true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	unided_name = "dark runed staff",
	name = "Staff of Absorption",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET, image = "object/staff_dragonbone.png",
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
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
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

-------------------- The four orbs of command

-- Rak'shor Pride
newEntity{ define_as = "ORB_UNDEATH",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Undeath (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[Dark visions fill you mind as you lift the orb. It is cold to the touch.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) end
	},

	carrier = {
		inc_stats = { [Stats.STAT_DEX] = 6, },
	},
}

-- Gorbat Pride
newEntity{ define_as = "ORB_DRAGON",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb of command",
	name = "Dragon Orb (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[This orb is warm to the touch.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) end
	},

	carrier = {
		inc_stats = { [Stats.STAT_CUN] = 6, },
	},
}

-- Vor Pride
newEntity{ define_as = "ORB_ELEMENTS",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb of command",
	name = "Elemental Orb (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[Flames swirl on the icy surface of this orb.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) end
	},

	carrier = {
		inc_stats = { [Stats.STAT_MAG] = 6, },
	},
}

-- Grushnak Pride
newEntity{ define_as = "ORB_DESTRUCTION",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Destruction (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[Visions of death and destruction fill your mind as you lift this orb.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) end
	},

	carrier = {
		inc_stats = { [Stats.STAT_STR] = 6, },
	},
}

---------------------------- Various quest starters

-- This one starts a quest it has a level and rarity so it can drop randomly, but there are palces where it is more likely to appear
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_TOME", subtype="tome",
	unique = true, quest=true,
	unided_name = "ancient tome",
	name = "Ancient Tome titled 'Gems and their uses'",
	level_range = {30, 40}, rarity = 120,
	color = colors.VIOLET,
	fire_proof = true,

	on_pickup = function(self, who)
		if who == game.player then
			self:identify(true)
			who:grantQuest("master-jeweler")
		end
	end,
}

newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_SUMMON", subtype="tome",
	unique = true, quest=true, identified=true,
	name = "Scroll of Summoning (Limmir the Jeweler)",
	color = colors.VIOLET,
	fire_proof = true,

	max_power = 1, power_regen = 1,
	use_power = { name = "summon Limmir the jeweler at the center of the lake of the moon", power = 1,
		use = function(self, who) who:hasQuest("master-jeweler"):summon_limmir(who) end
	},
}
