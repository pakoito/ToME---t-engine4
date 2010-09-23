local events = require "util.events";
local uuid = require "util.uuid";
local sha1 = require "util.sha1";

local proxy65_mt = {};
proxy65_mt.__index = proxy65_mt;

local xmlns_bytestreams = "http://jabber.org/protocol/bytestreams";

local negotiate_socks5;

function verse.plugins.proxy65(stream)
	stream.proxy65 = setmetatable({ stream = stream }, proxy65_mt);
	stream.proxy65.available_streamhosts = {};
	local outstanding_proxies = 0;
	stream:hook("disco/service-discovered/proxy", function (service)
		-- Fill list with available proxies
		if service.type == "bytestreams" then
			outstanding_proxies = outstanding_proxies + 1;
			stream:send_iq(verse.iq({ to = service.jid, type = "get" })
				:tag("query", { xmlns = xmlns_bytestreams }), function (result)
				
				outstanding_proxies = outstanding_proxies - 1;
				if result.attr.type == "result" then
					local streamhost = result:get_child("query", xmlns_bytestreams)
						:get_child("streamhost").attr;
					
					stream.proxy65.available_streamhosts[streamhost.jid] = {
						jid = streamhost.jid;
						host = streamhost.host;
						port = tonumber(streamhost.port);
					};
				end
				if outstanding_proxies == 0 then
					stream:event("proxy65/discovered-proxies", stream.proxy65.available_streamhosts);
				end
			end);
		end
	end);
	stream:hook("iq/"..xmlns_bytestreams, function (request)
		local conn = verse.new(nil, {
			initiator_jid = request.attr.from,
			streamhosts = {},
			current_host = 0;
		});
		
		-- Parse hosts from request
		for tag in request.tags[1]:childtags() do
			if tag.name == "streamhost" then
				table.insert(conn.streamhosts, tag.attr);	
			end
		end
		
		--Attempt to connect to the next host
		local function attempt_next_streamhost()
			-- First connect, or the last connect failed
			if conn.current_host < #conn.streamhosts then
				conn.current_host = conn.current_host + 1;
				conn:connect(
					conn.streamhosts[conn.current_host].host,
					conn.streamhosts[conn.current_host].port
				);
				negotiate_socks5(stream, conn, request.tags[1].attr.sid, request.attr.from, stream.jid);
				return true; -- Halt processing of disconnected event
			end
			-- All streamhosts tried, none successful
			conn:unhook("disconnected", attempt_next_streamhost);
			stream:send(verse.error_reply(request, "cancel", "item-not-found"));
			-- Let disconnected event fall through to user handlers...
		end
		
		function conn:accept()
			conn:hook("disconnected", attempt_next_streamhost, 100);
			-- When this event fires, we're connected to a streamhost
			conn:hook("connected", function ()
				conn:unhook("disconnected", attempt_next_streamhost);
				-- Send XMPP success notification
				local reply = verse.reply(request)
					:tag("query", request.tags[1].attr)
					:tag("streamhost-used", { jid = conn.streamhosts[conn.current_host].jid });
				stream:send(reply);
			end, 100);
			attempt_next_streamhost();
		end
		function conn:refuse()
			-- FIXME: XMPP refused reply
		end
		stream:event("proxy65/request", conn);
	end);
end

function proxy65_mt:new(target_jid, proxies)
	local conn = verse.new(nil, {
		target_jid = target_jid;
		bytestream_sid = uuid.generate();
	});
	
	local request = verse.iq{type="set", to = target_jid}
		:tag("query", { xmlns = xmlns_bytestreams, mode = "tcp", sid = conn.bytestream_sid });
	for _, proxy in ipairs(proxies or self.proxies) do
		request:tag("streamhost", proxy):up();
	end
	
	
	self.stream:send_iq(request, function (reply)
		if reply.attr.type == "error" then
			local type, condition, text = reply:get_error();
			conn:event("connection-failed", { conn = conn, type = type, condition = condition, text = text });
		else
			-- Target connected to streamhost, connect ourselves
			local streamhost_used = reply.tags[1]:get_child("streamhost-used");
			if not streamhost_used then
				--FIXME: Emit error
			end
			conn.streamhost_jid = streamhost_used.attr.jid;
			local host, port;
			for _, proxy in ipairs(proxies or self.proxies) do
				if proxy.jid == conn.streamhost_jid then
					host, port = proxy.host, proxy.port;
					break;
				end
			end
			if not (host and port) then
				--FIXME: Emit error
			end
			
			conn:connect(host, port);

			local function handle_proxy_connected()
				conn:unhook("connected", handle_proxy_connected);
				-- Both of us connected, tell proxy to activate connection
				local request = verse.iq{to = conn.streamhost_jid, type="set"}
					:tag("query", { xmlns = xmlns_bytestreams, sid = conn.bytestream_sid })
						:tag("activate"):text(target_jid);
				self.stream:send_iq(request, function (reply)
					if reply.attr.type == "result" then
						-- Connection activated, ready to use
						conn:event("connected", conn);
					else
						--FIXME: Emit error
					end
				end);
				return true;
			end
			conn:hook("connected", handle_proxy_connected, 100);

			negotiate_socks5(self.stream, conn, conn.bytestream_sid, self.stream.jid, target_jid);
		end
	end);
	return conn;
end

function negotiate_socks5(stream, conn, sid, requester_jid, target_jid)
	local hash = sha1.sha1(sid..requester_jid..target_jid);
	local function suppress_connected()
		conn:unhook("connected", suppress_connected);
		return true;
	end
	local function receive_connection_response(data)
		conn:unhook("incoming-raw", receive_connection_response);
		
		if data:sub(1, 2) ~= "\005\000" then
			return conn:event("error", "connection-failure");
		end
		conn:event("connected");
		return true;
	end
	local function receive_auth_response(data)
		conn:unhook("incoming-raw", receive_auth_response);
		if data ~= "\005\000" then -- SOCKSv5; "NO AUTHENTICATION"
			-- Server is not SOCKSv5, or does not allow no auth
			local err = "version-mismatch";
			if data:sub(1,1) == "\005" then
				err = "authentication-failure";
			end
			return conn:event("error", err);
		end
		-- Request SOCKS5 connection
		conn:send(string.char(0x05, 0x01, 0x00, 0x03, #hash)..hash.."\0\0"); --FIXME: Move to "connected"?
		conn:hook("incoming-raw", receive_connection_response, 100);
		return true;
	end
	conn:hook("connected", suppress_connected, 200);
	conn:hook("incoming-raw", receive_auth_response, 100);
	conn:send("\005\001\000"); -- SOCKSv5; 1 mechanism; "NO AUTHENTICATION"
end
