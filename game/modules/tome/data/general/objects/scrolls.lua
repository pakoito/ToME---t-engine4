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

newEntity{
	define_as = "BASE_SCROLL",
	slot = "INBELT", use_no_wear=true,
	type = "scroll", subtype="scroll",
	unided_name = "scroll", id_by_type = true,
	display = "?", color=colors.WHITE, image="object/scroll.png",
	encumber = 0.1,
	stacking = true,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	is_magic_device = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[Magical scrolls can have wildly different effects! Most of them function better with a high Magic score]],
	egos = "/data/general/objects/egos/scrolls.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of light",
	level_range = {1, 40},
	rarity = 3,
	cost = 1,
	material_leve = 1,

	use_simple = { name="light up the surrounding area", use = function(self, who)
		who:project({type="ball", range=0, friendlyfire=true, radius=15}, who.x, who.y, engine.DamageType.LITE, 1)
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of phase door",
	level_range = {1, 30},
	rarity = 4,
	cost = 3,
	material_leve = 2,

	use_simple = { name="teleport you randomly over a short distance", use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 15)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of controlled phase door",
	level_range = {30, 50},
	rarity = 7,
	cost = 3,
	material_leve = 4,

	use_simple = { name="teleport you randomly over a short distance into a targeted area", use = function(self, who)
		local tg = {type="ball", nolock=true, no_restrict=true, nowarning=true, range=10 + who:getMag(10), radius=3}
		x, y = who:getTarget(tg)
		if not x then return nil end
		-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
		-- but we cant ...
		local _ _, x, y = who:canProject(tg, x, y)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(x, y, 3)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of teleportation",
	level_range = {10, 50},
	rarity = 8,
	cost = 4,
	material_leve = 3,

	use_simple = { name="teleport you anywhere on the level, randomly", use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200, 15)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of magic mapping",
	level_range = {1, 50},
	rarity = 5,
	cost = 3,
	material_leve = 2,

	use_simple = { name="map the area directly around you", use = function(self, who)
		who:magicMap(20)
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of enemies detection",
	level_range = {15, 35},
	rarity = 4,
	cost = 5,
	material_leve = 1,

	use_simple = { name="detect enemies within a certain range", use = function(self, who)
		local rad = 15 + who:getMag(20)
		who:setEffect(who.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
		})
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_SCROLL",
	name = "scroll of shielding",
	level_range = {10, 50},
	rarity = 9,
	cost = 7,
	material_leve = 3,

	use_simple = { name="create a temporary shield that absorbs damage", use = function(self, who)
		local power = 60 + who:getMag(100)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=power})
		game.logSeen(who, "%s reads a %s!", who.name:capitalize(), self:getName{no_count=true})
		return "destroy", true
	end}
}
