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
local length = 0
local life = 0
local angle = 0
local r = 0
local distance = 0
local color = 0
local dir = 0
local waveCount = 0
local vel = 0

return { generator = function()
	local colorChoice = rng.percent(50)
	return {
		life = life,
		size = 3.5, sizev = 0, sizea = 0,

		x = r * math.cos(angle) + rng.float(-2, 2), xv = -distance * math.cos(angle) / life, xa = 0,
		y = r * math.sin(angle) + rng.float(-2, 2), yv = -distance * math.sin(angle) / life, ya = 0,
		dir = dir, dirv = 2 * math.pi * waveCount / life, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = color * (colorChoice and 240 or 240) / 255, rv = 0, ra = 0,
		g = color * (colorChoice and 240 or 160) / 255, gv = 0, ga = 0,
		b = color * (colorChoice and 240 or 220) / 255, bv = 0, ba = 0,
		a = rng.float(0.75, 1), av = -0.3 / life, aa = 0,
	}
end, },
function(self)
	if nb == 0 then
		-- initialize a new strand
		 length = rng.range(10, 15) -- length of particle strand
		 life = length + rng.range(3, 8) -- time particles stay alive
		 angle = math.rad(rng.range(0, 360)) -- starting point angle
		 r = rng.range(12, 20) -- starting point distance
		 distance = rng.range(20, 30) -- distance traveled
		 color = rng.float(0.7, 1) -- color
		 dir = math.rad(rng.range(0, 360)) -- initial wave direction
		 waveCount = rng.float(0.8, 1.2) -- number of full waves
		 vel = rng.float(.5, 1) -- power of wave effect
	end
	self.ps:emit(1)
	nb = (nb + 1) % (life + 2)
end,
100, nil, true
