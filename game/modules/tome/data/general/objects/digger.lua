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

newEntity{
	define_as = "BASE_DIGGER",
	slot = "TOOL",
	type = "tool", subtype="digger",
	display = "\\", color=colors.LIGHT_BLUE, image = resolvers.image_material("pickaxe", "metal"),
	encumber = 3,
	rarity = 14,
	desc = [[Allows you to dig a wall, remove a tree, create ways.]],
	add_name = " (#DIGSPEED#)",

	max_power = 1, power_regen = 1,
	use_power = { name = "dig a wall, cut a tree, ...", power = 1, use = function(self, who)
		local tg = {type="bolt", range=1, nolock=true}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end

		local wait = function()
			local co = coroutine.running()
			local ok = false
			who:restInit(self.digspeed, "digging", "dug", function(cnt, max)
				if cnt > max then ok = true end
				coroutine.resume(co)
			end)
			coroutine.yield()
			if not ok then
				game.logPlayer(who, "You have been interrupted!")
				return false
			end
			return true
		end
		if wait() then
			who:project(tg, x, y, engine.DamageType.DIG, 1)
		end
		return {id=true, used=true}
	end},

	egos = "/data/general/objects/egos/digger.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{ base = "BASE_DIGGER",
	name = "iron pickaxe", short_name = "iron",
	level_range = {1, 20},
	cost = 3,
	material_level = 1,
	digspeed = resolvers.rngavg(35,40),
}

newEntity{ base = "BASE_DIGGER",
	name = "dwarven-steel pickaxe", short_name = "d.steel",
	level_range = {20, 40},
	cost = 3,
	material_level = 3,
	digspeed = resolvers.rngavg(27,33),
}

newEntity{ base = "BASE_DIGGER",
	name = "voratun pickaxe", short_name = "voratun",
	level_range = {40, 50},
	cost = 3,
	material_level = 5,
	digspeed = resolvers.rngavg(20,25),
}
