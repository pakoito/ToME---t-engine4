-- TE4 - T-Engine 4
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

colors = {}
colors_simple = {}

function defineColor(name, r, g, b, br, bg, bb)
	colors[name] = {r=r, g=g, b=b, br=br, bg=bg, bb=bb}
	colors_simple[name] = {r, g, b}
end

function colors.simple(c) return {c.r, c.g, c.b} end

defineColor('BLACK', 0, 0, 0)
defineColor('WHITE', 0xFF, 0xFF, 0xFF)
defineColor('SLATE', 0x8C, 0x8C, 0x8C)
defineColor('ORANGE', 0xFF, 0x77, 0x00)
defineColor('RED', 0xC9, 0x00, 0x00)
defineColor('GREEN', 0x00, 0x86, 0x45)
defineColor('BLUE', 0x00, 0x00, 0xE3)
defineColor('UMBER', 0x8E, 0x45, 0x00)
defineColor('LIGHT_DARK', 0x50, 0x50, 0x50)
defineColor('LIGHT_SLATE', 0xD1, 0xD1, 0xD1)
defineColor('VIOLET', 0xC0, 0x00, 0xAF)
defineColor('YELLOW', 0xFF, 0xFF, 0x00)
defineColor('LIGHT_RED', 0xFF, 0x00, 0x68)
defineColor('LIGHT_GREEN', 0x00, 0xFF, 0x00)
defineColor('LIGHT_BLUE', 0x51, 0xDD, 0xFF)
defineColor('LIGHT_UMBER', 0xD7, 0x8E, 0x45)
defineColor('DARK_UMBER', 0x57, 0x5E, 0x25)

defineColor('DARK_GREY', 67, 67, 67)
defineColor('GREY', 127, 127, 127)

defineColor('ROYAL_BLUE', 65, 105, 225)
defineColor('AQUAMARINE', 127, 255, 212)
defineColor('CADET_BLUE', 95, 158, 160)
defineColor('STEEL_BLUE', 70, 130, 180)
defineColor('TEAL', 0, 128, 128)
defineColor('LIGHT_STEEL_BLUE', 176, 196, 222)
defineColor('DARK_BLUE', 0x00, 0x00, 0x93)
defineColor('ROYAL_BLUE', 0x00, 0x6C, 0xFF)

defineColor('PINK', 255, 192, 203)
defineColor('GOLD', 255, 215, 0)
defineColor('FIREBRICK', 178, 34, 34)
defineColor('DARK_RED', 100, 0, 0)
defineColor('VERY_DARK_RED', 50, 0, 0)
defineColor('CRIMSON', 220, 20, 60)
defineColor('MOCCASIN', 255, 228, 181)
defineColor('KHAKI', 240, 230, 130)
defineColor('SANDY_BROWN', 244, 164, 96)
defineColor('SALMON', 250, 128, 114)

defineColor('DARK_ORCHID', 153, 50, 204)
defineColor('ORCHID', 218, 112, 214)
defineColor('PURPLE', 128, 0, 139)

defineColor('CHOCOLATE', 210, 105, 30)
defineColor('DARK_KHAKI', 189, 183, 107)
defineColor('TAN', 210, 180, 140)
defineColor('DARK_TAN', 110, 80, 40)

defineColor('HONEYDEW', 240, 255, 240)
defineColor('ANTIQUE_WHITE', 250, 235, 215)
defineColor('OLD_LACE', 253, 245, 230)
defineColor('DARK_SLATE_GRAY', 47, 79, 79)

defineColor('OLIVE_DRAB', 107, 142, 35)
defineColor('DARK_SEA_GREEN', 143, 188, 143)
defineColor('YELLOW_GREEN', 154, 205, 50)
defineColor('DARK_GREEN', 50, 77, 12)
