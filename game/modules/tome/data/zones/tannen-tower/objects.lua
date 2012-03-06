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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"

newEntity{ base = "BASE_GEM",
	define_as = "RESONATING_DIAMOND_WEST2",
	name = "Resonating Diamond", color=colors.VIOLET, quest=true, unique="Resonating Diamond West2", identified=true, no_unique_lore=true,
	image = "object/artifact/resonating_diamond.png",
	material_level = 5,

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "diamon-back")
		end
	end,
}

newEntity{ define_as = "ATHAME_WEST2",
	quest=true, unique="Blood-Runed Athame West2", identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame", image = "object/artifact/blood_runed_athame.png",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[An athame, covered in blood runes. It radiates power.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "athame-back")
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS2",
	power_source = {unknown=true},
	unique = "Orb of Many Ways2", quest=true, no_unique_lore=true,
	type = "jewelry", subtype="orb",
	unided_name = "swirling orb",
	name = "Orb of Many Ways",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/pearl.png",
	encumber = 1,
	desc = [[The orb projects images of distant places, some that seem to not be of this world, switching rapidly.
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
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "orb-back")
		end
	end,
}
