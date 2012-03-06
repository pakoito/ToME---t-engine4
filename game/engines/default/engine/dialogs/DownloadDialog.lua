-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
local dispatch = require "dispatch"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, url, on_chunk, on_finish, on_error)
	self.url = url
	self.received = 0
	self.on_chunk = on_chunk
	self.on_finish = on_finish
	self.on_error = on_error

	Dialog.init(self, title or "Download", 1, 1)

	local desc = Textzone.new{text="Downloading from "..url, width=400, auto_height=true}

	self:loadUI{
		{left=0, top=0, ui=desc},
	}
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:startDownload()
--[[
	local l = lanes.linda()

	function list_handler(src)
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local size = 0
		http.TIMEOUT = 1200
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
-- ]]
--[[
	local co = coroutine.create(function()
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local size = 0
		http.TIMEOUT = 1200
		print("Downloading from", self.url)
		http.request{url = self.url, sink = function(chunk, err)
			coroutine.yield()
			return 1
		end}

		game:unregisterDialog(self)
	end)
	game:registerCoroutine("download module list", co)
]]
	local http = require "socket.http"
	local ltn12 = require "ltn12"
	local handler = dispatch.newhandler("coroutine")
	local done = false
	handler:start(function()
		print("plop")
		http.request{
			url = self.url,
			sink = function(chunk, err) print("=====") end,
			create = handler.tcp,
		}
		done = true
	end)
	while not done do
		handler:step()
		coroutine.yield()
	end
end
