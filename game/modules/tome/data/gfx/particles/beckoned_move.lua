-- ToME - Tales of Middle-Earth
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

dx = dx * base_size
dy = dy * base_size
local angle = math.atan2(dy, dx)

local nb = 0
local strands = {}
local strandCount = 5
local length = 10
for i = 1, strandCount do
	strands[i] = {
		x = rng.float(-12, 12), -- initial offset
		y = rng.float(-12, 12), -- initial offset
		life = length + rng.range(5, 10), -- time particles stay alive
		color = rng.float(0.7, 1), -- color
		dir = math.rad(rng.range(0, 360)), -- initial wave direction
		waveCount = rng.float(0.5, 1.5), -- number of full waves
		vel = rng.float(.6, 1) -- power of wave effect
	}
end
local strandIndex = 1

return { generator = function()
	local size = 4
	local colorChoice = rng.percent(50)

	local strand = strands[strandIndex+1]
	strandIndex = (strandIndex + 1) % strandCount

	return {
		life = strand.life,
		size = size, sizev = 0, sizea = 0,
		x = strand.x, xv = (-base_size * 1 * math.cos(angle) - strand.x) / strand.life, xa = 0,
		y = strand.y, yv = (-base_size * 1 * math.sin(angle) - strand.y) / strand.life, ya = 0,
		dir = strand.dir, dirv = 2 * math.pi * strand.waveCount / strand.life, dira = 0,
		vel = strand.vel, velv = 0, vela = 0,

		r = strand.color * (colorChoice and 240 or 240) / 255,  rv = 0, ra = 0,
		g = strand.color * (colorChoice and 240 or 160) / 255,  gv = 0, ga = 0,
		b = strand.color * (colorChoice and 240 or 220) / 255,  bv = 0, ba = 0,
		a = rng.float(0.75, 1), av = -0.3 / strand.life, aa = 0,
	}
end, },
function(self)
	if nb < length then
		self.ps:emit(strandCount)
	end
	nb = nb + 1
end,
strandCount * 30
