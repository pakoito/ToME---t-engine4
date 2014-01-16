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

local radius = radius or 6
local spread = math.rad(spread or 55/2)

local points = {}

local basedir = math.atan2(ty, tx)
local basesize = radius * (engine.Map.tile_w + engine.Map.tile_h) / 2

for fork_i = -15, 15 do
	local tx = math.cos(basedir + fork_i * spread / 15) * basesize
	local ty = math.sin(basedir + fork_i * spread / 15) * basesize
	local basedir = math.atan2(ty, tx)

	local c = rng.range(20, 80)/255
	local a = 1 or rng.float(0.3, 0.6)
	local size = 3
	local starta = basedir+math.pi/2
	local starts = rng.range(-4, 4)
	points[#points+1] = {bc=bc, c=c, a=a, size=size, x=math.cos(starta) * starts, y=math.sin(starta) * starts, prev=-1}

	local nb = radius * 2
	for i = 0, nb - 1 do
		-- Split point in the segment
		local split = rng.range(0, basesize / nb) + i * (basesize / nb)
		
		local dev = math.rad(rng.range(-8, 8))
		
		points[#points+1] = {c=c, a=a, movea=basedir+dev+math.pi/2, size=size + rng.range(-2, 2), x=math.cos(basedir+dev) * split, y=math.sin(basedir+dev) * split, prev=#points-1}
	end

	points[#points+1] = {c=c, a=a, size=size, x=tx, y=ty, prev=#points-1}
end

local nbp = #points

-- Populate the lightning based on the forks
return { engine=core.particles.ENGINE_LINES, generator = function()
	local p = table.remove(points, 1)

	return {
		life = 10, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.movea, dirv = 0, dira = 0,
		vel = rng.float(-1, 1), velv = 0, vela = 0,

		r = p.c, rv = 0, ra = 0,
		g = p.c, gv = 0, ga = 0,
		b = p.c, bv = 0, ba = 0,
		a = p.a, av = 0, aa = -0.02,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(nbp)
		nbp = 0
	end
end,
nbp, "particles_images/beam"
