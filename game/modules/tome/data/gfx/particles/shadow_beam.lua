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

-- Make the 2 main forks
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local basesize = math.sqrt((ty*ty)+(tx*tx))
local basedir = math.atan2(ty, tx)

local nbp = 0
local points = {}

local function make_beam(fork_i)
	local c = rng.range(20, 80)/255
	local a = 1 or rng.float(0.7, 0.9)
	local size = fork_i == 1 and 1 or 1
	local starta = basedir+math.pi/2
	local starts = rng.range(-0, 0)
	points[#points+1] = {c=c, a=a, size=size, x=math.cos(starta) * starts, y=math.sin(starta) * starts, prev=-1}

	local nb = 3
	for i = 0, nb - 1 do
		-- Split point in the segment
		local split = rng.range(0, basesize / nb) + i * (basesize / nb)
		local dev = rng.range(-4, 4) * (9 + fork_i) / 10
		points[#points+1] = {
			c=c, a=a, 
			movea=basedir+dev+math.pi/2, 
			size=size + rng.range(-2, 2), 
			x=math.cos(basedir) * split + math.cos(basedir+math.pi/2) * dev,
			y=math.sin(basedir) * split + math.sin(basedir+math.pi/2) * dev,
			prev=#points-1
		}
	end

	points[#points+1] = {c=c, a=a, size=size, x=tx, y=ty, prev=#points-1}
	nbp = #points
end

for fork_i = 1, 20 do make_beam(fork_i) end

local last_id = -1

-- Populate the lightning based on the forks
return { engine=core.particles.ENGINE_LINES, generator = function(id)
	local p = table.remove(points, 1)

	local ret = {
		life = 6, trail=(p.prev == -1) and -1 or last_id,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.movea, dirv = 0, dira = 0,
		vel = rng.float(-1, 1), velv = 0, vela = 0,

		r = p.c, rv = 0, ra = 0,
		g = p.c, gv = 0, ga = 0,
		b = p.c, bv = 0, ba = 0,
		a = 0.8, av = 0, aa = 0.001,
	}
	last_id = id
	return ret
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(10)
		nbp = nbp - 10
	end
end,
nbp, "particles_images/beam"
