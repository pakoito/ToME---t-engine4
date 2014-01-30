-- ToME - Tales of Middle-Earth
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

-- Make up the grids list
local gs = {}
max_alpha = max_alpha or 220

-- Compute the clipping circle
local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
for i = -radius, radius do for j = -radius, radius  do
	local lastx, lasty = 0, 0
	local l = line.new(0, 0, i, j)
	local lx, ly = l()
	while lx do
		if grids[lx+tx] and grids[lx+tx][ly+ty] then
			lastx, lasty = lx, ly
		else
			gs[lx] = gs[lx] or {}
			gs[lx][ly] = {x=lastx, y=lasty, radius=math.sqrt(lastx^2 + lasty^2)}
--			print("block", lx, ly, "=>", math.sqrt(lastx^2 + lasty^2))
		end
		lx, ly = l()
	end
end end

local nb = 0
return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(sradius - 12, sradius)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	if gs[bx] and gs[bx][by] and rng.chance(2) then
--		print("block at angle", ad, radius, ":=>", gs[bx][by].radius)
		radius = gs[bx][by].radius
		sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local r = rng.float(sradius - 5, sradius)
		x = r * math.cos(a)
		y = r * math.sin(a)
	end
	local static = rng.percent(40)

	return {
		trail = 1,
		life = 24,
		size = 3, sizev = static and 0.05 or 0.15, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = static and a + math.rad(90 + rng.range(10, 20)) or a, dirv = 0, dira = 0,
		vel = static and 2 or 0.5 * (-1-nb) * radius / 2.7, velv = 0, vela = static and 0.01 or rng.float(-0.3, -0.2) * 0.3,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = 0, ga = 0,
		b = 0,                        bv = 0, ba = 0,
		a = rng.range(25, max_alpha)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	if nb < 5 then
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
	end
end,
5*radius*266

--[[
local nb = 0
return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local r = rng.range(2, sradius)
	local boundx = r * math.cos(a)
	local boundy = r * math.sin(a)
	local x = math.floor(boundx / engine.Map.tile_w) + tx
	local y = math.floor(boundy / engine.Map.tile_h) + ty
	if not grids[x] or not grids[x][y] then return end

	return {
		trail = 1,
		life = 12,
		size = 3, sizev = 0.3, sizea = 0,

		x = boundx, xv = 0, xa = 0,
		y = boundy, yv = 0, ya = 0,
--		x = r * math.cos(a), xv = -0.1, xa = 0,
--		y = r * math.sin(a), yv = -0.1, ya = 0,
		dir = a + 5 * math.rad(rng.range(10, 20)), dirv = math.rad(rng.range(10, 20)), dira = -math.rad(2),
		vel = 1, velv = 0, vela = 0.1,

		r = rng.range(200, 255)/255,   rv = 0, ra = 0,
		g = rng.range(120, 170)/255,   gv = 0, ga = 0,
		b = rng.range(0, 10)/255,      bv = 0, ba = 0,
		a = rng.range(25, 220)/255,    av = 0, aa = 0,
	}
end, },
function(self)
	if nb < 2 then
		self.ps:emit(800)
		nb = nb + 1
	end
end,
5000
]]