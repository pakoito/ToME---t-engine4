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

--------------------------------------------------------------------------------------
-- Advanced shaders
--------------------------------------------------------------------------------------
if core.shader.active() then
use_shader = {type="shadowfire"}
base_size = 64

local r = 1
local g = 1
local b = 1
local a = 1

return { generator = function()
	return {
		trail = 0,
		life = 10,
		size = 2*42 * (size_factor or 1), sizev = 0, sizea = 0,

		x = (x or 0) * engine.Map.tile_w, xv = 0, xa = 0,
		y = (y or 0) * engine.Map.tile_h, yv = 0, ya = 0,
		dir = 0, dirv = dirv, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = r, rv = 0, ra = 0,
		g = g, gv = 0, ga = 0,
		b = b, bv = 0, ba = 0,
		a = a, av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
1,
"particles_images/shadowfire"

--------------------------------------------------------------------------------------
-- Default
--------------------------------------------------------------------------------------
else
base_size = 32

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad)
	local r = rng.range(18, 22)
	local dirchance = rng.chance(2)

	if rng.chance(2) then
	return {
		life = 20,
		size = 4, sizev = -0.05, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0.1, dira = 0,
		vel = dirchance and 0.2 or -0.2, velv = 0, vela = dirchance and -0.02 or 0.02,

		r = rng.range(180, 250)/255, rv = rng.range(0, 10)/100, ra = 0,
		g = rng.range(80, 110)/255,  gv = 0.005, ga = 0.0005,
		b = 0,   bv = 0, ba = 0,
		a = rng.range(70, 255)/255,   av = 0, aa = 0,
	}
	else
	return {
		life = 20,
		size = 4, sizev = -0.05, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0.1, dira = 0,
		vel = dirchance and 0.2 or -0.2, velv = 0, vela = dirchance and -0.02 or 0.02,

		r = rng.range(0, 40)/255,   rv = 0, ra = 0,
		g = rng.range(0, 40)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(0, 40)/255,      bv = 0, ba = 0,
		a = rng.range(255, 255)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
	end
end, },
function(self)
	self.ps:emit(4)
end,
80

end