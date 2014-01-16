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

base_size = 64

local first = true
local ad = rng.range(0, 360)
local a = math.rad(ad)
local dir = math.rad(ad + 90)
local r = 20
local speed = rng.range(100, 140)
local dirv = math.pi * 2 / speed
local vel = math.pi * 2 * r / speed
local da = math.rad(360 / 3)

return { generator = function()
	a = a + da
	dir = dir + da
	return {
		life = core.particles.ETERNAL,
		size = 16, sizev = 0, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a) - 50, yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = rng.range(220, 255)/255,   rv = 0, ra = 0,
		g = rng.range(220, 255)/255,   gv = 0, ga = 0,
		b = rng.range(220, 255)/255,   gv = 0, ga = 0,
		a = rng.range(230, 225)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	if first then self.ps:emit(3) first = false end
end,
3, "shockbolt/terrain/shertul_flying_castle_orbiter"
