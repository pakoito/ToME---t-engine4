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

local nb = 0

return { generator = function()
	local angle = math.rad(rng.range(0, 360))
	local r = 18
	local life = 30

	return {
		life = life,
		size = 3, sizev = 0, sizea = 0,

		x = r * math.cos(angle), xv = -r * math.cos(angle) / life, xa = 0,
		y = r * math.sin(angle), yv = -r * math.sin(angle) / life, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 228 / 255,  rv = 0, ra = 0,
		g = 40 / 255,  gv = 0, ga = 0,
		b = 5 / 255,  bv = 0, ba = 0,
		a = 230 / 255,  av = 0, aa = 0,
	}
end, },
function(self)
	if nb == 0 then
		self.ps:emit(100)
	elseif nb == 10 and bonus >= 2 then
		self.ps:emit(100)
	elseif nb == 20 and bonus >= 3 then
		self.ps:emit(100)
	end
	nb = (nb + 1) % 40
end,
300, nil, true
