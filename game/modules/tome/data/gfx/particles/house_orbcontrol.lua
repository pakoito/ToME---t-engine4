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

local nb = rng.range(0, 360)

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(28, 40)
	local dirv = math.rad(1)

	return {
		trail = 1,
		life = rng.range(6, 15),
		size = rng.range(3, 6), sizev = -0.5, sizea = 0,

		x = r * math.cos(a)-2, xv = 0, xa = 0,
		y = r * math.sin(a)-2, yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = rng.percent(50) and -1 or 1, velv = 0, vela = 0,

		r = rng.range(10, 50)/255,   rv = 0, ra = 0,
		g = rng.range(120, 200)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(180, 255)/255,      bv = 0, ba = 0,
		a = rng.range(25, 220)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	nb = nb + 2
	self.ps:emit(9*(math.cos(math.rad(nb)) + 1.7))
	if nb >= 360 then nb = nb - 360 end
end,
10 * 10,
"particle_cloud",
true -- stay forever
