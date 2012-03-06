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
	name = "Underwater Cave",
	type = "harmless", subtype = "special", unique = true,
	level_range = {30, 40},
	rarity = 1,
	special_filter = function(self)
		return self:findSpotGeneric(game.player, function(map, x, y) local enc = map:checkAllEntities(x, y, "can_encounter") return enc and enc == "water" end) and true or false
	end,
	on_encounter = function(self, who)
		local x, y = self:findSpotGeneric(who, function(map, x, y) local enc = map:checkAllEntities(x, y, "can_encounter") return enc and enc == "water" end)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Entrance to an underwater cave"
		g.display='>' g.color_r=colors.AQUAMARINE.r g.color_g=colors.AQUAMARINE.g g.color_b=colors.AQUAMARINE.b g.notice = true
		g.change_level=1 g.change_zone="flooded-cave" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/underwater/subsea_cave_entrance_01.png", z=4, display_h=2, display_y=-1}
		g.nice_tiler = nil
		g.does_block_move = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to an underwater cave.")
		return true
	end,
}

newEntity{
	name = "Shadow Crypt",
	type = "hostile", subtype = "special", unique = true,
	immediate = {"world-encounter", "fareast"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Entrance to a dark crypt"
		g.display='>' g.color_r=128 g.color_g=128 g.color_b=128 g.notice = true
		g.change_level=1 g.change_zone="shadow-crypt" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		return true
	end
}

newEntity{
	name = "Orc Breeding Pit",
	type = "hostile", subtype = "special", unique = true,
	immediate = {"world-encounter", "fareast"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Entrance to the orc breeding pit"
		g.display='>' g.color_r=colors.GREEN.r g.color_g=colors.GREEN.g g.color_b=colors.GREEN.b g.notice = true
		g.change_level=1 g.change_zone="orc-breeding-pit" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ladder_down.png"}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		return true
	end
}
