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
local forks = {{}, {}}
local m1 = forks[1]
local m2 = forks[2]
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
m1.bx = 0
m1.by = 0
m1.thick = 5
m1.dir = math.atan2(ty, tx) + breakdir
m1.size = math.sqrt(tx*tx+ty*ty) / 2

m2.bx = m1.size * math.cos(m1.dir)
m2.by = m1.size * math.sin(m1.dir)
m2.thick = 5
m2.dir = math.atan2(ty, tx) - breakdir
m2.size = math.sqrt(tx*tx+ty*ty) / 2

-- Add more forks
for i = 1, math.min(math.max(3, m1.size / 5), 20) do
	local m = rng.percent(50) and forks[1] or forks[2]
	if rng.percent(60) then m = rng.table(forks) end
	local f = {}
	f.thick = 2
	f.dir = m.dir + math.rad(rng.range(-30,30))
	f.size = rng.range(6, 25)
	local br = rng.range(1, m.size)
	f.bx = br * math.cos(m.dir) + m.bx
	f.by = br * math.sin(m.dir) + m.by
	forks[#forks+1] = f
end

-- Populate the lightning based on the forks
return { generator = function()
	local f = rng.table(forks)
	local a = f.dir
	local rad = rng.range(-3,3)
	local ra = math.rad(rad)
	local r = rng.range(1, f.size)

	return {
		life = life or 4,
		size = f.thick, sizev = 0, sizea = 0,

		x = r * math.cos(a) + 3 * math.cos(ra) + f.bx, xv = 0, xa = 0,
		y = r * math.sin(a) + 3 * math.sin(ra) + f.by, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.float(0.5, 0.7),   rv = 0, ra = 0,
		g = rng.float(0.3, 0.5),   gv = 0, ga = 0,
		b = rng.float(0, 1),      bv = 0, ba = 0,
		a = rng.float(0.4, 1),    av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(230*tiles)
	end
end,
4*(nb_particles or 230)*tiles
