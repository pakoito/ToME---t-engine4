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

base_size = 32

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 20)
	local dirv = math.rad(1)

	return {
		trail = 1,
		life = 10,
		size = 1, sizev = 0.5, sizea = 0,

		x = r * math.cos(a), xv = -0.1, xa = 0,
		y = r * math.sin(a), yv = -0.1, ya = 0,
		dir = math.rad(rng.range(0, 360)), dirv = 0, dira = 0,
		vel = 0.1, velv = 0, vela = 0,

		r = 0,   rv = 0, ra = 0,
		g = rng.range(170, 210)/255,   gv = 0, ga = 0,
		b = rng.range(200, 255)/255,   gv = 0, ga = 0,
		a = rng.range(80, 130)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(4)
end,
40,
"particle_torus"
