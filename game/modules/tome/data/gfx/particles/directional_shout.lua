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

rm, rM = rm or 0.8, rM or 1
gm, gM = gm or 0.8, gM or 1
bm, bM = bm or 0, bM or 0
am, aM = am or 1, aM or 1

local dir = math.deg(math.atan2(ty, tx))

-- engine.Target uses a default cone_angle of 55, but from what I can tell, it
-- rounds up rather aggressively (if part of a grid square is affected, the whole
-- grid square is), so for the purposes of particle effects, 75 works well.
local spread = spread or 75
dir = dir - spread / 2

local distortion_factor = 1 + (distortion_factor or 0.1)
local life = life or 30
local fullradius = (radius or 5) * engine.Map.tile_w
local basespeed = fullradius / life
local points = {}
local nbone

for circle_i = 1, nb_circles or 7 do
	local size = size or 2
	local r = 10

	for i = 0, spread, 5 do
		local a = math.rad(dir + i)
		points[#points+1] = {
			size=size,
			dir = a,
			vel = rng.float(basespeed, basespeed * distortion_factor),
			x=math.cos(a) * r,
			y=math.sin(a) * r,
			prev=i == 0 and -1 or #points-1
		}
	end
	if not nbone then nbone = #points end
end
local nbp = #points

-- Populate the sound waves based on the number of circles
return { engine=core.particles.ENGINE_LINES, generator = function()
	local p = table.remove(points, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir, dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = rng.float(rm, rM), rv = 0, ra = 0,
		g = rng.float(gm, gM), gv = 0, ga = 0,
		b = rng.float(bm, bM), bv = 0, ba = 0,
		a = rng.float(am, aM), av = 0, aa = -0.001,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(nbone)
		nbp = nbp - nbone
	end
end,
nbp, "particles_images/beam"