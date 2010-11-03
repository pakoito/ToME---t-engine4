-- ToME - Tales of Maj'Eyal
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
		damtype = DamageType.ARCANE,
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

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", power = 10,
		use = function(self, who)
			self:identify(true)
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

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS_DEMON",
	unique = "Orb of Many Ways Demon", quest=true, no_unique_lore=true,
	type = "jewelry", subtype="orb",
	unided_name = "swirling orb", identified=true,
	name = "Orb of Many Ways",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[The orb projects images of distance places, some that seem to not be of this world, switching rapidly.
If used near a portal it could probably activate it.]],

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", power = 10,
		use = function(self, who)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal{
					change_level = 1,
					change_zone = "demon-plane",
					message = "#VIOLET#The world twists sickeningly around you and you find yourself someplace unexpected! It felt nothing like your previous uses of the Orb of Many Ways. Tannen must have switched the Orb out for a fake!",
					on_use = function(self, who)
						who:setQuestStatus("east-portal", engine.Quest.COMPLETED, "tricked-demon")
					end,
				}
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

-- Scrying
newEntity{ define_as = "ORB_SCRYING",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb of scrying",
	name = "Orb of Scrying",
	display = "*", color=colors.VIOLET, image = "object/ruby.png",
	encumber = 1,
	desc = [[This orb was given to you by Elisa the halfling scryer, it will automatically identify normal and rare items for you and can be activated to contact Elisa for rarer items.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			local Chat = require("engine.Chat")
			local chat = Chat.new("elisa-orb-scrying", {name="Elisa the Scyer"}, who)
			chat:invoke()
		end
	},

	carrier = {
		auto_id_mundane = 1,
	},
}
