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

-- Make the 2 main forks
local distortion_factor = 1 + (distortion_factor or 0.1)
local life = life or 10
local fullradius = (radius or 0.5) * engine.Map.tile_w
local basespeed = fullradius / life
local points = {}
baseradius = baseradius or 14

for fork_i = 1, nb_circles or 5 do
	local size = 2
	local r = baseradius
	local a = 0
	local firstspeed = rng.float(basespeed, basespeed * distortion_factor)
	points[#points+1] = {size=size, dir = a + math.rad(90), vel = firstspeed, x=math.cos(a) * r, y=math.sin(a) * r, prev=-1}

	for i = 1, 35 do
		local a = math.rad(i * 10)
		points[#points+1] = {
			size=size,
			dir = a + math.rad(90),
			vel = rng.float(basespeed, basespeed * distortion_factor),
			x=math.cos(a) * r,
			y=math.sin(a) * r,
			prev=#points-1
		}
	end

	points[#points+1] = {size=size, dir = a + math.rad(90), vel = firstspeed, x=math.cos(a) * r, y=math.sin(a) * r, prev=#points-1}
end
local nbp = #points

-- Populate the lightning based on the forks
return { engine=core.particles.ENGINE_LINES, generator = function()
	local p = table.remove(points, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir, dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = rng.float(0.8, 1), rv = 0, ra = 0,
		g = rng.float(0.8, 1), gv = 0, ga = 0,
		b = 0, bv = 0, ba = 0,
		a = 1, av = 0, aa = -0.0005,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(36)
		nbp = nbp - 36
	end
end,
nbp, "particles_images/beam"
