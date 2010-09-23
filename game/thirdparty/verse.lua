
-- Use LuaRocks if available
pcall(require, "luarocks.require");

-- Load LuaSec if available
pcall(require, "ssl");

local server = require "net.server";
local events = require "util.events";

module("verse", package.seeall);
local verse = _M;

local stream = {};
stream.__index = stream;
stream_mt = stream;

verse.plugins = {};

function verse.new(logger, base)
	local t = setmetatable(base or {}, stream);
	t.id = tostring(t):match("%x*$");
	t:set_logger(logger, true);
	t.events = events.new();
	return t;
end

verse.add_task = require "util.timer".add_task;

verse.logger = logger.init;
verse.log = verse.logger("verse");

function verse.set_logger(logger)
	verse.log = logger;
	server.setlogger(logger);
end

function verse.filter_log(levels, logger)
	local level_set = {};
	for _, level in ipairs(levels) do
		level_set[level] = true;
	end
	return function (level, name, ...)
		if level_set[level] then
			return logger(level, name, ...);
		end
	end;
end

local function error_handler(err)
	verse.log("error", "Error: %s", err);
	verse.log("error", "Traceback: %s", debug.traceback());
end

function verse.set_error_handler(new_error_handler)
	error_handler = new_error_handler;
end

function verse.loop()
	return xpcall(server.loop, error_handler);
end

function verse.step()
	return xpcall(server.step, error_handler);
end

function verse.quit()
	return server.setquitting(true);
end

function stream:connect(connect_host, connect_port)
	connect_host = connect_host or "localhost";
	connect_port = tonumber(connect_port) or 5222;
	
	-- Create and initiate connection
	local conn = socket.tcp()
	conn:settimeout(0);
	local success, err = conn:connect(connect_host, connect_port);
	
	if not success and err ~= "timeout" then
		self:warn("connect() to %s:%d failed: %s", connect_host, connect_port, err);
		return self:event("disconnected", { reason = err }) or false, err;
	end

	local conn = server.wrapclient(conn, connect_host, connect_port, new_listener(self), "*a");
	if not conn then
		self:warn("connection initialisation failed: %s", err);
		return self:event("disconnected", { reason = err }) or false, err;
	end
	
	self.conn = conn;
	local w, t = conn.write, tostring;
	self.send = function (_, data) return w(conn, t(data)); end
	return true;
end

function stream:close()
	if not self.conn then 
		verse.log("error", "Attempt to close disconnected connection - possibly a bug");
		return;
	end
	local on_disconnect = self.conn.disconnect();
	self.conn:close();
	on_disconnect(conn, reason);
end

-- Logging functions
function stream:debug(...)
	if self.logger and self.log.debug then
		return self.logger("debug", ...);
	end
end

function stream:warn(...)
	if self.logger and self.log.warn then
		return self.logger("warn", ...);
	end
end

function stream:error(...)
	if self.logger and self.log.error then
		return self.logger("error", ...);
	end
end

function stream:set_logger(logger, levels)
	local old_logger = self.logger;
	if logger then
		self.logger = logger;
	end
	if levels then
		if levels == true then
			levels = { "debug", "info", "warn", "error" };
		end
		self.log = {};
		for _, level in ipairs(levels) do
			self.log[level] = true;
		end
	end
	return old_logger;
end

function stream_mt:set_log_levels(levels)
	self:set_logger(nil, levels);
end

-- Event handling
function stream:event(name, ...)
	self:debug("Firing event: "..tostring(name));
	return self.events.fire_event(name, ...);
end

function stream:hook(name, ...)
	return self.events.add_handler(name, ...);
end

function stream:unhook(name, handler)
	return self.events.remove_handler(name, handler);
end

function verse.eventable(object)
        object.events = events.new();
        object.hook, object.unhook = stream.hook, stream.unhook;
        local fire_event = object.events.fire_event;
        function object:event(name, ...)
                return fire_event(name, ...);
        end
        return object;
end

function stream:add_plugin(name)
	if require("verse.plugins."..name) then
		local ok, err = verse.plugins[name](self);
		if ok then
			self:debug("Loaded %s plugin", name);
		else
			self:warn("Failed to load %s plugin: %s", name, err);
		end
	end
	return self;
end

-- Listener factory
function new_listener(stream)
	local conn_listener = {};
	
	function conn_listener.onconnect(conn)
		stream.connected = true;
		stream.send = function (stream, data) stream:debug("Sending data: "..tostring(data)); return conn:write(tostring(data)); end;
		stream:event("connected");
	end
	
	function conn_listener.onincoming(conn, data)
		stream:event("incoming-raw", data);
	end
	
	function conn_listener.ondisconnect(conn, err)
		stream.connected = false;
		stream:event("disconnected", { reason = err });
	end

	function conn_listener.ondrain(conn)
		stream:event("drained");
	end
	
	function conn_listener.onstatus(conn, new_status)
		stream:event("status", new_status);
	end
	
	return conn_listener;
end


local log = require "util.logger".init("verse");

return verse;
