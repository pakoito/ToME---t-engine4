
local init_xmlhandlers = require "core.xmlhandlers";
local st = require "util.stanza";
require "net.httpclient_listener"; -- Required for net.http to work
local http = require "net.http";

local stream_mt = setmetatable({}, { __index = verse.stream_mt });
stream_mt.__index = stream_mt;

local xmlns_stream = "http://etherx.jabber.org/streams";
local xmlns_bosh = "http://jabber.org/protocol/httpbind";

local reconnect_timeout = 5;

function verse.new_bosh(logger, url)
	local stream = {
		bosh_conn_pool = {};
		bosh_waiting_requests = {};
		bosh_rid = math.random(1,999999);
		bosh_outgoing_buffer = {};
		bosh_url = url;
		conn = {};
	};
	function stream:reopen()
		self.bosh_need_restart = true;
		self:flush();
	end
	local conn = verse.new(logger, stream);
	return setmetatable(conn, stream_mt);
end

function stream_mt:connect()
	self:_send_session_request();
end

function stream_mt:send(data)
	self:debug("Putting into BOSH send buffer: %s", tostring(data));
	self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1] = st.clone(data);
	self:flush(); --TODO: Optimize by doing this on next tick (give a chance for data to buffer)
end

function stream_mt:flush()
	if self.connected
	and #self.bosh_waiting_requests < self.bosh_max_requests
	and (#self.bosh_waiting_requests == 0
		or #self.bosh_outgoing_buffer > 0
		or self.bosh_need_restart) then
		self:debug("Flushing...");
		local payload = self:_make_body();
		local buffer = self.bosh_outgoing_buffer;
		for i, stanza in ipairs(buffer) do
			payload:add_child(stanza);
			buffer[i] = nil;
		end
		self:_make_request(payload);
	else
		self:debug("Decided not to flush.");
	end
end

function stream_mt:_make_request(payload)
	local request, err = http.request(self.bosh_url, { body = tostring(payload) }, function (response, code, request)
		if code ~= 0 then
			self.inactive_since = nil;
			return self:_handle_response(response, code, request);
		end
		
		-- Connection issues, we need to retry this request
		local time = os.time();
		if not self.inactive_since then
			self.inactive_since = time; -- So we know when it is time to give up
		elseif time - self.inactive_since > self.bosh_max_inactivity then
			return self:_disconnected();
		else
			self:debug("%d seconds left to reconnect, retrying in %d seconds...", 
				self.bosh_max_inactivity - (time - self.inactive_since), reconnect_timeout);
		end
		
		-- Set up reconnect timer
		timer.add_task(reconnect_timeout, function ()
			self:debug("Retrying request...");
			-- Remove old request
			for i, waiting_request in ipairs(self.bosh_waiting_requests) do
				if waiting_request == request then
					table.remove(self.bosh_waiting_requests, i);
					break;
				end
			end
			self:_make_request(payload);
		end);
	end);
	if request then
		table.insert(self.bosh_waiting_requests, request);
	else
		self:warn("Request failed instantly: %s", err);
	end
end

function stream_mt:_disconnected()
	self.connected = nil;
	self:event("disconnected");
end

function stream_mt:_send_session_request()
	local body = self:_make_body();
	
	-- XEP-0124
	body.attr.hold = "1";
	body.attr.wait = "60";
	body.attr["xml:lang"] = "en";
	body.attr.ver = "1.6";

	-- XEP-0206
	body.attr.from = self.jid;
	body.attr.to = self.host;
	body.attr.secure = 'true';
	
	http.request(self.bosh_url, { body = tostring(body) }, function (response, code)
		if code == 0 then
			-- Failed to connect
			return self:_disconnected();
		end
		-- Handle session creation response
		local payload = self:_parse_response(response)
		if not payload then
			self:warn("Invalid session creation response");
			self:_disconnected();
			return;
		end
		self.bosh_sid = payload.attr.sid; -- Session id
		self.bosh_wait = tonumber(payload.attr.wait); -- How long the server may hold connections for
		self.bosh_hold = tonumber(payload.attr.hold); -- How many connections the server may hold
		self.bosh_max_inactivity = tonumber(payload.attr.inactivity); -- Max amount of time with no connections
		self.bosh_max_requests = tonumber(payload.attr.requests) or self.bosh_hold; -- Max simultaneous requests we can make
		self.connected = true;
		self:event("connected");
		self:_handle_response_payload(payload);
	end);
end

function stream_mt:_handle_response(response, code, request)
	if self.bosh_waiting_requests[1] ~= request then
		self:warn("Server replied to request that wasn't the oldest");
		for i, waiting_request in ipairs(self.bosh_waiting_requests) do
			if waiting_request == request then
				self.bosh_waiting_requests[i] = nil;
				break;
			end
		end
	else
		table.remove(self.bosh_waiting_requests, 1);
	end
	local payload = self:_parse_response(response);
	if payload then
		self:_handle_response_payload(payload);
	end
	self:flush();
end

function stream_mt:_handle_response_payload(payload)
	for stanza in payload:childtags() do
		if stanza.attr.xmlns == xmlns_stream then
			self:event("stream-"..stanza.name, stanza);
		elseif stanza.attr.xmlns then
			self:event("stream/"..stanza.attr.xmlns, stanza);
		else
			self:event("stanza", stanza);
		end
	end
	if payload.attr.type == "terminate" then
		self:_disconnected({reason = payload.attr.condition});
	end
end

local stream_callbacks = {
	stream_ns = "http://jabber.org/protocol/httpbind", stream_tag = "body",
	default_ns = "jabber:client",
	streamopened = function (session, attr) session.notopen = nil; session.payload = verse.stanza("body", attr); return true; end;
	handlestanza = function (session, stanza) session.payload:add_child(stanza); end;
};
function stream_mt:_parse_response(response)
	self:debug("Parsing response: %s", response);
	if response == nil then
		self:debug("%s", debug.traceback());
		self:_disconnected();
		return;
	end
	local session = { notopen = true, log = self.log };
	local parser = lxp.new(init_xmlhandlers(session, stream_callbacks), "\1");
	parser:parse(response);
	return session.payload;
end

function stream_mt:_make_body()
	self.bosh_rid = self.bosh_rid + 1;
	local body = verse.stanza("body", {
		xmlns = xmlns_bosh;
		content = "text/xml; charset=utf-8";
		sid = self.bosh_sid;
		rid = self.bosh_rid;
	});
	if self.bosh_need_restart then
		self.bosh_need_restart = nil;
		body.attr.restart = 'true';
	end
	return body;
end
