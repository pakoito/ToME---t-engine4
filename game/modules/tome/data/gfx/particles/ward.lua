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

base_size = 32

local color = color or {r=127, g=127, b=127}
local ad = rng.range(0, 360)
local a = math.rad(ad)
local dir = math.rad(ad + 90)
local r = 18
local speed = rng.range(33, 99)
local dirv = math.pi * 2 / speed
local vel = math.pi * 2 * r / speed
local first = true

return { generator = function()
	local dr = rng.range(0, 2)
	local da = math.rad(rng.range(0, 360))
	return {
		life = core.particles.ETERNAL,
		size = rng.range(9,12), sizev = 0, sizea = 0,

		x = r * math.cos(a) + dr * math.cos(da), xv = 0, xa = 0,
		y = r * math.sin(a) + dr * math.cos(da), yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = color.r/255,   rv = 0, ra = 0,
		g = color.g/255,   gv = 0, ga = 0,
		b = color.b/255,   gv = 0, ga = 0,
		a = rng.range(180, 240)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	if first then self.ps:emit(1) first = false end
end,
1, "particles_images/shieldimg"
