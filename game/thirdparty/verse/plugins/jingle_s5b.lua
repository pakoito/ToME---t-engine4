
local xmlns_s5b = "urn:xmpp:jingle:transports:s5b:1";
local sha1 = require "util.sha1".sha1;
local uuid_generate = require "util.uuid".generate;

local function negotiate_socks5(conn, hash)
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

local function connect_to_usable_streamhost(callback, streamhosts, auth_token)
	local conn = verse.new(nil, {
		streamhosts = streamhosts,
		current_host = 0;
	});
	--Attempt to connect to the next host
	local function attempt_next_streamhost(event)
		if event then
			return callback(nil, event.reason); 
		end
		-- First connect, or the last connect failed
		if conn.current_host < #conn.streamhosts then
			conn.current_host = conn.current_host + 1;
			conn:debug("Attempting to connect to "..conn.streamhosts[conn.current_host].host..":"..conn.streamhosts[conn.current_host].port.."...");
			local ok, err = conn:connect(
				conn.streamhosts[conn.current_host].host,
				conn.streamhosts[conn.current_host].port
			);
			if not ok then
				conn:debug("Error connecting to proxy (%s:%s): %s", 
					conn.streamhosts[conn.current_host].host,
					conn.streamhosts[conn.current_host].port,
					err
				);
			else
				conn:debug("Connecting...");
			end
			negotiate_socks5(conn, auth_token);
			return true; -- Halt processing of disconnected event
		end
		-- All streamhosts tried, none successful
		conn:unhook("disconnected", attempt_next_streamhost);
		return callback(nil);
		-- Let disconnected event fall through to user handlers...
	end
	conn:hook("disconnected", attempt_next_streamhost, 100);
	-- When this event fires, we're connected to a streamhost
	conn:hook("connected", function ()
		conn:unhook("disconnected", attempt_next_streamhost);
		callback(conn.streamhosts[conn.current_host], conn);
	end, 100);
	attempt_next_streamhost(); -- Set it in motion
	return conn;
end

function verse.plugins.jingle_s5b(stream)
	stream:hook("ready", function ()
		stream:add_disco_feature(xmlns_s5b);
	end, 10);

	local s5b = {};
	
	function s5b:generate_initiate()
		self.s5b_sid = uuid_generate();
		local transport = verse.stanza("transport", { xmlns = xmlns_s5b,
			mode = "tcp", sid = self.s5b_sid });
		local p = 0;
		for jid, streamhost in pairs(stream.proxy65.available_streamhosts) do
			p = p + 1;
			transport:tag("candidate", { jid = jid, host = streamhost.host,
				port = streamhost.port, cid=jid, priority = p, type = "proxy" }):up();
		end
		stream:debug("Have %d proxies", p)
		return transport;
	end
	
	function s5b:generate_accept(initiate_transport)
		local candidates = {};
		self.s5b_peer_candidates = candidates;
		self.s5b_mode = initiate_transport.attr.mode or "tcp";
		self.s5b_sid = initiate_transport.attr.sid or self.jingle.sid;
		
		-- Import the list of candidates the initiator offered us
		for candidate in initiate_transport:childtags() do
			--if candidate.attr.jid == "asterix4@jabber.lagaule.org/Gajim"
			--and candidate.attr.host == "82.246.25.239" then
				candidates[candidate.attr.cid] = {
					type = candidate.attr.type;
					jid = candidate.attr.jid;
					host = candidate.attr.host;
					port = tonumber(candidate.attr.port) or 0;
					priority = tonumber(candidate.attr.priority) or 0;
					cid = candidate.attr.cid;
				};
			--end
		end
		
		-- Import our own candidates
		-- TODO ^
		local transport = verse.stanza("transport", { xmlns = xmlns_s5b });
		return transport;
	end
	
	function s5b:connect(callback)
		stream:warn("Connecting!");
		
		local streamhost_array = {};
		for cid, streamhost in pairs(self.s5b_peer_candidates or {}) do
			streamhost_array[#streamhost_array+1] = streamhost;
		end
		
		if #streamhost_array > 0 then
			self.connecting_peer_candidates = true;
			local function onconnect(streamhost, conn)
				self.jingle:send_command("transport-info", verse.stanza("content", { creator = self.creator, name = self.name })
					:tag("transport", { xmlns = xmlns_s5b, sid = self.s5b_sid })
						:tag("candidate-used", { cid = streamhost.cid }));
				self.onconnect_callback = callback;
				self.conn = conn;
			end
			local auth_token = sha1(self.s5b_sid..self.peer..stream.jid, true);
			connect_to_usable_streamhost(onconnect, streamhost_array, auth_token);
		else
			stream:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
			self.onconnect_callback = callback;
		end
	end
	
	function s5b:info_received(jingle_tag)
		stream:warn("Info received");
		local content_tag = jingle_tag:child_with_name("content");
		local transport_tag = content_tag:child_with_name("transport");
		if transport_tag:get_child("candidate-used") and not self.connecting_peer_candidates then
			local candidate_used = transport_tag:child_with_name("candidate-used");
			if candidate_used then
				-- Connect straight away to candidate used, we weren't trying any anyway
				local function onconnect(streamhost, conn)
					if self.jingle.role == "initiator" then -- More correct would be - "is this a candidate we offered?"
						-- Activate the stream
						self.jingle.stream:send_iq(verse.iq({ to = streamhost.jid, type = "set" })
							:tag("query", { xmlns = xmlns_bytestreams, sid = self.s5b_sid })
								:tag("activate"):text(self.jingle.peer), function (result)
							
							if result.attr.type == "result" then
								self.jingle:send_command("transport-info", verse.stanza("content", content_tag.attr)
									:tag("transport", { xmlns = xmlns_s5b, sid = self.s5b_sid })
										:tag("activated", { cid = candidate_used.attr.cid }));
								self.conn = conn;
								self.onconnect_callback(conn);
							else
								self.jingle.stream:error("Failed to activate bytestream");
							end
						end);
					end
				end
				
				-- FIXME: Another assumption that cid==jid, and that it was our candidate
				self.jingle.stream:debug("CID: %s", self.jingle.stream.proxy65.available_streamhosts[candidate_used.attr.cid]);
				local streamhost_array = {
					self.jingle.stream.proxy65.available_streamhosts[candidate_used.attr.cid];
				};

				local auth_token = sha1(self.s5b_sid..stream.jid..self.peer, true);
				connect_to_usable_streamhost(onconnect, streamhost_array, auth_token);
			end
		elseif transport_tag:get_child("activated") then
			self.onconnect_callback(self.conn);
		end
	end
	
	function s5b:disconnect()
		if self.conn then
			self.conn:close();
		end
	end
	
	function s5b:handle_accepted(jingle_tag)
	end

	local s5b_mt = { __index = s5b };
	stream:hook("jingle/transport/"..xmlns_s5b, function (jingle)
		return setmetatable({
			role = jingle.role,
			peer = jingle.peer,
			stream = jingle.stream,
			jingle = jingle,
		}, s5b_mt);
	end);
end
