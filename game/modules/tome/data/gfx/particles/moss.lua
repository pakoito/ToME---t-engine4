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

base_size = 64

local nb = 0

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad)
	local r = rng.range(0, 32)

	return {
		life = 120,
		size = rng.range(24, 48), sizev = -0.05, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 0.3,   rv = 0, ra = 0,
		g = 0.7,   gv = 0, ga = 0,
		b = 0.3,   gv = 0, ga = 0,
		a = rng.float(0.01, 0.05),   av = 0.032, aa = -0.0006,
	}
end, },
function(self)
	if nb == 0 then self.ps:emit(1) end
	nb = nb + 1
	if nb >= 10 then
		nb = 0
	end
end,
10, "particles_images/slime"..rng.range(1, 5)