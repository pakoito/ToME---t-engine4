-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

newEntity{ define_as = "TRAP_COMPLEX",
	type = "complex", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		return true
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "boulder",
	name = "giant boulder trap", image = "trap/trap_pressure_plate_01.png",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=40, color_g=220, color_b=0,
	message = "@Target@ walks on a trap, there is a loud noise.",
	pressure_trap = true,
	on_added = function(self, level, x, y)
		local walls = {}
		for i, dir in ipairs{4,6,8,2} do
			local i, j = x, y
			local g
			repeat
				i, j = util.coordAddDir(i, j, dir)
				g = game.level.map(i, j, engine.Map.TERRAIN)
			until not g or g:check("block_move")
			if g and not g.is_door and core.fov.distance(x, y, i, j) >= 2 then
				i, j = util.coordAddDir(i, j, util.opposedDir(dir, i, j))
				walls[#walls+1] = {x=i, y=j}
			end
		end
		if #walls == 0 then game.level.map:remove(i, j, engine.Map.TRAP) return end

		local spot = rng.table(walls)
		local l = line.new(spot.x, spot.y, x, y)
		self.spawn_x, self.spawn_y = l()
		print("Boulder trap spawn", self.spawn_x, self.spawn_y)
		self.x, self.y = x, y
	end,
	str = resolvers.mbonus(200, 30),
	dam = resolvers.mbonus_level(300, 5),
	combatAttackStr = function(self) return self.str end,
	triggered = function(self, x, y, who)
		if not self.spawn_x then return end
		local tg = {name="huge boulder", type="bolt", range=5, x=self.spawn_x, y=self.spawn_y, speed=2, display={image="trap/trap_big_boulder_01.png"}}
		self:projectile(tg, x, y, engine.DamageType.PHYSKNOCKBACK, {dam=self.dam, dist=3})
		return true
	end,
}
