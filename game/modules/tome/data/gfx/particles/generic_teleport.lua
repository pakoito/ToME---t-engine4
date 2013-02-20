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

return { generator = function()
	local ad = rng.float(0, 360)
	local dir = math.rad(ad)

	return {
		x = math.cos(dir) * 5, y = math.sin(dir) * 5,
		dir = dir, vel = rng.float(1, 3),

		life = rng.range(20, 30),
		size = rng.range(3, 7), sizev = 0, sizea = 0,

	r = rng.range(rm, rM)/255,	rv = 0, ra = 0,
	g = rng.range(gm, gM)/255,	gv = 0, ga = 0.,
	b = rng.range(bm, bM)/255,	bv = 0, ba = 0,
	a = rng.range(am, aM)/255,	av = 0, aa = 0.005,
	}

end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(50)
	end
end,
300

