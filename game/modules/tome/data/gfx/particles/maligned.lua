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
local start = 0
local life = 28
local r = 20
local speed = 150
local dirv = math.pi * 2 / speed
local vel = math.pi * 2 * r / speed

return { generator = function()
	local angle = math.rad(360 * start)
	local dir = math.rad(360 * start + 90)
	
	return {
		life = life,
		size = 10, sizev = 0, sizea = 0,

		x = r * math.cos(angle), xv = 0, xa = 0,
		y = r * math.sin(angle), yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = 200 / 255,  rv = 0, ra = 0,
		g = 40 / 255,  gv = 0, ga = 0,
		b = 70 / 255,  bv = 0, ba = 0,
		a = 0,  av = 3 / life, aa = -6 / (life * life)
	}
end, },
function(self)
	if nb == 0 then
		start = 0
		self.ps:emit(1)
		start = 0.2
		self.ps:emit(1)
		start = 0.4
		self.ps:emit(1)
		start = 0.6
		self.ps:emit(1)
		start = 0.8
		self.ps:emit(1)
	end
	
	nb = (nb + 1) % (life + 2)
end,
10, nil, true
