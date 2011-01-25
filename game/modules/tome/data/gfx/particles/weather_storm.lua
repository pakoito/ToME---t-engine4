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

rdir = math.rad(dir or 110)
h_per_tick = math.sin(rdir)
r = r or 1
g = g or 1
b = b or 1

local first = true

return { generator = function()
	local size = rng.float(300, 800)
	local x = rng.range(size, width + size)
	local y = -size
	if first then y = rng.range(size, height - size) end
	local vel = rng.float(speed[1], speed[2])

	return {
		life = (height + size*2) / (h_per_tick * vel),
		size = rng.float(300, 800), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = rdir, dirv = blur, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = r, rv = 0, ra = 0,
		g = g, gv = 0, ga = 0,
		b = b, bv = 0, ba = 0,
		a = rng.float(alpha[1], alpha[2]), av = 0, aa = 0,
	}
end, },
function(self)
	if first then
		self.ps:emit(rng.range(0, max_nb or 1))
		first = false
		return
	end

	if rng.chance(chance or 100) then
		self.ps:emit(1)
	end
end,
max_nb or 1,
particle_name, true
