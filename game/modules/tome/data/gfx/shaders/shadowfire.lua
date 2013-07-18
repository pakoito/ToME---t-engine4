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

return {
	frag = "shadowfire",
	vert = nil,
	args = {
		tex = { texture = 0 },
		mainfbo = { texture = 1 },
		color = color or {0.4, 0.7, 1.0},
		time_factor = time_factor or 25000,
		aadjust = aadjust or 10,
		ellipsoidalFactor = 1.5,
		oscillationSpeed = 20.0,
		antialiasingRadius = 0.6,
		shieldIntensity = 0.15,
		leftColor1 = {11.0  / 255.0, 8.0 / 255.0, 10.0 / 255},
		leftColor2 = {171.0 / 255.0, 4.0 / 255.0, 10.0 / 255},
		rightColor1 = {171.0 / 255.0, 4.0 / 255.0, 10.0 / 255},
		rightColor2 = {11.0  / 255.0, 8.0 / 255.0, 10.0 / 255},
	},
	clone = false,
}