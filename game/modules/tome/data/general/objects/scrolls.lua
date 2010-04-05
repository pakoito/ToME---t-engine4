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

newEntity{
	define_as = "BASE_SCROLL",
	type = "scroll", subtype="scroll",
	unided_name = "scroll", id_by_type = true,
	display = "?", color=colors.WHITE, image="object/scroll-0x0.png",
	encumber = 0.1,
	stacking = true,
	use_sound = "actions/read",
	fire_destroy = 20,
	desc = [[Magical scrolls can have wildly different effects! Most of them function better with a high Magic score]],
	egos = "/data/general/objects/egos/scrolls.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of light",
	level_range = {1, 40},
	rarity = 3,
	cost = 1,

	use_simple = { name="light up the surrounding area", use = function(self, who)
		who:project({type="ball", range=0, friendlyfire=false, radius=15}, who.x, who.y, engine.DamageType.LIGHT, 1)
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of identify",
	level_range = {1, 50},
	rarity = 6,
	cost = 1,

	use_simple = { name="identify one object (or all with high magic stat)", use = function(self, who)
		if who:getMag() < 28 then
			who:showInventory("Identify object", who:getInven(who.INVEN_INVEN), nil, function(o, item)
				o:identify(true)
				game.logPlayer(who, "You identify: "..o:getName())
			end)
		else
			for i, o in ipairs(who:getInven("INVEN")) do
				o:identify(true)
			end
			game.logPlayer(who, "You identify all your inventory.")
		end
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of phase door",
	level_range = {1, 30},
	rarity = 4,
	cost = 3,

	use_simple = { name="teleport you randomly over a short distance", use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 15)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of teleportation",
	level_range = {10, 40},
	rarity = 8,
	cost = 4,

	use_simple = { name="teleport you anywhere and the level, randomly", use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of recall",
	level_range = {10, 50},
	rarity = 8,
	cost = 2,

	use_simple = { name="recall to your base town.", use = function(self, who)
		error("****************** IMPLEMENT SCROLL OF RECALL ****************")
		who:recall()
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of magic mapping",
	level_range = {1, 50},
	rarity = 5,
	cost = 3,

	use_simple = { name="map the area directly around you", use = function(self, who)
		who:magicMap(20)
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of enemies detection",
	level_range = {15, 35},
	rarity = 4,
	cost = 5,

	use_simple = { name="detect enemies within a certain range", use = function(self, who)
		local rad = 15 + who:getMag(20)
		who:setEffect(who.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
		})
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}
