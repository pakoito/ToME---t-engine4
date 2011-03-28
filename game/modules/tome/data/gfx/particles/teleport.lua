-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

return {
	base = 1000,

	angle = { 0, 360 }, anglev = { 2000, 5000 }, anglea = { 20, 60 },

	life = { 20, 30 },
	size = { 3, 7 }, sizev = {0, 0}, sizea = {0, 0},

	r = {10, 220}, rv = {0, 10}, ra = {0, 0},
	g = {10, 100}, gv = {0, 0}, ga = {0, 0},
	b = {20, 255}, bv = {0, 10}, ba = {0, 0},
	a = {25, 255}, av = {0, 0}, aa = {0, 0},

}, function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(100)
	end
end
