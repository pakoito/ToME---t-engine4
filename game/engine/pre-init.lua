-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

-- Turn on LuaJIT if available
pcall(require, "jit")
if jit then
	jit.on()
	require("jit.opt").start(2)
	print("LuaVM:", jit.version, jit.arch)
else
	print("LuaVM:", _VERSION)
end

-- Requiring "socketed" instead of "socket" makes sockets work
-- Thsi is due to the way luasocket is embeded statically in TE4
require "socketed"
