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
	define_as = "LAVA_FLOOR",
	name = "lava floor", image = "terrain/lava_floor.png",
	display = '.', color=colors.RED, back_color=colors.DARK_GREY,
	shader = "lava",
	mindam = resolvers.mbonus(5, 15),
	maxdam = resolvers.mbonus(10, 30),
	on_move = function(self, x, y, who)
		local DT = engine.DamageType
		local dam = DT:get(DT.FIRE).projector(self, x, y, DT.FIRE, rng.range(self.mindam, self.maxdam))
		if dam > 0 then game.logPlayer(who, "The laval burns you!") end
	end,
}

newEntity{
	define_as = "LAVA_WALL",
	name = "lava wall", image = "terrain/granite_wall1.png",
	display = '#', color=colors.RED, back_color=colors.DARK_GREY, tint=colors.LIGHT_RED,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "LAVA",
	name = "molten lava", image = "terrain/lava.png",
	display = '%', color=colors.LIGHT_RED, back_color=colors.RED,
	does_block_move = true,
	shader = "lava",
}
