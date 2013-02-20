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

base_size = 64
local nb = 1

return {
	system_rotation = 225 + math.deg(math.atan2(ty-sy, tx-sx)), system_rotationv = 0,

	base = 1000,

	angle = { 0, 0 }, anglev = { 0, 0 }, anglea = { 0, 0 },

	life = { 10, 10 },
	size = { 64, 64 }, sizev = {0, 0}, sizea = {0, 0},

	r = {255, 255}, rv = {0, 0}, ra = {0, 0},
	g = {255, 255}, gv = {0, 0}, ga = {0, 0},
	b = {255, 255}, bv = {0, 0}, ba = {0, 0},
	a = {255, 255}, av = {0, 0}, aa = {0, 0},

},
 function(self)
	if nb == 1 then
		self.ps:emit(1)
		nb = nb -1
	end
end,
 1, tile, true
