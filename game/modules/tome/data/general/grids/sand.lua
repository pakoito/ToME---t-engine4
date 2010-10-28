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
	define_as = "SAND",
	name = "sand", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
}

newEntity{
	define_as = "SANDWALL",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	-- Dig only makes unstable tunnels
	dig = function(src, x, y, old)
		local sand = require("engine.Object").new{
			name = "unstable sand tunnel", image = "terrain/sand.png",
			display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
			canAct = false,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.logSeen(self, "The unstable sand tunnel collapses!")

					local a = game.level.map(self.x, self.y, engine.Map.ACTOR)
					if a then
						game.logPlayer(a, "You are crushed by the collapsing tunnel! You suffocate!")
						a:suffocate(30, self)
						engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self, self.x, self.y, engine.DamageType.PHYSICAL, a.life / 4)
					end
				end
			end
		}
		sand.summoner_gain_exp = true
		sand.summoner = src
		sand.old_feat = old
		sand.temporary = 20
		sand.x = x
		sand.y = y
		game.level:addEntity(sand)
		return nil, sand, true
	end,
}

newEntity{
	define_as = "SANDWALL_STABLE",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "SAND",
}

newEntity{
	define_as = "PALMTREE",
	name = "tree", image = "terrain/sand.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=93,g=79,b=22},
--	add_displays = class:makeTrees("terrain/palmtree_alpha", 1),
	add_displays = {class.new{image="terrain/palmtree_alpha1.png"}},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "SAND",
}
