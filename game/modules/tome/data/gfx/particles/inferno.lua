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

base_size = 32

return { blend_mode=core.particles.BLEND_ADDITIVE, generator = function()
	local ad = rng.range(20+90, 160+90)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 20)
	local dirv = math.rad(rng.float(-1,1))
	local life = rng.range(10,30)

	return {
		trail = 1,
		life = life,
		size = rng.range(4, 12), sizev = -0.2, sizea = 0,

		x = r * math.cos(a), xv = -0.1, xa = 0,
		y = r * math.sin(a), yv = -0.1, ya = 0,
		dir = dir, dirv = dirv, dira = -dirv/life,
		vel = rng.float(0.3, 1), velv = 0, vela = 0,

		r = rng.float(0.8, 1),   rv = 0, ra = 0,
		g = rng.float(0.4, 0.7),   gv = 0, ga = 0,
		b = rng.float(0, 1),      bv = 0, ba = 0,
		a = rng.float(0.2, 0.8),    av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(4)
end,
40, "fire_particle"
