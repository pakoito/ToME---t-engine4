require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, url, on_finish)
	self.url = url
	self.received = 0
	self.on_finish = on_finish

	local font = core.display.newFont("/data/font/Vera.ttf", 12)
	engine.Dialog.init(self, title or "Downloading...", math.max(400, font:size("From: "..url) + 10), 75, nil, nil, nil, font)

	self:keyCommands({
	},{
	})
end

function _M:drawDialog(s)
	if self.th then
		local t = self.linda:receive(0, "final")
		local len = self.linda:receive(0, "received")
		while len do
			len = self.linda:receive(0, "received")
			if len then self.received = len end
		end

		local v, err = self.th:join(0)
		if err then error(err) end

		if t then
			self.changed = false
			self.linda = nil
			self.th = nil
			game:unregisterDialog(self)
			self:on_finish(t)
		end
	end

	s:drawString(self.font, "From: "..self.url, 2, 2, 255, 255, 255)
	s:drawString(self.font, "Received: "..self.received, 2, 25, 255, 255, 255)
end

function _M:startDownload()
	local l = lanes.linda()

	function list_handler(src)
		require "socketed"
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local t = {}
		local size = 0
		http.request{url = src, sink = function(chunk, err)
			if chunk then
				size = size + #chunk
				l:send(0, "received", size)
				table.insert(t, chunk)
			end
			return 1
		end}
		l:send("final", t)
	end

	self.th = lanes.gen("*", list_handler)(self.url)
	self.linda = l
end
