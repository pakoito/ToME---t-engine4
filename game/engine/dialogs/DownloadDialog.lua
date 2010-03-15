require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, url, on_finish)
	self.url = url
	self.received = 0
	self.on_finish = on_finish

	engine.Dialog.init(self, title or "Download", 400, 100)

	self:keyCommands({
	},{
	})
end

function _M:drawDialog(s)
	if self.th then
		local t = self.linda:receive(0, "final")
--		print("done ?", t)

		local len = self.linda:receive(0, "received")
		print("got", len)
		if len then self.received = self.received + len end

		local v, err = self.th:join(0)
		if err then error(err) end

		if t then
			print("done !", #t, table.concat(t))
			self.changed = false
			self.linda = nil
			self.th = nil
		end
	end

	s:drawString(self.font, "Received: "..self.received, 2, 2, 255, 255, 255)
end

function _M:startDownload()
	local l = lanes.linda()

	function list_handler(src)
		require "socketed"
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local t = {}
		http.request{url = src, sink = function(chunk, err)
			if chunk then
				l:send(0, "received", #chunk)
				table.insert(t, chunk)
			end
			return 1
		end}
		l:send("final", t)
	end

	self.th = lanes.gen("*", list_handler)(self.url)
	self.linda = l
end
