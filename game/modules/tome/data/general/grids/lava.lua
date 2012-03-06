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

local molten_lava_editer = {method="borders_def", def="molten_lava"}
local lava_editer = {method="borders_def", def="lava"}
local lava_mountain_editer = {method="borders_def", def="lava_mountain"}

newEntity{
	define_as = "LAVA_FLOOR",
	type = "floor", subtype = "lava",
	name = "lava floor", image = "terrain/lava_floor.png",
	display = '.', color=colors.RED, back_color=colors.DARK_GREY,
	shader = "lava",
	mindam = resolvers.mbonus(5, 15),
	maxdam = resolvers.mbonus(10, 30),
	on_stand = function(self, x, y, who)
		local DT = engine.DamageType
		local dam = DT:get(DT.FIRE).projector(self, x, y, DT.FIRE, rng.range(self.mindam, self.maxdam))
		if dam > 0 then game.logPlayer(who, "The lava burns you!") end
	end,
	nice_tiler = { method="replace", base={"LAVA_FLOOR", 100, 1, 16}},
	nice_editer = lava_editer,
}
for i = 1, 16 do newEntity{ base = "LAVA_FLOOR", define_as = "LAVA_FLOOR"..i, image = "terrain/lava/lava_floor"..i..".png" } end

newEntity{
	define_as = "LAVA_WALL",
	type = "wall", subtype = "lava",
	name = "lava wall", image = "terrain/lava/lava_mountain5.png",
	display = '#', color=colors.RED, back_color=colors.DARK_GREY,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	nice_editer = lava_mountain_editer,
	nice_tiler = { method="replace", base={"LAVA_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="LAVA_WALL", define_as = "LAVA_WALL"..i, image = "terrain/lava/lava_mountain5_"..i..".png"} end

newEntity{
	define_as = "LAVA",
	type = "floor", subtype = "molten_lava",
	name = "molten lava", image = "terrain/lava/molten_lava_5_01.png",
	display = '%', color=colors.LIGHT_RED, back_color=colors.RED,
	special_minimap = colors.RED,
	does_block_move = true,
	pass_projectile = true,
	shader = "lava",
	nice_editer = molten_lava_editer,
	nice_tiler = { method="replace", base={"LAVA", 10, 2, 5} },
}
for i = 2, 5 do newEntity{ base="LAVA", define_as = "LAVA"..i, image = "terrain/lava/molten_lava_5_0"..i..".png"} end
