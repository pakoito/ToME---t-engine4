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
local Talents = require "engine.interface.ActorTalents"

-- This one starts a quest it has a level and rarity so it can drop randomly, but there are places where it is more likely to appear
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_TOME", subtype="tome", no_unique_lore=true,
	unique = true, quest=true,
	unided_name = "ancient tome",
	name = "Ancient Tome titled 'Gems and their uses'",
	level_range = {30, 40}, rarity = 120,
	color = colors.VIOLET,
	is_magic_device = false,
	fire_proof = true,
	not_in_stores = true,

	on_pickup = function(self, who)
		if who == game.player then
			self:identify(true)
			who:grantQuest("master-jeweler")
		end
	end,
}

-- Not a random drop, used by the quest started above
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_SUMMON", subtype="tome", no_unique_lore=true,
	unique = true, quest=true, identified=true,
	name = "Scroll of Summoning (Limmir the Jeweler)",
	color = colors.VIOLET,
	fire_proof = true,
	is_magic_device = false,

	max_power = 1, power_regen = 1,
	use_power = { name = "summon Limmir the jeweler at the center of the lake of the moon", power = 1,
		use = function(self, who) who:hasQuest("master-jeweler"):summon_limmir(who) end
	},
}
