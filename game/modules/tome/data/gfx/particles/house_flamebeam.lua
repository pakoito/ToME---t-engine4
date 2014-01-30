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

local nb = rng.range(0, 360)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local r = rng.range(1, ray.size - 32)

	local ra = a + (rng.chance(2) and math.rad(-90) or math.rad(90))
	local rr = rng.float(2, engine.Map.tile_w * 0.50)

	local vel = rng.float(1.2, 6)

	return {
		life = 32 / vel,
		size = rng.float(2, 5), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + rr * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + rr * math.sin(ra), yv = 0, ya = 0,
		dir = ray.dir, dirv = 0, dira = 0,
		vel = vel, velv = -0.1, vela = 0.01,

		r = rng.range(120, 255)/255,   rv = 0, ra = 0,
		g = rng.range(120, 200)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(0, 10)/255,      bv = 0, ba = 0,
		a = rng.range(25, 220)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	nb = nb + 2
	self.ps:emit(2*tiles*(math.cos(math.rad(nb)) + 1.7))
	if nb >= 360 then nb = nb - 360 end
end,
32*9*tiles,
"particle_cloud",
true -- stay forever
