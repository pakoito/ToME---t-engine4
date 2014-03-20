-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

if not core.webview then return end

local class = require "class"

core.webview.paths = {}

function core.webview.responder(id, path)
	path = "/"..path
	print("[WEBCORE] path request: ", path)

	-- Let hook do their stuff
	local reply = {}
	if class:triggerHook{"Web:request", path=path, reply=reply} and reply.data then
		core.webview.localReplyData(id, reply.mime, reply.data)
		return
	end

	-- No hooks, perhaps we have a registered path matching
	for mpath, fct in pairs(core.webview.paths) do
		local r = {path:find("^"..mpath)}
		if r[1] then
			table.remove(r, 1) table.remove(r, 1)
			local mime, data = fct(path, unpack(r))
			if mime and data then
				core.webview.localReplyData(id, mime, data)
				return
			end
		end
	end

	-- Default, check for a file in /data/
	local mime = "application/octet-stream"
	if path:find("%.html$") then mime = "text/html"
	elseif path:find("%.js$") then mime = "text/javascript"
	elseif path:find("%.css$") then mime = "text/css"
	elseif path:find("%.png$") then mime = "image/png"
	end
	core.webview.localReplyFile(id, mime, "/data"..path)
end

core.webview.paths["/example/(.*)"] = function(path, sub)
	return "text/html", "example sub url was: "..sub
end
