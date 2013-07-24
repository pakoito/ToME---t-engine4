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

use_shader = {type="flamewings", deploy_factor=deploy_speed, flap=flap} toback=true
base_size = 32

local r = 1
local g = 1
local b = 1
local a = a or 1
local infinite = infinite
local nb = 0

return { generator = function()
	return {
		trail = 0,
		life = life or 10,
		size = 64 * (size_factor or 1), sizev = 0, sizea = 0,

		x = (x or 0) * 32, xv = 0, xa = 0,
		y = (y or -0.781) * 32, yv = 0, ya = 0,
		dir = 0, dirv = dirv, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = r, rv = 0, ra = 0,
		g = g, gv = 0, ga = 0,
		b = b, bv = 0, ba = 0,
		a = a, av = 0, aa = fade or 0,
	}
end, },
function(self)
	if nb == 0 or infinite then
		self.ps:emit(1)
		nb = 1
	end
end,
1,
"particles_images/"..(img or "wings")
