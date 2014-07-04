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

local life = life or 30
local density = density or 266
bx = x or 0
by = y or 0
local nb = 0
return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0, sradius / 2)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)
	local s = 3
	if size then
		s = rng.range(size[1], size[2])
	end

	return {
		trail = 1,
		life = life,
		size = s, sizev = 0, sizea = 0,

		x = bx + x, xv = 0, xa = 0,
		y = by + y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = sradius / 2 / life, velv = 0, vela = 0,
		
		r = rng.range(rm or 255, rM or 255)/255,    rv = 0, ra = 0,
		g = rng.range(gm or 255, gM or 255)/255,	  gv = 0, ga = 0,
		b = rng.range(bm or 255, bM or 255)/255,	  bv = 0, ba = 0,
		a = rng.range(am or 255, aM or 255)/255,    av = 0.01, aa = 0,
	}
end, },
function(self)
	if nb < 5 then
		self.ps:emit(radius*density)
		nb = nb + 1
		self.ps:emit(radius*density)
		nb = nb + 1
		self.ps:emit(radius*density)
		nb = nb + 1
		self.ps:emit(radius*density)
		nb = nb + 1
		self.ps:emit(radius*density)
		nb = nb + 1
	end
end,
5*radius*density, img or nil
