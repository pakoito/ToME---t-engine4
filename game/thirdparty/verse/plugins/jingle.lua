local sha1 = require "util.sha1".sha1;
local st = require "util.stanza";
local timer = require "util.timer";
local uuid_generate = require "util.uuid".generate;

local xmlns_jingle = "urn:xmpp:jingle:1";
local xmlns_jingle_errors = "urn:xmpp:jingle:errors:1";

local jingle_mt = {};
jingle_mt.__index = jingle_mt;

local registered_transports = {};
local registered_content_types = {};

function verse.plugins.jingle(stream)
	stream:hook("ready", function ()
		stream:add_disco_feature(xmlns_jingle);
	end, 10);
	
	function stream:jingle(to)
		return verse.eventable(setmetatable(base or {
			role = "initiator";
			peer = to;
			sid = uuid_generate();
			stream = stream;
		}, jingle_mt));
	end
	
	function stream:register_jingle_transport(transport)
		-- transport is a function that receives a
		-- <transport> element, and returns a connection
		-- We wait for 'connected' on that connection,
		-- and use :send() and 'incoming-raw'.
	end
	
	function stream:register_jingle_content_type(content)
		-- Call content() for every 'incoming-raw'?
		-- I think content() returns the object we return
		-- on jingle:accept()
	end
	
	local function handle_incoming_jingle(stanza)
		local jingle_tag = stanza:get_child("jingle", xmlns_jingle);
		local sid = jingle_tag.attr.sid;
		local action = jingle_tag.attr.action;
		local result = stream:event("jingle/"..sid, stanza);
		if result == true then
			-- Ack
			stream:send(verse.reply(stanza));
			return true;
		end
		-- No existing Jingle object handled this action, our turn...
		if action ~= "session-initiate" then
			-- Trying to send a command to a session we don't know
			local reply = st.error_reply(stanza, "cancel", "item-not-found")
				:tag("unknown-session", { xmlns = xmlns_jingle_errors }):up();
			stream:send(reply);
			return;
		end
		
		-- Ok, session-initiate, new session
		
		-- Create new Jingle object
		local sid = jingle_tag.attr.sid;
		
		local jingle = verse.eventable{
			role = "receiver";
			peer = stanza.attr.from;
			sid = sid;
			stream = stream;
		};
		
		setmetatable(jingle, jingle_mt);
		
		local content_tag;
		local content, transport;
		for tag in jingle_tag:childtags() do
			if tag.name == "content" and tag.attr.xmlns == xmlns_jingle then
			 	local description_tag = tag:child_with_name("description");
			 	local description_xmlns = description_tag.attr.xmlns;
			 	if description_xmlns then
			 		local desc_handler = stream:event("jingle/content/"..description_xmlns, jingle, description_tag);
			 		if desc_handler then
			 			content = desc_handler;
			 		end
			 	end
				
				local transport_tag = tag:child_with_name("transport");
				local transport_xmlns = transport_tag.attr.xmlns;
				
				transport = stream:event("jingle/transport/"..transport_xmlns, jingle, transport_tag);
				if content and transport then
					content_tag = tag;
					break;
				end
			end
		end
		if not content then
			-- FIXME: Fail, no content
			stream:send(st.error_reply(stanza, "cancel", "feature-not-implemented", "The specified content is not supported"));
			return;
		end
		
		if not transport then
			-- FIXME: Refuse session, no transport
			stream:send(st.error_reply(stanza, "cancel", "feature-not-implemented", "The specified transport is not supported"));
			return;
		end
		
		stream:send(st.reply(stanza));
		
		jingle.content_tag = content_tag;
		jingle.creator, jingle.name = content_tag.attr.creator, content_tag.attr.name;
		jingle.content, jingle.transport = content, transport;
		
		function jingle:decline()
			-- FIXME: Decline session
		end
		
		stream:hook("jingle/"..sid, function (stanza)
			if stanza.attr.from ~= jingle.peer then
				return false;
			end
			local jingle_tag = stanza:get_child("jingle", xmlns_jingle);
			return jingle:handle_command(jingle_tag);
		end);
		
		stream:event("jingle", jingle);
		return true;
	end
	
	function jingle_mt:handle_command(jingle_tag)
		local action = jingle_tag.attr.action;
		stream:debug("Handling Jingle command: %s", action);
		if action == "session-terminate" then
			self:destroy();
		elseif action == "session-accept" then
			-- Yay!
			self:handle_accepted(jingle_tag);
		elseif action == "transport-info" then
			stream:debug("Handling transport-info");
			self.transport:info_received(jingle_tag);
		elseif action == "transport-replace" then
			-- FIXME: Used for IBB fallback
			stream:error("Peer wanted to swap transport, not implemented");
		else
			-- FIXME: Reply unhandled command
			stream:warn("Unhandled Jingle command: %s", action);
			return nil;
		end
		return true;
	end

	function jingle_mt:send_command(command, element, callback)
		local stanza = st.iq({ to = self.peer, type = "set" })
			:tag("jingle", {
				xmlns = xmlns_jingle,
				sid = self.sid,
				action = command,
				initiator = self.role == "initiator" and self.stream.jid or nil,
				responder = self.role == "responder" and self.jid or nil,
			}):add_child(element);
		if not callback then
			self.stream:send(stanza);
		else
			self.stream:send_iq(stanza, callback);
		end
	end
		
	function jingle_mt:accept(options)
		local accept_stanza = st.iq({ to = self.peer, type = "set" })
			:tag("jingle", {
				xmlns = xmlns_jingle,
				sid = self.sid,
				action = "session-accept",
				responder = stream.jid,
			})
				:tag("content", { creator = self.creator, name = self.name });
		
		local content_accept_tag = self.content:generate_accept(self.content_tag:child_with_name("description"), options);
		accept_stanza:add_child(content_accept_tag);
		
		local transport_accept_tag = self.transport:generate_accept(self.content_tag:child_with_name("transport"), options);
		accept_stanza:add_child(transport_accept_tag);
		
		local jingle = self;
		stream:send_iq(accept_stanza, function (result)
			if result.attr.type == "error" then
				local type, condition, text = result:get_error();
				stream:error("session-accept rejected: %s", condition); -- FIXME: Notify
				return false;
			end
			jingle.transport:connect(function (conn)
				stream:warn("CONNECTED (receiver)!!!");
				jingle.state = "active";
				jingle:event("connected", conn);
			end);
		end);
	end
	

	stream:hook("iq/"..xmlns_jingle, handle_incoming_jingle);
	return true;
end

function jingle_mt:offer(name, content)
	local session_initiate = st.iq({ to = self.peer, type = "set" })
		:tag("jingle", { xmlns = xmlns_jingle, action = "session-initiate",
			initiator = self.stream.jid, sid = self.sid });
	
	-- Content tag
	session_initiate:tag("content", { creator = self.role, name = name });
	
	-- Need description element from someone who can turn 'content' into XML
	local description = self.stream:event("jingle/describe/"..name, content);
	
	if not description then
		return false, "Unknown content type";
	end
	
	session_initiate:add_child(description);
	
	-- FIXME: Sort transports by 1) recipient caps 2) priority (SOCKS vs IBB, etc.)
	-- Fixed to s5b in the meantime
	local transport = self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1", self);
	self.transport = transport;
	
	session_initiate:add_child(transport:generate_initiate());
	
	self.stream:debug("Hooking %s", "jingle/"..self.sid);
	self.stream:hook("jingle/"..self.sid, function (stanza)
		if stanza.attr.from ~= self.peer then
			return false;
		end
		local jingle_tag = stanza:get_child("jingle", xmlns_jingle);
		return self:handle_command(jingle_tag)
	end);
	
	self.stream:send_iq(session_initiate, function (result)
		if result.type == "error" then
			self.state = "terminated";
			local type, condition, text = result:get_error();
			return self:event("error", { type = type, condition = condition, text = text });
		end
	end);
	self.state = "pending";
end

function jingle_mt:terminate(reason)
	local reason_tag = verse.stanza("reason"):tag(reason or "success");
	self:send_command("session-terminate", reason_tag, function (result)
		self.state = "terminated";
		self.transport:disconnect();
		self:destroy();
	end);
end

function jingle_mt:destroy()
	self:event("terminated");
	self.stream:unhook("jingle/"..self.sid, self.handle_command);
end

function jingle_mt:handle_accepted(jingle_tag)
	local transport_tag = jingle_tag:child_with_name("transport");
	self.transport:handle_accepted(transport_tag);
	self.transport:connect(function (conn)
		print("CONNECTED (initiator)!")
		-- Connected, send file
		self.state = "active";
		self:event("connected", conn);
	end);
end

function jingle_mt:set_source(source, auto_close)
	local function pump()
		local chunk, err = source();
		if chunk and chunk ~= "" then
			self.transport.conn:send(chunk);
		elseif chunk == "" then
			return pump(); -- We need some data!
		elseif chunk == nil then
			if auto_close then
				self:terminate();
			end
			self.transport.conn:unhook("drained", pump);
			source = nil;
		end
	end
	self.transport.conn:hook("drained", pump);
	pump();
end

function jingle_mt:set_sink(sink)
	self.transport.conn:hook("incoming-raw", sink);
	self.transport.conn:hook("disconnected", function (event)
		self.stream:debug("Closing sink...");
		local reason = event.reason;
		if reason == "closed" then reason = nil; end
		sink(nil, reason);
	end);
end
