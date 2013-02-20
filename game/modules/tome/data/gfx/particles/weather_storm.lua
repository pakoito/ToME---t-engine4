-- ToME - Tales of Maj'Eyal
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

rdir = math.rad(dir or 110)
h_per_tick = math.sin(rdir)
r = r or 1
g = g or 1
b = b or 1

local first = true
local last = nil

return { generator = function()
	-- We kept the last one, use for shadow
	if last then
		last.r = r
		last.g = g
		last.b = b
		last.x = last.x + 200
		last.y = last.y - 200
	-- Make a new one
	else
		local size = rng.float(300, 800)
		local x = rng.range(size, width + size)
		local y = -size
		if first then y = rng.range(size, height - size) end
		local vel = rng.float(speed[1], speed[2])
		local a = rng.float(alpha[1], alpha[2])

		last = {
			life = (height + size*2) / (h_per_tick * vel),
			size = rng.float(300, 800), sizev = 0, sizea = 0,

			x = x, xv = 0, xa = 0,
			y = y, yv = 0, ya = 0,
			dir = rdir, dirv = blur, dira = 0,
			vel = vel, velv = 0, vela = 0,

			r = shadow and 0 or r, rv = 0, ra = 0,
			g = shadow and 0 or g, gv = 0, ga = 0,
			b = shadow and 0 or b, bv = 0, ba = 0,
			a = a, av = 0, aa = 0,
		}
	end
	return last
end, },
function(self)
	if first then
		for i = 1, rng.range(0, max_nb or 1) do
			self.ps:emit(1)
			if shadow then self.ps:emit(1) end
			last = nil
		end
		first = false
		return
	end

	if rng.chance(chance or 100) then
		self.ps:emit(1)
		if shadow then self.ps:emit(1) end
		last = nil
	end
end,
(max_nb or 1) * (shadow and 2 or 1),
particle_name, true
