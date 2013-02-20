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

local distributionOffset = math.rad(rng.range(0, 360))

return { generator = function()
	local life = rng.float(6, 10)
	local size = 1
	local angle = math.rad(rng.range(0, 360))
	local distribution = (math.sin(angle + distributionOffset) + 1) / 2
	local distance = engine.Map.tile_w * rng.float(0.3, 0.9)
	local startX = distance * math.cos(angle) + dx * engine.Map.tile_w
	local startY = distance * math.sin(angle) + dy * engine.Map.tile_h
	local alpha = (80 - distribution * 50) / 255
	
	local speed = 0.02
	local dirv = math.pi * 2 * speed
	local vel = math.pi * distance * speed
	
	return {
		trail = 1,
		life = life,
		size = size, sizev = size / life / 3, sizea = 0,

		x = -size / 2 + startX, xv = -startX / life, xa = 0,
		y = -size / 2 + startY, yv = -startY / life, ya = 0,
		dir = angle + math.rad(90), dirv = dirv, dira = 0,
		vel = vel, velv = -vel / life, vela = 0,
		
		r = (100 + distribution * 100) / 255,  rv = 0, ra = 0,
		g = 64 / 255,  gv = 0, ga = 0,
		b = (200 - distribution * 100) / 255,  bv = 0, ba = 0,
		a = 20 / 255,  av = alpha / life / 2, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb <= 5 then
		self.ps:emit(500 - 60 * self.nb)
	end
end,
500 * 10
