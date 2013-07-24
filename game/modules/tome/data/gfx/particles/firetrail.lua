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
if core.shader.active(4) then
use_shader = {type="fireball"}
base_size = 64

local nb = 0
local basedir = math.atan2(ty or 1, tx or 0)
local dir = math.deg(basedir)

return {
	system_rotation = 0 or dir, system_rotationv = 0,
	generator = function()
	return {
		life = 10,
		size = 30, sizev = 0, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = dirv, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 0.5, av = -0.05, aa = 0,
	}
end, },
function(self)
	if nb < 1 then
		self.ps:emit(1)
	end
	nb = nb + 1
end,
1, "particles_images/fireball"


--------------------------------------------------------------------------------------
-- Default
--------------------------------------------------------------------------------------
else
local nb = 0

return { generator = function()
	local radius = 0
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0.1, sradius / 2)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)

	return {
		trail = 1,
		life = 3 + 9 * (sradius - r) / sradius,
		size = 3, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.range(200, 255)/255,   rv = 0, ra = 0,
		g = rng.range(120, 170)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(0, 10)/255,      bv = 0, ba = 0,
		a = rng.range(25, 220)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	if nb < 1 then
		self.ps:emit(40)
	end
	nb = nb + 1
end,
40

end