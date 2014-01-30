-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- Make the ray
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local r = rng.range(1, ray.size - 32)

	local side = rng.chance(2)
	local ra = a + (side and math.rad(-90) or math.rad(90))
	local rr = rng.float(2, engine.Map.tile_w * 0.30)

	local vel = rng.float(1.2, 6)

	return {
		life = 38 / vel,
		size = rng.float(8, 20), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + rr * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + rr * math.sin(ra), yv = 0, ya = 0,
		dir = ray.dir + math.rad(180) + (side and 1 or -1) * rng.float(0, 1), dirv = 0, dira = 0,
		vel = vel, velv = -0.1, vela = 0.01,

		r = 1,   rv = 0, ra = 0,
		g = 1,   gv = 0, ga = 0,
		b = 1,   bv = 0, ba = 0,
		a = rng.range(25, 220)/255,    av = -0.034, aa = 0.005,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(9*tiles)
	end
end,
32*9*tiles,
"particles_images/particle_stone"
