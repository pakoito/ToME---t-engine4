-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

base_size = 32

return { generator = function()
	local angle = math.rad(rng.range(0, 360))
	local dir = angle + math.rad(90)
	local distance = engine.Map.tile_w * rng.float(1.5, radius)
	
	--local speed = rng.float(0.02, 0.1)
	--local dirv = math.pi * 2 * speed
	--local vel = math.pi * 2 * distance * speed
	vel = rng.float(2, 6)
	dirv = vel / distance
	
	return {
		trail = 1,
		life = 25,
		size = 6, sizev = 0.2, sizea = -0.025,

		x = distance * math.cos(angle), xv = 0, xa = 0,
		y = distance * math.sin(angle), yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = 240,  rv = 0, ra = 0,
		g = 240,  gv = 0, ga = 0,
		b = 240,  bv = 0, ba = 0,
		a = rng.range(150, 200) / 255, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
25
