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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, url, on_chunk, on_finish, on_error)
	self.url = url
	self.received = 0
	self.on_chunk = on_chunk
	self.on_finish = on_finish
	self.on_error = on_error

	local font = core.display.newFont("/data/font/Vera.ttf", 12)
	engine.Dialog.init(self, title or "Downloading...", math.max(400, font:size("From: "..url) + 10), 75, nil, nil, nil, font)

	self:keyCommands({
	},{
	})
end

function _M:drawDialog(s)
	if self.th then
		local ck = self.linda:receive(0, "received")
		while ck do
			if ck then
				if not ck.error then
					self.received = ck.size
					self.on_chunk(ck.chunk)
				else
					self.on_error(ck.error)
					break
				end
			end
			ck = self.linda:receive(0, "received")
		end
		local t = self.linda:receive(0, "final")

		local v, err = self.th:join(0)
		if err then error(err) end

		if t then
			self.changed = false
			self.linda = nil
			self.th = nil
			game:unregisterDialog(self)
			self:on_finish()
		end
	end

	s:drawStringBlended(self.font, "From: "..self.url, 2, 2, 255, 255, 255)
	s:drawStringBlended(self.font, "Received: "..self.received, 2, 25, 255, 255, 255)
end

function _M:startDownload()
	local l = lanes.linda()

	function list_handler(src)
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local size = 0
		http.TIMEOUT = 10
		http.request{url = src, sink = function(chunk, err)
			if err then
				l:send(0, "received", {error=err})
			end
			if chunk then
				size = size + #chunk
				l:send(0, "received", {size=size, chunk=chunk})
			end
			return 1
		end}
		l:send("final", true)
	end

	self.th = lanes.gen("*", list_handler)(self.url)
	self.linda = l
end
