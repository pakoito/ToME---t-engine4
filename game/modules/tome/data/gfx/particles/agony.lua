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

local distributionOffset = math.rad(rng.range(0, 360))

return { generator = function()
	local life = 20
	local size = 3
	local angle = math.rad(rng.range(0, 360))
	local distribution = (math.sin(angle + distributionOffset) + 1) / 2
	local distance = engine.Map.tile_w * rng.float(0.2, 0.2 + 0.08 * power)
	local alpha = (80 - distribution * 50) / 255
	local vel = 4 * distance / life
	
	return {
		trail = 1,
		life = life,
		size = size, sizev = size / life / 3, sizea = 0,

		x = -size / 2, xv = 0, xa = 0,
		y = -size / 2, yv = 0, ya = 0,
		dir = angle, dirv = 0, dira = 0,
		vel = vel, velv = -vel / life * 2, vela = 0,
		
		r = (100 + distribution * 100) / 255,  rv = 0, ra = 0,
		g = 64 / 255,  gv = 0, ga = 0,
		b = (200 - distribution * 100) / 255,  bv = 0, ba = 0,
		a = alpha,  av = -alpha / life / 2, aa = 0,
	}
end, },
function(self)
	self.ps:emit(200)
end,
100

--[[
local life = 7

return { generator = function()
	local distance1 = engine.Map.tile_w * rng.float(0, 0.2 + 0.08 * power)
	local distance2 = engine.Map.tile_w * rng.float(0, 0.2 + 0.08 * power)
	local angle1 = math.rad(rng.range(0, 360))
	local angle2 = math.rad(rng.range(0, 360))
	local x1 = distance1 * math.cos(angle1)
	local y1 = distance1 * math.sin(angle1)
	local x2 = distance2 * math.cos(angle2)
	local y2 = distance2 * math.sin(angle2)

	return {
		trail = 5,
		life = life,
		size = 2, sizev = 0, sizea = 0,

		x = x1, xv = (x2 - x1) / life, xa = 0,
		y = y1, yv = (y2 - y1) / life, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 64 / 255,  rv = 0, ra = 0,
		g = 32 / 255,  gv = 0, ga = 0,
		b = 96 / 255,  bv = 0, ba = 0,
		a = 100 / 255,  av = 80 / 255 / life, aa = 0,
	}
end, },
function(self)
	self.ps:emit(power + 1)
end,
(power + 1) * life * 5
]]