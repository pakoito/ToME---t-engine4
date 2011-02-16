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

require "engine.class"
local socket = require "socket"

module(..., package.seeall, class.make)

function _M:init()
end

function _M:connect()
	if not self.login or not self.pass then return end
	if self.sock then return true end
	self.sock = socket.connect("te4.org", 5122)
	if not self.sock then return end
	return self:login()
end

function _M:write(str, ...)
	self.sock:send(str:format(...))
end

function _M:read(ncode)
	local l = self.sock:receive("*l")
	if not l then error("no data") end
	if ncode and l:sub(1, 3) ~= ncode then
		error("bad return code: "..ncode.." != "..l:sub(1, 3))
	end
	return l
end

function _M:login()
	if self.login and self.pass then
		self:write("%s\n%s\n", self.login, self.pass)
		if self:read("200") then
			return true
		end
	end
end

function _M:command(c, ...)
	self.sock:send(("%s %s\n"):format(c, table.concat({...}, " ")))
end

function _M:run()
	while true do
		if self:connect() then
			local l = self:read()
			print("GOT: ", l)
		else
			core.game.sleep(5000) -- Wait 5 seconds before retry
		end
	end
end
