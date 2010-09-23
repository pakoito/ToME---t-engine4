local adhoc = require "lib.adhoc";

local xmlns_commands = "http://jabber.org/protocol/commands";
local xmlns_data = "jabber:x:data";

local command_mt = {};
command_mt.__index = command_mt;

-- Table of commands we provide
local commands = {};

function verse.plugins.adhoc(stream)
	stream:add_disco_feature(xmlns_commands);

	function stream:query_commands(jid, callback)
		stream:disco_items(jid, xmlns_commands, function (items)
			stream:debug("adhoc list returned")
			local command_list = {};
			for _, item in ipairs(items) do
				command_list[item.node] = item.name;
			end
			stream:debug("adhoc calling callback")
			return callback(command_list);
		end);
	end
	
	function stream:execute_command(jid, command, callback)
		local cmd = setmetatable({
			stream = stream, jid = jid,
			command = command, callback = callback 
		}, command_mt);
		return cmd:execute();
	end
	
	-- ACL checker for commands we provide
	local function has_affiliation(jid, aff)
		if not(aff) or aff == "user" then return true; end
		if type(aff) == "function" then
			return aff(jid);
		end
		-- TODO: Support 'roster', etc.
	end
	
	function stream:add_adhoc_command(name, node, handler, permission)
		commands[node] = adhoc.new(name, node, handler, permission);
		stream:add_disco_item({ jid = stream.jid, node = node, name = name }, xmlns_commands);
		return commands[node];
	end
	
	local function handle_command(stanza)
		local command_tag = stanza.tags[1];
		local node = command_tag.attr.node;
		
		local handler = commands[node];
		if not handler then return; end
		
		if not has_affiliation(stanza.attr.from, handler.permission) then
			stream:send(verse.error_reply(stanza, "auth", "forbidden", "You don't have permission to execute this command"):up()
			:add_child(handler:cmdtag("canceled")
				:tag("note", {type="error"}):text("You don't have permission to execute this command")));
			return true
		end
		
		-- User has permission now execute the command
		return adhoc.handle_cmd(handler, { send = function (d) return stream:send(d) end }, stanza);
	end
	
	stream:hook("iq/"..xmlns_commands, function (stanza)
		local type = stanza.attr.type;
		local name = stanza.tags[1].name;
		if type == "set" and name == "command" then
			return handle_command(stanza);
		end
	end);
end

function command_mt:_process_response(result)
	if result.type == "error" then
		self.status = "canceled";
		self.callback(self, {});
	end
	local command = result:get_child("command", xmlns_commands);
	self.status = command.attr.status;
	self.sessionid = command.attr.sessionid;
	self.form = command:get_child("x", xmlns_data);
	self.callback(self);
end

-- Initial execution of a command
function command_mt:execute()
	io.write(":execute()\n");
	local iq = verse.iq({ to = self.jid, type = "set" })
		:tag("command", { xmlns = xmlns_commands, node = self.command });
	self.stream:send_iq(iq, function (result)
		io.write(":send_iq() response\n");
		self:_process_response(result);
	end);
end

function command_mt:next(form)
	local iq = verse.iq({ to = self.jid, type = "set" })
		:tag("command", {
			xmlns = xmlns_commands,
			node = self.command,
			sessionid = self.sessionid
		});
	
	if form then iq:add_child(form); end
	
	self.stream:send_iq(iq, function (result)
		self:_process_response(result);
	end);
end
